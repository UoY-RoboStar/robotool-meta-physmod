// visualization_server.cpp - Unified visualization server for robot and world
#include <iostream>
#include <Eigen/Dense>
#include <thread>
#include <chrono>
#include <atomic>
#include <memory>
#include <mutex>
#include <cstring>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>

#if (defined(HAS_MESHCAT) && HAS_MESHCAT) || (defined(HAVE_MESHCAT) && HAVE_MESHCAT)
#include <MeshcatCpp/Material.h>
#include <MeshcatCpp/Meshcat.h>
#include <MeshcatCpp/Shape.h>
#else
#error "MeshcatCpp must be available for FULL_SIMULATION_VISUALISATION builds"
#endif

// Message types for IPC
enum MessageType {
    MSG_ROBOT_TRANSFORM = 1,
    MSG_WORLD_OBJECT = 2,
    MSG_INITIALIZE = 3,
    MSG_SHUTDOWN = 4
};

// Transform data structure
struct TransformData {
    MessageType type;
    char object_name[32];
    double transform[16];  // 4x4 matrix in column-major order
};

// Object creation data
struct ObjectData {
    MessageType type;
    char object_name[32];
    int shape_type;  // 0=box, 1=cylinder, 2=sphere, 3=mesh
    double dimensions[3];
    int color[3];
    char mesh_path[256];  // Mesh path for shape_type=3
};

class VisualizationServer {
private:
#ifdef HAS_MESHCAT
    std::unique_ptr<MeshcatCpp::Meshcat> meshcat_;
#else
    void* meshcat_;  // Placeholder when MeshcatCpp not available
#endif
    std::mutex meshcat_mutex_;
    std::atomic<bool> running_;
    int server_socket_;
    std::thread receive_thread_;
    
public:
    VisualizationServer() : running_(false), server_socket_(-1) {}
    
    ~VisualizationServer() {
        stop();
    }
    
    bool start(int port = 9999) {
#ifdef HAS_MESHCAT
        // Initialize Meshcat
        meshcat_ = std::make_unique<MeshcatCpp::Meshcat>();
        std::cout << "[VisualizationServer] Meshcat started. Check console output above for the actual port (usually 7000-7099)" << std::endl;
#else
        meshcat_ = nullptr;
        std::cout << "[VisualizationServer] MeshcatCpp not available - visualization server running in stub mode" << std::endl;
#endif
        
        // Initialize socket server for receiving data (always enabled, even without Meshcat)
        server_socket_ = socket(AF_INET, SOCK_DGRAM, 0);
        if (server_socket_ < 0) {
            std::cerr << "[VisualizationServer] Failed to create socket" << std::endl;
            return false;
        }
        
        // Allow socket reuse
        int opt = 1;
        if (setsockopt(server_socket_, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0) {
            std::cerr << "[VisualizationServer] Failed to set socket options" << std::endl;
            close(server_socket_);
            return false;
        }
        
        // Set socket timeout to allow clean shutdown
        struct timeval timeout;
        timeout.tv_sec = 1;  // 1 second timeout
        timeout.tv_usec = 0;
        if (setsockopt(server_socket_, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)) < 0) {
            std::cerr << "[VisualizationServer] Failed to set socket timeout" << std::endl;
            close(server_socket_);
            return false;
        }
        
        struct sockaddr_in server_addr;
        memset(&server_addr, 0, sizeof(server_addr));
        server_addr.sin_family = AF_INET;
        server_addr.sin_addr.s_addr = INADDR_ANY;
        server_addr.sin_port = htons(port);
        
        if (bind(server_socket_, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
            std::cerr << "[VisualizationServer] Failed to bind socket to port " << port << std::endl;
            close(server_socket_);
            return false;
        }
        
        // Initialize scene objects
        initializeScene();
        
        // Start receive thread
        running_ = true;
        receive_thread_ = std::thread(&VisualizationServer::receiveLoop, this);
        
        std::cout << "[VisualizationServer] Listening for visualization data on port " << port << std::endl;
        return true;
    }
    
    void stop() {
        running_ = false;
        if (server_socket_ >= 0) {
            close(server_socket_);
            server_socket_ = -1;
        }
        if (receive_thread_.joinable()) {
            receive_thread_.join();
        }
#ifdef HAS_MESHCAT
        meshcat_.reset();
#else
        meshcat_ = nullptr;
#endif
    }
    
private:
    void initializeScene() {
#ifdef HAS_MESHCAT
        std::lock_guard<std::mutex> lock(meshcat_mutex_);
        // Example-agnostic scene setup: only ground plane here.
        // Model-specific geometries are created by clients via MSG_INITIALIZE.
        // Create ground plane for reference
        MeshcatCpp::Material ground_material;
        ground_material.set_color(200, 200, 200);
        ground_material.opacity = 0.5;
        meshcat_->set_object("ground", MeshcatCpp::Box(10.0, 10.0, 0.01), ground_material);
        
        // Set initial transforms
        Eigen::Matrix4d ground_tf = Eigen::Matrix4d::Identity();
        ground_tf(2, 3) = -0.005;  // Slightly below z=0
        meshcat_->set_transform("ground", ground_tf);
#endif
    }
    
    void receiveLoop() {
        char buffer[1024];
        struct sockaddr_in client_addr;
        socklen_t client_len = sizeof(client_addr);
        
        while (running_) {
            int bytes = recvfrom(server_socket_, buffer, sizeof(buffer), 0,
                                (struct sockaddr*)&client_addr, &client_len);
            
            if (bytes > 0) {
                processMessage(buffer, bytes);
            } else if (bytes < 0) {
                // Check if it's a timeout (EAGAIN/EWOULDBLOCK) - this is normal
                if (errno == EAGAIN || errno == EWOULDBLOCK) {
                    // Timeout occurred, continue loop to check running_ flag
                    continue;
                } else {
                    // Real error occurred
                    if (running_) {
                        std::cerr << "[VisualizationServer] Socket error: " << strerror(errno) << std::endl;
                    }
                    break;
                }
            }
        }
    }
    
    void processMessage(const char* buffer, int size) {
#ifdef HAS_MESHCAT
        if (size < static_cast<int>(sizeof(MessageType))) return;
        
        MessageType type = *reinterpret_cast<const MessageType*>(buffer);
        
        switch (type) {
            case MSG_ROBOT_TRANSFORM:
            case MSG_WORLD_OBJECT: {
                if (size >= static_cast<int>(sizeof(TransformData))) {
                    const TransformData* data = reinterpret_cast<const TransformData*>(buffer);
                    updateTransform(data);
                }
                break;
            }
            case MSG_INITIALIZE: {
                if (size >= static_cast<int>(sizeof(ObjectData))) {
                    const ObjectData* data = reinterpret_cast<const ObjectData*>(buffer);
                    createObject(data);
                }
                break;
            }
            case MSG_SHUTDOWN: {
                std::cout << "[VisualizationServer] Received shutdown signal" << std::endl;
                running_ = false;
                break;
            }
        }
#endif
    }
    
    void updateTransform(const TransformData* data) {
#ifdef HAS_MESHCAT
        std::lock_guard<std::mutex> lock(meshcat_mutex_);
        
        // Convert transform array to Eigen matrix
        Eigen::Matrix4d transform;
        for (int i = 0; i < 4; ++i) {
            for (int j = 0; j < 4; ++j) {
                transform(i, j) = data->transform[j * 4 + i];  // Column-major
            }
        }
        
        meshcat_->set_transform(data->object_name, transform);
#endif
    }
    
    void createObject(const ObjectData* data) {
#ifdef HAS_MESHCAT
        std::lock_guard<std::mutex> lock(meshcat_mutex_);
        
        MeshcatCpp::Material material;
        material.set_color(data->color[0], data->color[1], data->color[2]);
        
        switch (data->shape_type) {
            case 0:  // Box
                meshcat_->set_object(data->object_name, 
                    MeshcatCpp::Box(data->dimensions[0], data->dimensions[1], data->dimensions[2]), 
                    material);
                break;
            case 1:  // Cylinder
                meshcat_->set_object(data->object_name,
                    MeshcatCpp::Cylinder(data->dimensions[0], data->dimensions[1]),
                    material);
                break;
            case 2:  // Sphere
                meshcat_->set_object(data->object_name,
                    MeshcatCpp::Sphere(data->dimensions[0]),
                    material);
                break;
            case 3:  // Mesh
                {
                    const std::string mesh_path = data->mesh_path;
                    double scale = data->dimensions[0];
                    try {
                        MeshcatCpp::Mesh mesh_obj(mesh_path, scale);
                        meshcat_->set_object(data->object_name, mesh_obj, material);
                        std::cout << "[VisualizationServer] Loaded mesh: " << mesh_path
                                  << " for object: " << data->object_name
                                  << " with scale: " << scale << std::endl;
                    } catch (const std::exception& e) {
                        std::cerr << "[VisualizationServer] Failed to load mesh '" << mesh_path
                                  << "': " << e.what() << ". Falling back to box." << std::endl;
                        meshcat_->set_object(data->object_name,
                            MeshcatCpp::Box(0.1, 0.1, 0.1), material);
                    }
                }
                break;
        }
#endif
    }
};

// Signal handler for clean shutdown
std::atomic<bool> shutdown_requested(false);

void signal_handler(int sig) {
    if (sig == SIGINT || sig == SIGTERM) {
        shutdown_requested = true;
    }
}

int main(int argc, char* argv[]) {
    // Set up signal handlers
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    
    int port = 9999;
    if (argc > 1) {
        port = std::atoi(argv[1]);
    }
    
    std::cout << "[VisualizationServer] Starting unified visualization server..." << std::endl;
    
    VisualizationServer server;
    if (!server.start(port)) {
        std::cerr << "[VisualizationServer] Failed to start server" << std::endl;
        return 1;
    }
    
    std::cout << "[VisualizationServer] Server running. Press Ctrl+C to stop." << std::endl;
    
    // Keep running until shutdown is requested
    while (!shutdown_requested) {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
    
    std::cout << "[VisualizationServer] Shutting down..." << std::endl;
    server.stop();
    
    return 0;
}
