cmake_minimum_required(VERSION 3.16)
project(physics_mobile_robot_full_simulation LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(MESH_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/meshes")
if (EXISTS "${MESH_SOURCE_DIR}")
    file(COPY "${MESH_SOURCE_DIR}" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
endif()

find_package(Eigen3 REQUIRED)
find_package(Threads REQUIRED)
find_package(MeshcatCpp REQUIRED)

add_library(physics_engine STATIC
    src/dmodel_interface.cpp
    src/platform1_engine.cpp
    src/platform_mapping_adapter.cpp
    src/utils.cpp
    src/world_engine.cpp
    src/world_mapping.cpp
)

target_include_directories(physics_engine PUBLIC src)
target_link_libraries(physics_engine PUBLIC pthread Eigen3::Eigen)

add_executable(physics_test
    src/orchestrator.cpp
    src/CacheConsM.c
)

target_include_directories(physics_test PUBLIC src)
target_link_libraries(physics_test PRIVATE physics_engine pthread Eigen3::Eigen)

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
