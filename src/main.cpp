#include <iostream>
#include <SDL2/SDL.h>
#include <GL/glew.h> // Glew must be added before OpenGL headers
#include <OpenGL/gl.h>  // macOS OpenGL
#include <fstream>
#include <sstream>
#include <string>

// Helper function to load shader source from file
std::string loadShaderSource(const char* filepath) {
    std::ifstream file(filepath);
    std::stringstream buffer;
    buffer << file.rdbuf();
    return buffer.str();
}

// Helper function to compile a shader
GLuint compileShader(GLenum type, const char* source) {
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, nullptr);
    glCompileShader(shader);

    // Check for errors
    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetShaderInfoLog(shader, 512, nullptr, infoLog);
        std::cerr << "Shader compilation failed:\n" << infoLog << std::endl;
    }

    return shader;
}

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

    // Define fullscreen quad vertices
    // Each vertex is just X, Y (we don't need Z for 2D)
    float vertices[] = {
    // Triangle 1
    -1.0f, -1.0f,  // Bottom-left
     1.0f, -1.0f,  // Bottom-right
     1.0f,  1.0f,  // Top-right
 
    // Triangle 2
    -1.0f, -1.0f,  // Bottom-left
     1.0f,  1.0f,  // Top-right
    -1.0f,  1.0f   // Top-left
    };

    // Upload to GPU
    // Create Vertex Array Object (VAO)
    // This remembers the configuration of how to interpret vertex data
    GLuint VAO, VBO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);

    // Bind the VAO first - everything we do now gets recorded in it
    glBindVertexArray(VAO);

    // Upload vertex data to GPU
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    // Tell OpenGL how to interpret the data
    // "Position attribute is at location 0, has 2 components (x,y), type float"
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);

    // Unbind (good practice)
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    // Load shader sources
    std::string vertSource = loadShaderSource("../shaders/vertex.glsl");
    std::string fragSource = loadShaderSource("../shaders/fragment.glsl");

    // Compile shaders
    GLuint vertexShader = compileShader(GL_VERTEX_SHADER, vertSource.c_str());
    GLuint fragmentShader = compileShader(GL_FRAGMENT_SHADER, fragSource.c_str());

    // Link into a shader program
    GLuint shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);

    // Check linking errors
    GLint success;
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetProgramInfoLog(shaderProgram, 512, nullptr, infoLog);
        std::cerr << "Shader linking failed:\n" << infoLog << std::endl;
    }

    // Clean up individual shaders (we don't need them after linking)
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

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

        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        // Use our shader program
        glUseProgram(shaderProgram);

        // Draw the quad
        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 6);  // 6 vertices = 2 triangles
        glBindVertexArray(0);

        SDL_GL_SwapWindow(window);

        // Swap buffers (double buffering)
        SDL_GL_SwapWindow(window);

        SDL_Delay(16); // ~60 FPS
    }

    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteProgram(shaderProgram);

    // Cleanup
    SDL_GL_DeleteContext(glContext);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
