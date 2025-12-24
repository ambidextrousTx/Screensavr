cmake_minimum_required(VERSION 3.10)
project(Screensavr)

set(CMAKE_CXX_STANDARD 17)

find_package(SDL2 REQUIRED)
find_package(OpenGL REQUIRED)
find_package(GLEW REQUIRED)

add_executable(screensaver src/main.cpp)

target_include_directories(screensaver PRIVATE ${SDL2_INCLUDE_DIRS})
target_link_libraries(screensaver ${SDL2_LIBRARIES} ${OPENGL_LIBRARIES} GLEW::GLEW)
