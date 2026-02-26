#include <SDL_timer.h>
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

    while (app.isRunning()) {
        app.pollEvents();

        // Get time in seconds
        float time = SDL_GetTicks() / 1000.0f;

        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        // Use our shader program
        shader.use();
        shader.setFloat("u_time", time);
        renderer.draw();

        app.swapBuffers();
    }

    return 0;
}
