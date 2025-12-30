cmake_minimum_required(VERSION 3.10)
project(Screensavr)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(SDL2 REQUIRED)
find_package(OpenGL REQUIRED)
find_package(GLEW REQUIRED)

# Print some debug info
message(STATUS "SDL2_INCLUDE_DIRS: ${SDL2_INCLUDE_DIRS}")
message(STATUS "GLEW_INCLUDE_DIRS: ${GLEW_INCLUDE_DIRS}")

add_executable(screensaver 
    src/main.cpp
    src/shader.cpp
)

# More explicit include directories
target_include_directories(screensaver PRIVATE 
    ${SDL2_INCLUDE_DIRS}
    ${GLEW_INCLUDE_DIRS}
)

target_link_libraries(screensaver 
    ${SDL2_LIBRARIES} 
    ${OPENGL_LIBRARIES} 
    GLEW::GLEW
)
