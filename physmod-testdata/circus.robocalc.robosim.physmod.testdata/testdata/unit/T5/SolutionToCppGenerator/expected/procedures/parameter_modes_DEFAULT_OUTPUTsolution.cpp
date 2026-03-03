#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Geometry>
#include <vector>
#include <string>

int counter;
Eigen::VectorXd array;
int value;

void initGlobals() {
    counter = 0;
    array = Eigen::VectorXd::Zero(10);
    array << 0, 0, 0, 0, 0, 0, 0, 0, 0, 0;
    value = 42;
}

void increment(int &counter) {
    counter = (counter + 1);
}

void setValue(int &target, int newValue) {
    target = newValue;
}

void initArray(Eigen::VectorXd &arr, int size, int initValue) {
    for (int i = 0; i < (size - 1); i++) {
        arr(i) = initValue;
    }
}


int main() {
    initGlobals();
    increment(counter);
    setValue(value, 100);
    initArray(array, 10, 7);
    return 0;
}
