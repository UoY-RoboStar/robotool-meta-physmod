cmake_minimum_required(VERSION 3.16)
project(physics_full_simulation LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Find required packages
find_package(Eigen3 REQUIRED)
find_package(Threads REQUIRED)

# Find MeshcatCpp (required for visualization)
find_package(MeshcatCpp REQUIRED)

add_library(physics_engine STATIC
    src/platform1_engine.cpp
    src/platform_mapping_adapter.cpp
    src/utils.cpp
    # World mapping provides gravity sensor to platform mapping
    src/world_engine.cpp
    src/world_mapping.cpp
    src/object1_entity.hpp
    src/object2_entity.hpp
    src/platform1_state.hpp
    src/platform_mapping.h
    src/visualization_client.h
    src/world_mapping.h
    src/utils.h
)

target_include_directories(physics_engine PUBLIC src)
target_link_libraries(physics_engine PUBLIC pthread Eigen3::Eigen)

# Conditionally define HAS_MESHCAT for physics_engine
if(MeshcatCpp_FOUND)
    target_compile_definitions(physics_engine PRIVATE HAS_MESHCAT=0)
else()
    target_compile_definitions(physics_engine PRIVATE HAS_MESHCAT=0)
endif()

add_executable(physics_test
    src/orchestrator.cpp
    src/dmodel_interface.cpp
    src/acrobot_controller.c
)

target_include_directories(physics_test PUBLIC src)
target_link_libraries(physics_test PRIVATE physics_engine pthread Eigen3::Eigen)

# Visualization server as separate executable (MeshcatCpp REQUIRED)
add_executable(visualization_server
    src/visualization_server.cpp
)
target_include_directories(visualization_server PRIVATE src)
target_link_libraries(visualization_server
    Eigen3::Eigen
    Threads::Threads
    MeshcatCpp::MeshcatCpp
)
target_compile_definitions(visualization_server PRIVATE HAS_MESHCAT=1)
