# One program per C++ engine. An engine is built only when its location is given (see README.md).
cmake_minimum_required(VERSION 3.16)
project(acrobot_benchmark CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()
set(CMAKE_CXX_FLAGS_RELEASE "-O3")
# Not applied to RBDL: its library is built without it, and Eigen's type layout differs between the two.
set(TUNED -march=native)

find_package(Eigen3 REQUIRED)

if(RBDL_DIR)
    add_executable(engine_rbdl engine_rbdl.cpp)
    target_include_directories(engine_rbdl PRIVATE ${RBDL_DIR}/include ${RBDL_DIR}/build/include)
    target_link_libraries(engine_rbdl PRIVATE Eigen3::Eigen ${RBDL_DIR}/build/librbdl.a)
endif()

if(ROBCOGEN_GEN_DIR AND IITRBD_DIR)
    file(GLOB ROBCOGEN_SOURCES ${ROBCOGEN_GEN_DIR}/*.cpp)
    add_executable(engine_robcogen engine_robcogen.cpp ${ROBCOGEN_SOURCES})
    target_include_directories(engine_robcogen PRIVATE ${ROBCOGEN_GEN_DIR} ${IITRBD_DIR})
    target_compile_definitions(engine_robcogen PRIVATE EIGEN_NO_DEBUG)
    target_compile_options(engine_robcogen PRIVATE ${TUNED})
    target_link_libraries(engine_robcogen PRIVATE Eigen3::Eigen)
endif()

if(GAFRO_DIR AND GAFRO_DESCRIPTIONS_DIR)
    find_package(yaml-cpp REQUIRED)
    add_executable(engine_gafro engine_gafro.cpp)
    target_include_directories(engine_gafro PRIVATE ${GAFRO_DIR}/src ${GAFRO_DIR}/build/src ${GAFRO_DESCRIPTIONS_DIR}/src)
    target_compile_definitions(engine_gafro PRIVATE ACROBOT_YAML="${CMAKE_CURRENT_SOURCE_DIR}/gafro/acrobot.yaml")
    target_compile_options(engine_gafro PRIVATE ${TUNED})
    target_link_libraries(engine_gafro PRIVATE Eigen3::Eigen yaml-cpp
        ${GAFRO_DESCRIPTIONS_DIR}/build/src/gafro_robot_descriptions/libgafro_robot_descriptions.so)
endif()

if(SKO_ENGINE_DIR)
    add_executable(engine_sko engine_sko.cpp)
    target_include_directories(engine_sko PRIVATE ${SKO_ENGINE_DIR})
    target_compile_options(engine_sko PRIVATE ${TUNED})
    target_link_libraries(engine_sko PRIVATE Eigen3::Eigen)
endif()
