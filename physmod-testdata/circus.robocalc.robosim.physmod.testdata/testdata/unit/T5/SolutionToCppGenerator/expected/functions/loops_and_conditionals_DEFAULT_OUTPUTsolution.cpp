#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Geometry>
#include <vector>
#include <string>

int result;
int doubled;

void initGlobals() {
    result = 0;
    doubled = 0;
}

int double_value(int n) {
    int result = 0;
    result = (n * 2);
    return result;
}
int add_values(int a, int b) {
    int result = 0;
    result = (a + b);
    return result;
}

int main() {
    initGlobals();
    result = double_value(5);
    doubled = add_values(result, 10);
    return 0;
}
