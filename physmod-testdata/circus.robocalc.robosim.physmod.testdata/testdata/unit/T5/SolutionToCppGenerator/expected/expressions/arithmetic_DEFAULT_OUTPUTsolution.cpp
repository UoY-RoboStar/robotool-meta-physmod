#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Geometry>
#include <vector>
#include <string>

int a;
int b;
double c;
int result1;
double result2;
bool result3;

void initGlobals() {
    a = 5;
    b = 10;
    c = 3.14;
    result1 = 0;
    result2 = 0.0;
    result3 = false;
}

int main() {
    initGlobals();
    result1 = ((a + (b * 2)) - 3);
    result2 = ((c / 2.0) + (a * b));
    result3 = a > b == false;
    result3 = a <= 5 != b >= 10;
    result1 = (-(a + b) * 2);
    result2 = ((c + 1.0) / (a - 2));
    return 0;
}
