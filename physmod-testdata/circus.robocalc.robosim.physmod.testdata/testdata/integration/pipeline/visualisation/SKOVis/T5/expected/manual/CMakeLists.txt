cmake_minimum_required(VERSION 3.16)
project(SimpleArmSerialGenerated LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(Eigen3 3.3 REQUIRED NO_MODULE)
find_package(Threads REQUIRED)

file(GLOB_RECURSE ENGINE_SOURCES CONFIGURE_DEPENDS "src/*.cpp" "src/*.c")
set(ENGINE_INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/src/engine_interface.cpp")
list(REMOVE_ITEM ENGINE_SOURCES "${ENGINE_INTERFACE}")
list(REMOVE_ITEM ENGINE_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/visualization_server.cpp")

add_library(physics_engine STATIC ${ENGINE_SOURCES})
target_include_directories(physics_engine PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/src")
target_compile_definitions(physics_engine PUBLIC HAVE_MESHCAT=0)
target_link_libraries(physics_engine PUBLIC Eigen3::Eigen Threads::Threads)

add_executable(physics_test "${ENGINE_INTERFACE}")
target_include_directories(physics_test PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src")
target_link_libraries(physics_test PRIVATE physics_engine)
