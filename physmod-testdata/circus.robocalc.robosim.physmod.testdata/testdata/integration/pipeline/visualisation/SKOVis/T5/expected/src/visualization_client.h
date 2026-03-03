#ifndef VISUALIZATION_CLIENT_H
#define VISUALIZATION_CLIENT_H

#include <Eigen/Dense>

// Visualization client stub used to communicate with visualization_server.cpp
// This header provides a minimal interface so the generated code compiles when
// MeshcatCpp is not available.

extern "C" {

// Initialize visualization client connection.
// Returns 0 on success, non-zero on failure.
int viz_client_connect(const char* server_ip, int port);

// Send transform update, returns 0 on success.
int viz_client_send_transform(const char* object_name, const double* transform_4x4, int is_world);

// Disconnect from the visualization server.
void viz_client_disconnect();

}

#endif  // VISUALIZATION_CLIENT_H

