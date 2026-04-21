#version 330 core

in vec2 fragPos;
out vec4 FragColor;

uniform float u_time;
uniform vec2 u_resolution;

// Pseudo-random floating point number
float random(float x) {
    return fract(sin(x * 12.9898) * 43758.5453);
}

// Helper: Generate concentric circles drone formation
void generateCirclesFormation(out vec2 positions[20]) {
    for (int i = 0; i < 20; i++) {
        if (i < 10) {
            // Inner circle - 10 drones
            float angle = (float(i) / 5.0) * 6.28318;
            float radius = 0.08;
            positions[i] = vec2(cos(angle) * radius, sin(angle) * radius * 0.6);
        } else {
            // Outer circle - 10 drones
            float angle = (float(i - 5) / 5.0) * 6.28318;
            float radius = 0.15;
            positions[i] = vec2(cos(angle) * radius, sin(angle) * radius * 0.6);
        }
    }
}

// Helper: Generate arrow drone formation
void generateArrowFormation(out vec2 positions[20]) {
    for (int i = 0; i < 20; i++) {
        if (i == 0) {
            positions[i] = vec2(0.15, 0.0);  // Tip
        } else if (i < 12) {
            // Top edge
            float t = (float(i) - 1.0) / 5.0;
            positions[i] = vec2(-0.1 + t * 0.25, 0.05 + t * 0.08);
        } else {
            // Bottom edge
            float t = (float(i) - 6.0) / 4.0;
            positions[i] = vec2(-0.1 + t * 0.25, -0.05 - t * 0.08);
        }
    }
}

// Helper: Generate spiral formation
void generateSpiralFormation(out vec2 positions[20]) {
    for (int i = 0; i < 20; i++) {
        float t = float(i) / 9.0;  // 0 to 1
        float angle = t * 6.28318 * 2.0;  // 2 full rotations
        float radius = 0.05 + t * 0.12;   // Expands outward
        positions[i] = vec2(cos(angle) * radius, sin(angle) * radius * 0.6);
    }
}

// Helper: Generate heart formation
void generateHeartFormation(out vec2 positions[20]) {
    for (int i = 0; i < 20; i++) {
        float t = float(i) / 9.0;  // 0 to 1

        // Parametric heart equation
        // x = 16 * sin^3(t)
        // y = 13*cos(t) - 5*cos(2t) - 2*cos(3t) - cos(4t)
        float angle = t * 6.28318;  // 0 to 2π

        float x = pow(sin(angle), 3.0);
        float y = (13.0 * cos(angle) 
                  - 5.0 * cos(2.0 * angle) 
                  - 2.0 * cos(3.0 * angle) 
                  - cos(4.0 * angle)) / 16.0;

        // Scale and flip (hearts are usually upside down in math)
        positions[i] = vec2(x * 0.1, -y * 0.08);
    }
}

vec3 renderDroneSwarm(
    vec2 uv,
    vec2 uvCorrected,
    float aspect,
    vec2 formationA[20],
    vec2 formationB[20],
    int numDrones,
    vec2 centerPos,
    float timeOffset,
    vec3 droneColor
) {
    vec3 color = vec3(0.0);

    // Animation - oscillate between two formations
    float formationBlend = (sin(u_time * 0.3) + 1.0) / 2.0;  // 0 to 1, smooth

    for (int i = 0; i < numDrones; i++) {

        // Interpolate between formations
        vec2 dronePos = mix(formationA[i], formationB[i], formationBlend);
        dronePos += centerPos;  // Offset to formation center

        // Distance from this pixel to this drone
        float dist = distance(uvCorrected, dronePos);

        // Drone size and glow
        float droneRadius = 0.008;

        if (dist < droneRadius) {
            // Core - bright white
            color = vec3(1.0, 1.0, 1.0);
        } else if (dist < droneRadius * 3.0) {
            // Glow
            float glowStrength = 1.0 - (dist - droneRadius) / (droneRadius * 2.0);
            color = mix(color, droneColor, glowStrength * 0.6);
        }
    }

    return color;
}

float drawScanline(vec2 uv) {
    float scanlineFrequency = 500.0;  // Number of lines
    float scanlineIntensity = 0.05;   // How dark the lines are
    float scanline = sin((uv.y + u_time * 0.1) * scanlineFrequency) * scanlineIntensity; // Moving scanline
    return scanline;
}

vec3 renderSky(vec2 uv) {
    // Dark blue gradient
    vec3 skyTop = vec3(0.02, 0.02, 0.08);
    vec3 skyBottom = vec3(0.05, 0.05, 0.15);
    return mix(skyBottom, skyTop, uv.y);
}

vec3 renderMoon(vec2 uv, vec2 uvCorrected, float aspect) {
    vec2 moonPos = vec2(0.75 * aspect, 0.7);  // upper right
    float moonRadius = 0.08;
    float distToMoon = distance(uvCorrected, moonPos);

    vec3 color = vec3(0.0);

    if (distToMoon < moonRadius) {
        // Moon surface - pale yellow
        vec3 moonColor = vec3(0.9, 0.9, 0.7);
        color = moonColor;

        // Add some subtle texture/craters
        float craterNoise = random(floor(uv.x * 30.0) + floor(uv.y * 30.0));
        if (craterNoise > 0.8) {
            color *= 0.85;  // Darken for craters
        }
    }

    // Atmospheric glow around moon
    float glowRadius = moonRadius * 1.5;
    if (distToMoon < glowRadius && distToMoon > moonRadius) {
        float glowStrength = 1.0 - (distToMoon - moonRadius) / (glowRadius - moonRadius);
        vec3 glowColor = vec3(0.7, 0.7, 0.5);
        color = mix(color, glowColor, glowStrength * 0.3);
    }

    return color;
}


vec3 applyAtmosphericHaze(vec3 color, vec2 uv) {
    float hazeAmount = pow(uv.y, 1.5) * 0.4;  // More haze at top
    vec3 hazeColor = vec3(0.15, 0.08, 0.2);   // Purple/pink tint

    // Blend the haze over everything
    return mix(color, hazeColor, hazeAmount);
}

vec3 drawBuildings(vec3 color, vec2 uv) {
    // Building parameters
    float numBuildings = 20.0;
    float buildingIndex = floor(uv.x * numBuildings);
    float buildingX = fract(uv.x * numBuildings);  // 0-1 within this building

    // Random height for each building (using building index as seed)
    float buildingHeight = 0.1 + random(buildingIndex) * 0.4;

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

            // Random width and position within the building
            float neonStartX = random(buildingIndex + 54.0) * 0.3;  // Start position (0-0.3 within building)
            float neonWidth = 0.5 + random(buildingIndex + 55.0) * 0.5;  // Width (0.5 to 1.0 of building width)
            float neonEndX = neonStartX + neonWidth;

            // Is this pixel part of the neon strip?
            // Check: right Y height AND within X bounds
            bool isInNeon = abs(uv.y - neonY) < neonThickness &&
                buildingX >= neonStartX &&
                buildingX <= neonEndX;

            // Is this pixel part of the neon strip?
            if (isInNeon) {
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

    return color;

}

vec3 renderFlyingCar(vec2 uv, vec2 uvCorrected, float aspect, float carID) {
    vec3 color = vec3(0.0);  // Default: no car

    // Car properties based on ID (so each car is consistent)
    float carSpeed = 0.1 + random(carID) * 0.15;  // Speed varies 0.1 to 0.25
    float carLane = 0.1 + random(carID + 1.0) * 0.4;  // Y position 0.1 to 0.5
    float carSize = 0.7 + random(carID + 2.0) * 0.6;  // Size multiplier 0.7 to 1.3
    float timeOffset = random(carID + 3.0) * 10.0;  // Start at different times

    // Car movement
    float carX = fract((u_time + timeOffset) * carSpeed);  // 0 to 1, loops
    float carY = carLane + sin((u_time + timeOffset) * 2.0) * 0.03;  // Slight wobble

    // Car position in aspect-corrected space
    vec2 carPos = vec2(carX * aspect, carY);

    // Car dimensions
    float carWidth = 0.04;
    float carHeight = 0.02;

    // Is this pixel part of the car body?
    bool isCarBody = abs(uvCorrected.x - carPos.x) < carWidth &&
        abs(uvCorrected.y - carPos.y) < carHeight;

    if (isCarBody) {
        // Dark car body
        color = vec3(0.15, 0.15, 0.2);

        // Add headlights (front of car)
        float distFromFront = (uvCorrected.x - carPos.x) / carWidth;  // -1 to 1
        if (distFromFront > 0.6) {  // Front 40% of car
            float lightPulse = 0.8 + sin(u_time * 10.0) * 0.2;
            color = vec3(1.0, 1.0, 0.8) * lightPulse;  // Bright white/yellow
        }

        // Add underglow
        if (abs(uvCorrected.y - (carPos.y - carHeight)) < 0.003) {  // Bottom edge
            color = vec3(0.0, 0.8, 1.0);  // Cyan underglow
        }
    }

    return color;
}

void main() {
    vec2 uv = (fragPos + 1.0) / 2.0;

    // Aspect ratio correction
    float aspect = u_resolution.x / u_resolution.y;
    vec2 uvCorrected = uv;
    uvCorrected.x *= aspect;  // Stretch X to match aspect ratio

    vec3 color = renderSky(uv);
    color = renderMoon(uv, uvCorrected, aspect);

    vec2 formationA[20];
    vec2 formationB[20];

    generateCirclesFormation(formationA);
    generateArrowFormation(formationB);

    // Drone swarm in the sky
    vec3 droneColor = renderDroneSwarm(
        uv,
        uvCorrected,
        aspect,
        formationA,
        formationB,
        20,
        vec2(0.6 * aspect, 0.85),
        0.0,
        vec3(0.3, 0.7, 0.0)
    );

    // Second swarm - spiral to heart
    vec2 formationC[20];
    vec2 formationD[20];
    generateSpiralFormation(formationC);
    generateHeartFormation(formationD);

    vec3 droneColor2 = renderDroneSwarm(
        uv, uvCorrected, aspect,
        formationC, formationD,
        20,
        vec2(0.3 * aspect, 0.80),  // Different position
        3.14,                      // π offset - halfway out of phase
        vec3(1.0, 0.3, 0.7)        // Magenta/pink
    );

if (length(droneColor2) > 0.0) {
    color = mix(color, droneColor2, 0.8);
}

    if (length(droneColor) > 0.0) {
        color = mix(color, droneColor, 0.8);  // Blend with sky
    }

    color = drawBuildings(color, uv);

    for (float carID = 0; carID < 3.0; carID += 1.0) {
        vec3 carColor = renderFlyingCar(uv, uvCorrected, aspect, carID);
        if (length(carColor) > 0.0) {
            color = carColor;
        }
    }

    color = applyAtmosphericHaze(color, uv);

    float scanline = drawScanline(uv);
    color -= scanline;  // Darken based on scanline

    FragColor = vec4(color, 1.0);
}
