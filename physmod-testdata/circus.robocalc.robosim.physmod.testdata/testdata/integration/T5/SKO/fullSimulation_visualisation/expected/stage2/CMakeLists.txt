cmake_minimum_required(VERSION 3.10)
project(ManualImplementation)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Find required packages
find_package(Eigen3 REQUIRED)
find_package(Threads REQUIRED)

# Find MeshcatCpp (assuming it's installed or available)
find_package(MeshcatCpp QUIET)

# Main integration test executable
add_executable(integration_test
    src/orchestrator.cpp
    src/dmodel_interface.cpp
    src/platform_mapping_adapter.cpp
    src/world_mapping.cpp
    src/PickPlace.c
)

# Visualization server executable (run separately)
add_executable(visualization_server
    src/visualization_server.cpp
)

# Include directories
target_include_directories(integration_test PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${EIGEN3_INCLUDE_DIR}
)

target_include_directories(visualization_server PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${EIGEN3_INCLUDE_DIR}
)

# Link libraries
target_link_libraries(integration_test
    physics_engine
    Threads::Threads
    m  # Math library
)

target_link_libraries(visualization_server
    Eigen3::Eigen
    Threads::Threads
    m  # Math library
)

# Conditionally link MeshcatCpp if found
if(MeshcatCpp_FOUND)
    target_link_libraries(visualization_server MeshcatCpp::MeshcatCpp)
    target_compile_definitions(visualization_server PRIVATE HAS_MESHCAT=1)
    target_compile_definitions(integration_test PRIVATE HAS_MESHCAT=0)
else()
    message(WARNING "MeshcatCpp not found. Visualization will be disabled.")
    target_compile_definitions(integration_test PRIVATE HAS_MESHCAT=0)
    target_compile_definitions(visualization_server PRIVATE HAS_MESHCAT=0)
endif()

# Add compile options
target_compile_options(integration_test PRIVATE
    -g
    -O0
)

target_compile_options(visualization_server PRIVATE
    -Wall
    -Wextra
    -g
    -O0
)

# Create a library version for integration testing (without main function)
add_library(physics_engine STATIC
    src/platform1_engine.cpp
    src/world_engine.cpp
    src/world_mapping.cpp
    src/platform_mapping_adapter.cpp
    src/utils.cpp
)

target_compile_definitions(physics_engine PRIVATE LIBRARY_BUILD=1)

target_include_directories(physics_engine PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${EIGEN3_INCLUDE_DIR}
)

target_link_libraries(physics_engine
    Eigen3::Eigen
)

target_compile_options(physics_engine PRIVATE
    -g
    -O0
)

# Physics engine doesn't need MeshcatCpp anymore, it uses visualization client

# Integration test is already defined above

# Installation rules (optional)
install(TARGETS integration_test visualization_server
    RUNTIME DESTINATION bin
)

install(TARGETS physics_engine
    ARCHIVE DESTINATION lib
)

install(FILES
    src/engine.h
    src/platform_mapping.h
    DESTINATION include/manual_implementation
)

# Print build configuration
message(STATUS "Build configuration for ManualImplementation:")
message(STATUS "  C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "  Eigen3: ${EIGEN3_INCLUDE_DIR}")
message(STATUS "  MeshcatCpp: ${MeshcatCpp_FOUND}")
