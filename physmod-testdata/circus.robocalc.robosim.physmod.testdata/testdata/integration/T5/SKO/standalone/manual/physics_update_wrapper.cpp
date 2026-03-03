// Wrapper for physics_update with trajectory logging
// This replaces the original physics_update function

void physics_update_impl(); // Forward declaration for original implementation

void physics_update() {
    // Initialize trajectory log on first call
    if (!traj_initialized) {
        traj_log.open("trajectory.csv");
        traj_log << "time,wrist_pos,wrist_vel,elbow_pos,elbow_vel,wrist_tau,elbow_tau,M11_wrist,M22_elbow" << std::endl;
        traj_initialized = true;
    }

    // STANDALONE MODE: Set default actuator torques (zero torque)
    tau(0) = 0.0;  // Wrist joint
    tau(1) = 0.0;  // Elbow joint

    // Run physics computation
    physics_update_impl();

    // Log trajectory data
    if (traj_initialized && traj_log.is_open()) {
        double m11 = (M_mass.rows() > 0 && M_mass.cols() > 0) ? M_mass(0,0) : 0.0;
        double m22 = (M_mass.rows() > 1 && M_mass.cols() > 1) ? M_mass(1,1) : 0.0;
        traj_log << std::fixed << std::setprecision(6) << t
                 << "," << theta(0) << "," << d_theta(0)
                 << "," << theta(1) << "," << d_theta(1)
                 << "," << tau(0) << "," << tau(1)
                 << "," << m11 << "," << m22 << std::endl;
        if (static_cast<int>(t / dt) % 100 == 0) traj_log.flush();
    }
}
