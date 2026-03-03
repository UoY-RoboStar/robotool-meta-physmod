// Stub visualization_client.h for non-visualisation builds
// Provides empty implementation of VisualizationClient class

#ifndef VISUALIZATION_CLIENT_H
#define VISUALIZATION_CLIENT_H

#include <string>
#include <Eigen/Dense>

class VisualizationClient {
public:
    VisualizationClient() {}
    ~VisualizationClient() {}
    
    bool connect(const char* host, int port) { (void)host; (void)port; return false; }
    void disconnect() {}
    bool isConnected() const { return false; }
    void createObject(const char* path, int type, const double* dimensions, const int* color) { 
        (void)path; (void)type; (void)dimensions; (void)color; 
    }
    void updateTransform(const char* path, const double* transform) { 
        (void)path; (void)transform; 
    }
    bool sendTransform(const std::string& object_name, const Eigen::Matrix4d& transform, bool is_world = false) {
        (void)object_name; (void)transform; (void)is_world;
        return false;
    }
    void deleteObject(const char* path) { 
        (void)path; 
    }
};

#endif // VISUALIZATION_CLIENT_H

