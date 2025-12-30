#ifndef SHADER_H
#define SHADER_H

#include <GL/glew.h>
#include <string>

class Shader {
public:
    Shader(const char* vertexPath, const char* fragmentPath);

    ~Shader();

    // Use/activate the shader program
    void use();

    // Utility functions for setting uniforms
    void setFloat(const std::string& name, float value);
    void setInt(const std::string& name, int value);
    void setVec2(const std::string& name, float x, float y);

    // Public so you can access it if needed, but generally you shouldn't need to
    GLuint programID;

private:
    std::string loadShaderSource(const char* filepath);
    GLuint compileShader(GLenum type, const char* source);
    void checkCompileErrors(GLuint shader, const std::string& type);
};

#endif
