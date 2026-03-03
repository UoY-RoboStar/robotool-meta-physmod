#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Geometry>
#include <vector>
#include <string>

Eigen::VectorXd vector;
Eigen::MatrixXd matrix;
Eigen::MatrixXd blockMat;
std::vector<int> sequence;
double element;
Eigen::VectorXd subvec;
Eigen::MatrixXd submat;
int seqElement;

void initGlobals() {
    vector = Eigen::VectorXd::Zero(4);
    vector << 1.0, 2.0, 3.0, 4.0;
    matrix = Eigen::MatrixXd::Zero(3, 3);
    matrix << 1, 2, 3, 4, 5, 6, 7, 8, 9;
    blockMat = Eigen::MatrixXd::Zero(4, 4);
blockMat.block(0, 0, 2, 2) << 1, 2, 3, 4;
blockMat.block(0, 2, 2, 2) << 5, 6, 7, 8;
blockMat.block(2, 0, 2, 2) << 9, 10, 11, 12;
blockMat.block(2, 2, 2, 2) << 13, 14, 15, 16;

    element = 0.0;
    subvec = Eigen::VectorXd::Zero(2);
    subvec << 0.0, 0.0;
    submat = Eigen::MatrixXd::Zero(2, 2);
    submat << 0, 0, 0, 0;
    seqElement = 0;
    sequence = std::vector<typename std::remove_reference<decltype(10)>::type>({ 10, 20, 30, 40 });
}

int main() {
    initGlobals();
    element = vector(2);
    subvec = vector.segment(1, 2);
    submat = matrix.block(0, 1, 2, 2);
    seqElement = sequence[1];
    return 0;
}
