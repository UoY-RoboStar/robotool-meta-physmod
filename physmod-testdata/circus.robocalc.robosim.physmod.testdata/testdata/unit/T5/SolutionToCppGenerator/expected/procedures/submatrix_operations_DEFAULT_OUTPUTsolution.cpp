#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Geometry>
#include <vector>
#include <string>

Eigen::MatrixXd matrix;
Eigen::VectorXd vector;

void initGlobals() {
    matrix = Eigen::MatrixXd::Zero(4, 4);
    matrix << 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
    vector = Eigen::VectorXd::Zero(6);
    vector << 0, 0, 0, 0, 0, 0;
}

void setMatrixBlock(Eigen::MatrixXd &target, int row, int col, int rows, int cols, double value) {
    target.block(row, col, rows, cols) = value;
}

void setVectorRange(Eigen::VectorXd &target, int start, int size, double value) {
    target.segment(start, size) = value;
}

int main() {
    initGlobals();
    setMatrixBlock(matrix, 1, 1, 2, 2, 5.0);
    setVectorRange(vector, 2, 3, 3.14);
    return 0;
}
