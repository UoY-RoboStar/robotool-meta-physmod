#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Geometry>
#include <vector>
#include <string>

struct Point {
    int x;
    int y;
    double z;
};

struct Color {
    double red;
    double green;
    double blue;
};

Point origin;
Color mainColor;

void initGlobals() {
    origin = Point{0, 0, 0.0};
    mainColor = Color{1.0, 0.0, 0.0};
}

int main() {
    initGlobals();
    origin.x = 10;
    mainColor.green = 0.5;
    return 0;
}
