// Model, stepping and timing shared by every engine. Index 0 is the shoulder, 1 the elbow.
#pragma once

#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <numeric>
#include <vector>

#include <Eigen/Dense>

namespace acrobot {

using Joints = Eigen::Vector2d;

const double MASS = 1.0;                           // kg, each link
const double LINK1_LENGTH = 1.0;                   // m
const double COM1 = 0.5;                           // m from the shoulder
const double COM2 = 1.0;                           // m from the elbow
const double INERTIA1[3] = {0.083, 0.083, 0.001};  // about the centre of mass
const double INERTIA2[3] = {0.333, 0.333, 0.001};
const double DAMPING = 0.1;                        // N m s, each joint
const double GRAVITY = 9.81;

const double START_ANGLE = 1.0;                    // rad, both joints
const double STEP = 0.001;                         // s
const int STEPS = 5000;
const int ROW_EVERY = 10;                          // steps per trajectory row

const int WARM_UP_CALLS = 100;
const int TIMED_CALLS = 1000;

template <typename Engine>
int writeTrajectory(Engine& engine, const char* path) {
    std::FILE* out = std::fopen(path, "w");
    if (out == nullptr) {
        std::fprintf(stderr, "cannot write %s\n", path);
        return 1;
    }
    Joints q(START_ANGLE, START_ANGLE), v(0.0, 0.0);
    std::fprintf(out, "time,theta0,theta1,dtheta0,dtheta1\n");
    for (int step = 0; step <= STEPS; ++step) {
        if (step % ROW_EVERY == 0) {
            std::fprintf(out, "%.3f,%.9f,%.9f,%.9f,%.9f\n", step * STEP, q[0], q[1], v[0], v[1]);
        }
        const Joints a = engine.acceleration(q, v);
        q += STEP * v;
        v += STEP * a;
    }
    std::fclose(out);
    return 0;
}

// Times one forward-dynamics call at nine shoulder angles.
template <typename Engine>
int writeTiming(Engine& engine, const char* name, const char* path) {
    std::FILE* out = std::fopen(path, "w");
    if (out == nullptr) {
        std::fprintf(stderr, "cannot write %s\n", path);
        return 1;
    }
    std::fprintf(out, "engine,theta1,mean_time_us,std_time_us,min_time_us,max_time_us\n");
    double checksum = 0.0;
    for (int k = -4; k <= 4; ++k) {
        const Joints q(k * M_PI / 4.0, 0.0), v(0.0, 0.0);
        for (int call = 0; call < WARM_UP_CALLS; ++call) {
            checksum += engine.acceleration(q, v)[0];
        }
        std::vector<double> times(TIMED_CALLS);
        for (double& time : times) {
            const auto start = std::chrono::high_resolution_clock::now();
            const Joints a = engine.acceleration(q, v);
            const auto end = std::chrono::high_resolution_clock::now();
            time = std::chrono::duration<double, std::micro>(end - start).count();
            checksum += a[0];
        }
        const double mean = std::accumulate(times.begin(), times.end(), 0.0) / times.size();
        double squares = 0.0;
        for (double time : times) {
            squares += (time - mean) * (time - mean);
        }
        std::fprintf(out, "%s,%.6f,%.6f,%.6f,%.6f,%.6f\n", name, q[0], mean, std::sqrt(squares / times.size()),
                     *std::min_element(times.begin(), times.end()), *std::max_element(times.begin(), times.end()));
    }
    std::fclose(out);
    // Printing the sum keeps the compiler from dropping the timed calls.
    std::printf("%s: timing written to %s (checksum %.6f)\n", name, path, checksum);
    return 0;
}

template <typename Engine>
int run(int argc, char** argv, const char* name, Engine& engine) {
    if (argc == 3 && std::strcmp(argv[1], "trajectory") == 0) {
        return writeTrajectory(engine, argv[2]);
    }
    if (argc == 3 && std::strcmp(argv[1], "timing") == 0) {
        return writeTiming(engine, name, argv[2]);
    }
    std::fprintf(stderr, "usage: %s <trajectory|timing> <out.csv>\n", argv[0]);
    return 2;
}

}  // namespace acrobot
