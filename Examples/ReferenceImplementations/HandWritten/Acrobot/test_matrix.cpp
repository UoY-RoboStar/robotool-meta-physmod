#include <Eigen/Dense>
#include <iostream>
#include <cmath>

int main() {
    double theta = 1.0;
    double c = std::cos(theta);
    double s = std::sin(theta);
    
    Eigen::MatrixXd X_J_1 = Eigen::MatrixXd::Zero(6, 6);
    X_J_1 <<  c, 0, s,  0, 0, 0,
              0, 1, 0,  0, 0, 0,
             -s, 0, c,  0, 0, 0,
              0, 0, 0,  c, 0, s,
              0, 0, 0,  0, 1, 0,
              0, 0, 0, -s, 0, c;
    
    std::cout << "Matrix initialized successfully!" << std::endl;
    std::cout << X_J_1 << std::endl;
    return 0;
}
