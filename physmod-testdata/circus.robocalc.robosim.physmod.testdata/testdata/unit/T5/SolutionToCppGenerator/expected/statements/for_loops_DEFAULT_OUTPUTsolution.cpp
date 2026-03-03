#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Geometry>
#include <vector>
#include <string>

int sum;
int product;
Eigen::VectorXd numbers;

void initGlobals() {
    sum = 0;
    product = 1;
    numbers = Eigen::VectorXd::Zero(5);
    numbers << 1, 2, 3, 4, 5;
}

int main() {
    initGlobals();
    {
        for (int i = 0; i < 4; i++) {
            sum = (sum + numbers(i));
            product = (product * numbers(i));
        }
    }
    {
        for (int j : numbers) {
            if (j > 3) {
                sum = (sum + 10);
            } else {
                sum = (sum + 1);
            }
        }
    }
    return 0;
}
