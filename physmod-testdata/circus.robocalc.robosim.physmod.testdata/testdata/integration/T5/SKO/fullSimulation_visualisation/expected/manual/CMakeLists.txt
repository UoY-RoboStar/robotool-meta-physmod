cmake_minimum_required(VERSION 3.16)
project(physics_full_simulation LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

add_library(physics_engine STATIC
    src/platform1_engine.cpp
    src/platform_mapping_adapter.cpp
    src/utils.cpp
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

add_executable(physics_test
    src/orchestrator.cpp
    src/dmodel_interface.cpp
    src/PickPlace.c
)

target_include_directories(physics_test PUBLIC src)
target_link_libraries(physics_test PRIVATE physics_engine pthread Eigen3::Eigen)

find_package(Eigen3 REQUIRED)

# Find MeshcatCpp (optional for visualization)
find_package(MeshcatCpp QUIET)

# Visualization server executable (run separately)
if(MeshcatCpp_FOUND)
    add_executable(visualization_server
        src/visualization_server.cpp
    )
    target_include_directories(visualization_server PUBLIC src)
    target_link_libraries(visualization_server PRIVATE
        MeshcatCpp::MeshcatCpp
        pthread
        Eigen3::Eigen
    )
    target_compile_definitions(visualization_server PRIVATE HAS_MESHCAT=1)
    message(STATUS "MeshcatCpp found - visualization_server will be built")
else()
    message(WARNING "MeshcatCpp not found - visualization_server will NOT be built")
    message(WARNING "To enable visualization, install MeshcatCpp")
endif()
