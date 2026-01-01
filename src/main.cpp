#include <iostream>
#include <SDL2/SDL.h>
#include <GL/glew.h> // Glew must be added before OpenGL headers
#include <OpenGL/gl.h>  // macOS OpenGL
#include "shader.hpp"
#include "renderer.hpp"
#include "app.hpp"

int main(int argc, char* argv[]) {
    Application app("Cyberpunk Screensaver", 1280, 720);

    if (!app.initialize()) {
        return 1;
    }

    Shader shader("../shaders/vertex.glsl", "../shaders/fragment.glsl");
    Renderer renderer;

    // Main loop
    while (app.isRunning()) {
        // Handle events
        app.pollEvents();

        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        // Use our shader program
        shader.use();
        renderer.draw();

        app.swapBuffers();
    }

    return 0;
}
