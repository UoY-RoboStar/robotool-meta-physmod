#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Geometry>
#include <vector>
#include <string>

int x;
int y;
int result;
bool flag;

void initGlobals() {
    x = 10;
    y = 20;
    result = 0;
    flag = true;
}

int main() {
    initGlobals();
    {
        if (x > y) {
            result = (x - y);
        } else {
            result = (y - x);
        }
    }
    {
        if (flag == true) {
            x = (x * 2);
            y = (y * 2);
        }
    }
    {
        if (result <= 0) {
            result = 1;
        } else {
            if (result > 100) {
                result = 100;
            }
        }
    }
    return 0;
}
