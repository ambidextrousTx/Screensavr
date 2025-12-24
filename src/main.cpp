#include <iostream>
#include <SDL2/SDL.h>
#include <GL/glew.h> // Glew must be added before OpenGL headers
#include <OpenGL/gl.h>  // macOS OpenGL

int main(int argc, char* argv[]) {
    // Initialize SDL
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL initialization failed: " << SDL_GetError() << std::endl;
        return 1;
    }

    // Request OpenGL 3.3 Core Profile - Modern OpenGL
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

    // Might need this on macOS specifically
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);

    // Create a window
    SDL_Window* window = SDL_CreateWindow(
        "Cyberpunk Screensaver",
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        1280, 720,
        SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN
    );

    if (!window) {
        std::cerr << "Window creation failed: " << SDL_GetError() << std::endl;
        SDL_Quit();
        return 1;
    }

    SDL_GLContext glContext = SDL_GL_CreateContext(window);
    if (!glContext) {
        std::cerr << "OpenGL context creation failed: " << SDL_GetError() << std::endl;
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    // Initialize GLEW
    glewExperimental = GL_TRUE; // Needed for core profile
    GLenum glewError = glewInit();
    if (glewError != GLEW_OK) {
        std::cerr << "GLEW initialization failed: " << glewGetErrorString(glewError) << std::endl;
        return 1;
    }

    // Print OpenGL version for debugging
    std::cout << "OpenGL Version: " << glGetString(GL_VERSION) << std::endl;
    std::cout << "GLSL Version: " << glGetString(GL_SHADING_LANGUAGE_VERSION) << std::endl;

    // Main loop flag
    bool running = true;
    SDL_Event event;

    // Main loop
    while (running) {
        // Handle events
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                running = false;
            }
            if (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_ESCAPE) {
                running = false;
            }
        }

        // Clear to a nice cyberpunk magenta
        // Cyan: (0.0f, 0.8f, 0.8f, 1.0f)
        // Neon pink: (1.0f, 0.0f, 0.5f, 1.0f)
        // Deep blue: (0.0f, 0.0f, 0.2f, 1.0f)
        glClearColor(0.0f, 0.9f, 0.8f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        // Swap buffers (double buffering)
        SDL_GL_SwapWindow(window);

        SDL_Delay(16); // ~60 FPS
    }

    // Cleanup
    SDL_GL_DeleteContext(glContext);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
