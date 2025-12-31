#include "renderer.hpp"

Renderer::Renderer() {
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
}

Renderer::~Renderer() {
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
}

void Renderer::draw() {
        // Draw the quad
        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 6);  // 6 vertices = 2 triangles
        glBindVertexArray(0);
}
