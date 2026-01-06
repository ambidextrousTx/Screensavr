#version 330 core

layout(location = 0) in vec2 position;

out vec2 fragPos; // output to fragment shader

void main() {
    fragPos = position; // pass in the position
    gl_Position = vec4(position, 0.0, 1.0);
}
