// Utility functions: Diagnostic logging for platform state
// Implementation for utils.h

#include "utils.h"
#include <iostream>
#include <fstream>
#include <iomanip>

// Logging state
// Note: torque and transform logging remain file-local (not shared)
namespace {
    std::ofstream torque_log_file;
    bool torque_logging_enabled = false;
}

// Shared logging state (used by platform1_engine.cpp)
std::ofstream high_freq_log_file;
bool high_freq_logging_enabled = false;
int log_counter = 0;
const double HIGH_FREQ_LOG_PERIOD = 0.001;

std::ofstream velocity_log_file;
bool velocity_logging_enabled = false;

namespace {
    
    std::ofstream transform_log_file;
    bool transform_logging_enabled = false;
    
    std::ofstream mapping_debug_log_file;
    bool mapping_debug_logging_enabled = false;
}

// ============================================================================
// Torque Logging
// ============================================================================

void enable_torque_logging(const char* filename) {
    if (torque_log_file.is_open()) torque_log_file.close();
    torque_log_file.open(filename);
    if (torque_log_file.is_open()) {
        torque_log_file << "time,elbow_torque" << std::endl;
        torque_log_file << std::fixed << std::setprecision(6);
        torque_logging_enabled = true;
        std::cout << "[Logging] Torque logging enabled: " << filename << std::endl;
    } else {
        std::cerr << "[Logging] Failed to open torque log file: " << filename << std::endl;
        torque_logging_enabled = false;
    }
}

void disable_torque_logging(void) {
    if (torque_log_file.is_open()) torque_log_file.close();
    torque_logging_enabled = false;
    std::cout << "[Logging] Torque logging disabled" << std::endl;
}

void log_torque(double time, const Eigen::VectorXd& torques) {
    if (torque_logging_enabled && torque_log_file.is_open() && torques.size() >= 2) {
        torque_log_file << time << "," << torques(1) << std::endl;
    }
}

// ============================================================================
// High-Frequency Torque Logging
// ============================================================================

void enable_high_freq_logging(const char* filename) {
    if (high_freq_log_file.is_open()) high_freq_log_file.close();
    high_freq_log_file.open(filename);
    if (high_freq_log_file.is_open()) {
        high_freq_log_file << "time,elbow_torque" << std::endl;
        high_freq_log_file << std::fixed << std::setprecision(6);
        high_freq_logging_enabled = true;
        log_counter = 0;
        std::cout << "[Logging] High-frequency logging enabled: " << filename << " (1ms period)" << std::endl;
    } else {
        std::cerr << "[Logging] Failed to open high-freq log file: " << filename << std::endl;
        high_freq_logging_enabled = false;
    }
}

void disable_high_freq_logging(void) {
    if (high_freq_log_file.is_open()) {
        high_freq_log_file.close();
        std::cout << "[Logging] Torque data saved (high-frequency)" << std::endl;
    }
    high_freq_logging_enabled = false;
    std::cout << "[Logging] High-frequency logging disabled" << std::endl;
}

void log_high_freq_torque(double time, const Eigen::VectorXd& torques, double dt) {
    if (high_freq_logging_enabled && high_freq_log_file.is_open() && torques.size() >= 2) {
        int log_interval = (int)(HIGH_FREQ_LOG_PERIOD / dt);
        if (log_interval < 1) log_interval = 1;
        
        if (log_counter % log_interval == 0) {
            high_freq_log_file << std::fixed << std::setprecision(6) << time;
            high_freq_log_file << "," << std::fixed << std::setprecision(6) << torques(1);
            high_freq_log_file << std::endl;
            high_freq_log_file.flush();
        }
        log_counter++;
    }
}

// ============================================================================
// Velocity Logging
// ============================================================================

void enable_velocity_logging(const char* filename) {
    if (velocity_log_file.is_open()) velocity_log_file.close();
    velocity_log_file.open(filename);
    if (velocity_log_file.is_open()) {
        velocity_log_file << "time,wrist_pos,wrist_vel,elbow_pos,elbow_vel,wrist_tau,elbow_tau,M11_wrist,M22_elbow" << std::endl;
        velocity_log_file << std::fixed << std::setprecision(6);
        velocity_logging_enabled = true;
        std::cout << "[Logging] Velocity logging enabled: " << filename << std::endl;
    } else {
        std::cerr << "[Logging] Failed to open velocity log file: " << filename << std::endl;
        velocity_logging_enabled = false;
    }
}

void disable_velocity_logging(void) {
    if (velocity_log_file.is_open()) {
        velocity_log_file.close();
        std::cout << "[Logging] Velocity data saved" << std::endl;
    }
    velocity_logging_enabled = false;
    std::cout << "[Logging] Velocity logging disabled" << std::endl;
}

void log_velocity(double time, const Eigen::VectorXd& positions, const Eigen::VectorXd& velocities, 
                  const Eigen::VectorXd& torques, const Eigen::MatrixXd& mass_matrix) {
    if (velocity_logging_enabled && velocity_log_file.is_open() && 
        positions.size() >= 2 && velocities.size() >= 2 && torques.size() >= 2) {
        velocity_log_file << std::fixed << std::setprecision(6) << time
                          << "," << positions(0)
                          << "," << velocities(0)
                          << "," << positions(1)
                          << "," << velocities(1)
                          << "," << torques(0)
                          << "," << torques(1);

        double m11 = (mass_matrix.rows() > 0 && mass_matrix.cols() > 0) ? mass_matrix(0,0) : 0.0;
        double m22 = (mass_matrix.rows() > 1 && mass_matrix.cols() > 1) ? mass_matrix(1,1) : 0.0;
        velocity_log_file << "," << std::fixed << std::setprecision(6) << m11
                          << "," << std::fixed << std::setprecision(6) << m22
                          << std::endl;
        velocity_log_file.flush();
    }
}

// ============================================================================
// Transform Logging
// ============================================================================

void enable_transform_logging(const char* filename) {
    if (transform_log_file.is_open()) transform_log_file.close();
    transform_log_file.open(filename);
    if (transform_log_file.is_open()) {
        transform_log_file << "time,";
        auto header_mat = [&](const char* name){
            for (int r = 0; r < 4; ++r) {
                for (int c = 0; c < 4; ++c) {
                    transform_log_file << name << "_" << r << c;
                    if (!(r == 3 && c == 3)) transform_log_file << ",";
                }
            }
        };
        header_mat("Bk2"); transform_log_file << ",";
        header_mat("Bk1"); transform_log_file << ",";
        header_mat("Bk0"); transform_log_file << std::endl;
        transform_logging_enabled = true;
        std::cout << "[Logging] Transform logging enabled: " << filename << std::endl;
    } else {
        std::cerr << "[Logging] Failed to open transform log file: " << filename << std::endl;
        transform_logging_enabled = false;
    }
}

void disable_transform_logging(void) {
    if (transform_log_file.is_open()) {
        transform_log_file.close();
        std::cout << "[Logging] Transform data saved" << std::endl;
    }
    transform_logging_enabled = false;
}

void log_transforms(double time, const std::vector<Eigen::MatrixXd>& frames) {
    if (transform_logging_enabled && transform_log_file.is_open() && frames.size() >= 3) {
        auto write_mat = [](std::ofstream& out, const Eigen::Matrix4d& M){
            out
                << M(0,0) << "," << M(0,1) << "," << M(0,2) << "," << M(0,3) << ","
                << M(1,0) << "," << M(1,1) << "," << M(1,2) << "," << M(1,3) << ","
                << M(2,0) << "," << M(2,1) << "," << M(2,2) << "," << M(2,3) << ","
                << M(3,0) << "," << M(3,1) << "," << M(3,2) << "," << M(3,3);
        };
        transform_log_file << std::fixed << std::setprecision(6) << time << ",";
        write_mat(transform_log_file, frames[2]); transform_log_file << ",";
        write_mat(transform_log_file, frames[1]); transform_log_file << ",";
        write_mat(transform_log_file, frames[0]); transform_log_file << std::endl;
    }
}

// ============================================================================
// Mapping Debug Logging
// ============================================================================

void enable_mapping_debug_logging(const char* filename) {
    if (mapping_debug_log_file.is_open()) mapping_debug_log_file.close();
    mapping_debug_log_file.open(filename);
    if (mapping_debug_log_file.is_open()) {
        mapping_debug_log_file << "time,elbow_torque,operation,k_seconds" << std::endl;
        mapping_debug_log_file.flush();
        mapping_debug_logging_enabled = true;
        std::cout << "[Logging] Mapping debug logging enabled: " << filename << std::endl;
    } else {
        std::cerr << "[Logging] Failed to open mapping debug log file: " << filename << std::endl;
        mapping_debug_logging_enabled = false;
    }
}

void disable_mapping_debug_logging(void) {
    if (mapping_debug_log_file.is_open()) {
        mapping_debug_log_file.close();
        std::cout << "[Logging] Mapping debug data saved" << std::endl;
    }
    mapping_debug_logging_enabled = false;
}

void log_mapping_debug(double time, const Eigen::VectorXd& torques, const char* operation, double k) {
    if (mapping_debug_logging_enabled && mapping_debug_log_file.is_open() && torques.size() >= 2) {
        mapping_debug_log_file << std::fixed << std::setprecision(6)
                               << time << "," << torques(1) << ","
                               << (operation ? operation : "")
                               << "," << k
                               << std::endl;
        mapping_debug_log_file.flush();
    }
}

