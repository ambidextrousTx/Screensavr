#version 330 core

out vec4 FragColor;

uniform float u_time;

void main() {
    // Create a pulsing color using sine wave
    // sin() oscillates between -1 and 1
    // We map it to 0 to 1 by doing (sin + 1) / 2
    float pulse = (sin(u_time * 2.0) + 1.0) / 2.0;

    // Mix between cyan and magenta based on pulse
    vec3 cyan = vec3(0.0, 0.8, 0.8);
    vec3 magenta = vec3(0.8, 0.0, 0.8);
    vec3 color = mix(cyan, magenta, pulse);

    FragColor = vec4(color, 1.0);
}
