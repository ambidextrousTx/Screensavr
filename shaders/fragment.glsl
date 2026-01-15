#version 330 core

in vec2 fragPos;
out vec4 FragColor;

uniform float u_time;

// Pseudo-random floating point number
float random(float x) {
    return fract(sin(x * 12.9898) * 43758.5453);
}

void main() {
    vec2 uv = (fragPos + 1.0) / 2.0;

    // Background - dark blue gradient
    vec3 skyTop = vec3(0.02, 0.02, 0.08);
    vec3 skyBottom = vec3(0.05, 0.05, 0.15);
    vec3 color = mix(skyBottom, skyTop, uv.y);

    // Building parameters
    float numBuildings = 20.0;
    float buildingIndex = floor(uv.x * numBuildings);
    float buildingX = fract(uv.x * numBuildings);  // 0-1 within this building

    // Random height for each building (using building index as seed)
    float buildingHeight = 0.3 + random(buildingIndex) * 0.6;

    // Is this pixel part of a building?
    if (uv.y < buildingHeight) {
        // Building silhouette - dark gray
        color = vec3(0.1, 0.1, 0.12);

        // Add windows
        float windowCols = 6.0;  // Windows across
        float windowRows = 20.0; // Windows up

        float windowX = fract(buildingX * windowCols);
        float windowY = fract(uv.y * windowRows);

        // Window margin (creates gaps between windows)
        float margin = 0.2;
        bool isWindow = windowX > margin && windowX < (1.0 - margin) &&
            windowY > margin && windowY < (1.0 - margin);

        if (isWindow) {
            // Window color - cyan glow
            color = vec3(0.3, 0.6, 0.7);
        }
    }

    FragColor = vec4(color, 1.0);
}
