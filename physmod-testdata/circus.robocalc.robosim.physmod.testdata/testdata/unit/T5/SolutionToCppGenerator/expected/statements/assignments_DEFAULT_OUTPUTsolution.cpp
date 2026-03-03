#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Geometry>
#include <vector>
#include <string>

int a;
double b;
Eigen::MatrixXd matrix;
Eigen::VectorXd vector;
int temp;
Eigen::MatrixXd block;

void initGlobals() {
    a = 5;
    b = 3.14;
    matrix = Eigen::MatrixXd::Zero(2, 2);
    matrix << 1, 2, 3, 4;
    vector = Eigen::VectorXd::Zero(3);
    vector << 1.0, 2.0, 3.0;
    temp = 0;
    block = Eigen::MatrixXd::Zero(2, 2);
    block << 0, 0, 0, 0;
}

int main() {
    initGlobals();
    a = 42;
    b = (a + 7.5);
    matrix(0,1) = 99;
    vector(2) = (b * 2.0);
    matrix.block(0, 0, 1, 2) << 10, 20;
    vector.segment(1, 2) << 5.0, 6.0;
    {
        int temp = 100;
        temp = (temp + a);
        a = temp;
    }
    // skip;
    return 0;
}
