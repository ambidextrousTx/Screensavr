#version 330 core

in vec2 fragPos;
out vec4 FragColor;

uniform float u_time;

void main() {
    // Normalize position to 0-1 range
    vec2 uv = (fragPos + 1.0) / 2.0;

    // Create a ripple effect from center
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);

    // Animated ripple
    float ripple = sin(dist * 20.0 - u_time * 3.0);

    // Map ripple to color
    vec3 cyan = vec3(0.0, 0.8, 0.8);
    vec3 magenta = vec3(0.8, 0.0, 0.8);
    float t = (ripple + 1.0) / 2.0;  // Map -1,1 to 0,1
    vec3 color = mix(cyan, magenta, t);

    FragColor = vec4(color, 1.0);
}
