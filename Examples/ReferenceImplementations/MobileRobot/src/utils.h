#ifndef UTILS_H
#define UTILS_H

#include <Eigen/Dense>
#include <vector>
#include <fstream>

// ============================================================================
// Utilities: Platform diagnostics and logging
// ============================================================================
//
// These functions provide diagnostic logging for platform state variables.
// Implemented in utils.cpp
// ============================================================================

// Shared logging state (defined in utils.cpp)
extern std::ofstream high_freq_log_file;
extern bool high_freq_logging_enabled;
extern int log_counter;
extern const double HIGH_FREQ_LOG_PERIOD;
extern std::ofstream velocity_log_file;
extern bool velocity_logging_enabled;

// Torque logging (controller outputs)
void enable_torque_logging(const char* filename);
void disable_torque_logging(void);
void log_torque(double time, const Eigen::VectorXd& torques);

// High-frequency torque logging (1ms resolution)
void enable_high_freq_logging(const char* filename);
void disable_high_freq_logging(void);
void log_high_freq_torque(double time, const Eigen::VectorXd& torques, double dt);

// Velocity logging (joint velocities)
void enable_velocity_logging(const char* filename);
void disable_velocity_logging(void);
void log_velocity(double time, const Eigen::VectorXd& positions, const Eigen::VectorXd& velocities,
                  const Eigen::VectorXd& torques, const Eigen::MatrixXd& mass_matrix);

// Transform logging (link positions/orientations)
void enable_transform_logging(const char* filename);
void disable_transform_logging(void);
void log_transforms(double time, const std::vector<Eigen::MatrixXd>& frames);

// Mapping debug logging (platform mapping state)
void enable_mapping_debug_logging(const char* filename);
void disable_mapping_debug_logging(void);
void log_mapping_debug(double time, const Eigen::VectorXd& torques, const char* operation, double k);

#endif // UTILS_H
