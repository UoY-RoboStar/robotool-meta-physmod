#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Geometry>
#include <vector>
#include <string>

Eigen::VectorXd vector;
Eigen::MatrixXd matrix;
double element;
Eigen::VectorXd subvec;
Eigen::MatrixXd submat;

void initGlobals() {
    vector = Eigen::VectorXd::Zero(5);
    vector << 1.0, 2.0, 3.0, 4.0, 5.0;
    matrix = Eigen::MatrixXd::Zero(3, 3);
    matrix << 1, 2, 3, 4, 5, 6, 7, 8, 9;
    element = 0.0;
    subvec = Eigen::VectorXd::Zero(2);
    subvec << 0.0, 0.0;
    submat = Eigen::MatrixXd::Zero(2, 2);
    submat << 0, 0, 0, 0;
}

double getElement(Eigen::VectorXd v, int idx) {
    double result = 0.0;
    result = v(idx);
    return result;
}
Eigen::VectorXd getSubrange(Eigen::VectorXd v, int start, int size) {
    Eigen::VectorXd result = Eigen::VectorXd();
    result = v.segment(start, size);
    return result;
}
Eigen::MatrixXd getSubmatrix(Eigen::MatrixXd m, int row, int col, int rows, int cols) {
    Eigen::MatrixXd result = Eigen::MatrixXd();
    result = m.block(row, col, rows, cols);
    return result;
}

int main() {
    initGlobals();
    element = getElement(vector, 2);
    subvec = getSubrange(vector, 1, 2);
    submat = getSubmatrix(matrix, 0, 0, 2, 2);
    return 0;
}
