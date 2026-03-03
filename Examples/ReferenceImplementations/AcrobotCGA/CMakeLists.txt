cmake_minimum_required(VERSION 3.10)
project(physics_cga)

# C++17 standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Eigen (header-only): locate headers robustly
# Allow override via EIGEN3_INCLUDE_DIR env or cache variable
set(EIGEN3_HINTS $ENV{EIGEN3_INCLUDE_DIR} ${EIGEN3_INCLUDE_DIR})
find_path(EIGEN3_INCLUDE_DIR Eigen/Dense
    HINTS ${EIGEN3_HINTS}
    PATHS /usr/include/eigen3 /usr/local/include/eigen3
)
if(NOT EIGEN3_INCLUDE_DIR)
    message(FATAL_ERROR "Eigen headers not found. Install libeigen3-dev or set EIGEN3_INCLUDE_DIR.")
endif()

# Find Threads for visualization server
find_package(Threads REQUIRED)

# Find MeshcatCpp (optional)
find_package(MeshcatCpp QUIET)

# Source files for physics simulation
set(SOURCE_FILES
    src/platform1_engine.cpp
    src/orchestrator.cpp
)

# Physics simulation executable
add_executable(platform1_sim ${SOURCE_FILES})

# Include directories
target_include_directories(platform1_sim PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${EIGEN3_INCLUDE_DIR}
)

# Visualization support - define HAS_VISUALIZATION for physics simulation
target_compile_definitions(platform1_sim PRIVATE HAS_VISUALIZATION)

# Separate visualization server executable
add_executable(visualization_server
    src/visualization_server.cpp
)

target_include_directories(visualization_server PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${EIGEN3_INCLUDE_DIR}
)

target_link_libraries(visualization_server
    Threads::Threads
    m  # Math library
)

# Conditionally link MeshcatCpp if found
if(MeshcatCpp_FOUND)
    target_link_libraries(visualization_server MeshcatCpp::MeshcatCpp)
    target_compile_definitions(visualization_server PRIVATE HAS_MESHCAT=1)
else()
    message(WARNING "MeshcatCpp not found. Visualization server will use stub implementation.")
    target_compile_definitions(visualization_server PRIVATE HAS_MESHCAT=0)
endif()

target_compile_options(visualization_server PRIVATE
    -Wall
    -Wextra
    -g
    -O0
)

# Compiler warnings
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(platform1_sim PRIVATE -Wall -Wextra -Wpedantic)
endif()

# Installation
install(TARGETS platform1_sim
    RUNTIME DESTINATION bin
)

install(TARGETS visualization_server
    RUNTIME DESTINATION bin
)
