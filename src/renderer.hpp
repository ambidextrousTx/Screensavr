#ifndef RENDERER_H
#define RENDERER_H

#include <GL/glew.h> // Glew must be added before OpenGL headers
#include <OpenGL/gl.h>  // macOS OpenGL

class Renderer {
public:
    Renderer();

    ~Renderer();

    void draw();

private:
    GLuint VAO, VBO;
};

#endif
