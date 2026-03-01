#version 330 core

in vec2 fragPos;
out vec4 FragColor;

uniform float u_time;

// Pseudo-random floating point number
float random(float x) {
    return fract(sin(x * 12.9898) * 43758.5453);
}

float drawScanline(vec2 uv) {
    float scanlineFrequency = 500.0;  // Number of lines
    float scanlineIntensity = 0.05;   // How dark the lines are
    float scanline = sin((uv.y + u_time * 0.1) * scanlineFrequency) * scanlineIntensity; // Moving scanline
    return scanline;
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
            // Unique seed for this window (based on building + window position)
            float windowSeed = buildingIndex * 100.0 + floor(buildingX * windowCols) + floor(uv.y * windowRows) * 10.0;

            // Random chance this window is lit (70% lit, 30% dark)
            float litChance = random(windowSeed);

            if (litChance > 0.3) {
                // Window is lit - vary the brightness
                float brightness = 0.4 + random(windowSeed + 1.0) * 0.6;  // 0.4 to 1.0

                // Only 5% of lit windows flicker
                float flickerChance = random(windowSeed + 3.0);

                if (flickerChance > 0.95) {
                    // This window flickers
                    // Create a flickering pattern based on time
                    float flickerTime = u_time * (2.0 + random(windowSeed + 4.0) * 4.0);  // Vary speed
                    float flickerNoise = random(floor(flickerTime + windowSeed));

                    // Sudden on/off: if noise > threshold, dim the light
                    if (flickerNoise > 0.7) {
                        brightness *= 0.2;  // Drop to 20% brightness (almost off)
                    }
                }

                // Vary the color slightly - more cyan or more white
                float colorVariation = random(windowSeed + 2.0);
                vec3 windowColor = mix(
                    vec3(0.3, 0.6, 0.7),  // Cyan
                    vec3(0.8, 0.8, 0.9),  // Warm white
                    colorVariation
                );

                color = windowColor * brightness;
            } else {
                // Window is dark - very dark gray
                color = vec3(0.05, 0.05, 0.06);
            }
        }


        // Neon signs on buildings
        // Check if this building has a neon sign
        float neonChance = random(buildingIndex + 50.0);

        if (neonChance > 0.6) {  // 40% of buildings have neon
            // Determine neon strip height on this building
            float neonY = 0.2 + random(buildingIndex + 51.0) * 0.5;  // Random height on building
            float neonThickness = 0.015;  // How thick the strip is

            // Is this pixel part of the neon strip?
            if (abs(uv.y - neonY) < neonThickness) {
                // Choose neon color for this building
                float colorChoice = random(buildingIndex + 52.0);
                vec3 neonColor;

                if (colorChoice < 0.33) {
                    neonColor = vec3(0.0, 1.0, 1.0);  // Bright cyan
                } else if (colorChoice < 0.66) {
                    neonColor = vec3(1.0, 0.0, 0.8);  // Hot pink/magenta
                } else {
                    neonColor = vec3(0.0, 0.5, 1.0);  // Electric blue
                }

                // Pulse the neon
                float pulse = 0.7 + sin(u_time * (1.0 + random(buildingIndex + 53.0) * 2.0)) * 0.3;
                color = neonColor * pulse;
            }
        }
    }

    // Atmospheric haze
    float hazeAmount = pow(uv.y, 1.5) * 0.4;  // More haze at top
    vec3 hazeColor = vec3(0.15, 0.08, 0.2);   // Purple/pink tint

    // Blend the haze over everything
    color = mix(color, hazeColor, hazeAmount);

    float scanline = drawScanline(uv);
    color -= scanline;  // Darken based on scanline

    FragColor = vec4(color, 1.0);
}
