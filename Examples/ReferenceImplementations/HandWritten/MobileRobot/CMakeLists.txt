cmake_minimum_required(VERSION 3.16)
project(mobile_robot_reference LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(Eigen3 REQUIRED)
find_package(Threads REQUIRED)

set(DMODEL_DIR "/home/arjunbadyal/RoboStar/DigitalTwins_RoboSim/mobileRobot/dmodelFMU/adapted_C"
    CACHE PATH "Path to mobile robot adapted_C d-model sources")

if (NOT EXISTS "${DMODEL_DIR}/CacheConsM.c")
    message(FATAL_ERROR "Missing CacheConsM.c at ${DMODEL_DIR}. Update DMODEL_DIR.")
endif()

add_library(physics_engine STATIC
    src/dmodel_interface.cpp
    src/platform1_engine.cpp
    src/utils.cpp
    src/world_engine.cpp
    src/world_mapping.cpp
    src/platform_mapping_adapter.cpp
)

target_include_directories(physics_engine PUBLIC
    src
    ${DMODEL_DIR}
)

target_link_libraries(physics_engine PUBLIC Eigen3::Eigen Threads::Threads)

add_executable(physics_test
    src/orchestrator.cpp
    src/CacheConsM.c
)

target_include_directories(physics_test PUBLIC
    src
    ${DMODEL_DIR}
)

target_link_libraries(physics_test PRIVATE physics_engine Threads::Threads Eigen3::Eigen)

find_package(MeshcatCpp QUIET)
if (MeshcatCpp_FOUND)
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
endif()
