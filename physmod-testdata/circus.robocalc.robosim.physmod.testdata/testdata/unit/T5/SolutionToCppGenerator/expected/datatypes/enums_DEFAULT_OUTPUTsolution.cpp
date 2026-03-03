#include <iostream>
#include <Eigen/Dense>
#include <Eigen/Geometry>
#include <vector>
#include <string>

enum class Status { Idle, Running, Error };
enum class Priority { Low, Medium, High };

Status currentStatus;
Priority taskPriority;
int dummy;

void initGlobals() {
}

int main() {
    initGlobals();
    // Computation Block
    // skip;
    return 0;
}
