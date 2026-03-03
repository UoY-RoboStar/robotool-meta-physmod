#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Geometry>
#include <vector>
#include <string>

int result;

void initGlobals() {
    result = 0;
}

int add(int a, int b) {
    int result = 0;
    result = (a + b);
    return result;
}

int main() {
    initGlobals();
    result = add(5, 3);
    return 0;
}
