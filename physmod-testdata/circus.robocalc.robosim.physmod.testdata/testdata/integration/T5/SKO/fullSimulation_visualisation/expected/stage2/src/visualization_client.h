// visualization_client.h - Client interface for sending visualization data
#ifndef VISUALIZATION_CLIENT_H
#define VISUALIZATION_CLIENT_H

#include <Eigen/Dense>
#include <string>
#include <cstring>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

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
    char mesh_path[256];  // Path for shape_type=3
};

class VisualizationClient {
private:
    int socket_;
    struct sockaddr_in server_addr_;
    bool connected_;

public:
    VisualizationClient() : socket_(-1), connected_(false) {
        memset(&server_addr_, 0, sizeof(server_addr_));
    }

    ~VisualizationClient() {
        disconnect();
    }

    bool connect(const char* server_ip = "127.0.0.1", int port = 9999) {
        socket_ = socket(AF_INET, SOCK_DGRAM, 0);
        if (socket_ < 0) {
            return false;
        }

        server_addr_.sin_family = AF_INET;
        server_addr_.sin_port = htons(port);
        inet_pton(AF_INET, server_ip, &server_addr_.sin_addr);

        connected_ = true;
        return true;
    }

    void disconnect() {
        if (socket_ >= 0) {
            close(socket_);
            socket_ = -1;
        }
        connected_ = false;
    }

    bool sendTransform(const std::string& object_name, const Eigen::Matrix4d& transform, bool is_world = false) {
        if (!connected_) return false;

        TransformData data;
        data.type = is_world ? MSG_WORLD_OBJECT : MSG_ROBOT_TRANSFORM;
        strncpy(data.object_name, object_name.c_str(), sizeof(data.object_name) - 1);
        data.object_name[sizeof(data.object_name) - 1] = '\0';

        for (int j = 0; j < 4; ++j) {
            for (int i = 0; i < 4; ++i) {
                data.transform[j * 4 + i] = transform(i, j);
            }
        }

        int sent = sendto(socket_, &data, sizeof(data), 0,
                         (struct sockaddr*)&server_addr_, sizeof(server_addr_));
        return sent == sizeof(data);
    }

    bool createObject(const std::string& object_name, int shape_type,
                     const double dims[3], const int color[3]) {
        if (!connected_) return false;

        ObjectData data;
        std::memset(&data, 0, sizeof(data));
        data.type = MSG_INITIALIZE;
        strncpy(data.object_name, object_name.c_str(), sizeof(data.object_name) - 1);
        data.object_name[sizeof(data.object_name) - 1] = '\0';
        data.shape_type = shape_type;
        memcpy(data.dimensions, dims, sizeof(data.dimensions));
        memcpy(data.color, color, sizeof(data.color));
        data.mesh_path[0] = '\0';

        int sent = sendto(socket_, &data, sizeof(data), 0,
                     (struct sockaddr*)&server_addr_, sizeof(server_addr_));
        return sent == sizeof(data);
    }

    bool createMesh(const std::string& object_name, const std::string& mesh_path,
                    double scale, const int color[3]) {
        if (!connected_) return false;

        ObjectData data;
        std::memset(&data, 0, sizeof(data));
        data.type = MSG_INITIALIZE;
        strncpy(data.object_name, object_name.c_str(), sizeof(data.object_name) - 1);
        data.object_name[sizeof(data.object_name) - 1] = '\0';
        data.shape_type = 3;  // mesh
        data.dimensions[0] = scale;
        data.dimensions[1] = 1.0;
        data.dimensions[2] = 1.0;
        memcpy(data.color, color, sizeof(data.color));
        strncpy(data.mesh_path, mesh_path.c_str(), sizeof(data.mesh_path) - 1);
        data.mesh_path[sizeof(data.mesh_path) - 1] = '\0';

        int sent = sendto(socket_, &data, sizeof(data), 0,
                         (struct sockaddr*)&server_addr_, sizeof(server_addr_));
        return sent == sizeof(data);
    }

    bool sendShutdown() {
        if (!connected_) return false;

        MessageType type = MSG_SHUTDOWN;
        int sent = sendto(socket_, &type, sizeof(type), 0,
                         (struct sockaddr*)&server_addr_, sizeof(server_addr_));
        return sent == sizeof(type);
    }

    bool isConnected() const {
        return connected_;
    }
};

extern "C" {
    int viz_client_connect(const char* server_ip, int port);
    int viz_client_send_transform(const char* object_name, const double* transform_4x4, int is_world);
    void viz_client_disconnect();
}

#endif // VISUALIZATION_CLIENT_H
