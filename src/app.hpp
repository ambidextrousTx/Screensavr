#ifndef APP_H
#define APP_H

#include <SDL2/SDL.h>
#include <GL/glew.h>

class Application {
public:
    Application(const char* title, int width, int height);
    ~Application();

    bool initialize();
    SDL_Window* getWindow() { return window; }
    bool isRunning() { return running; }
    void pollEvents();
    void swapBuffers();
    void quit() { running = false; }

private:
    SDL_Window* window;
    SDL_GLContext glContext;
    bool running;

    bool initSDL();
    bool createWindow(const char* title, int width, int height);
    bool initOpenGL();
};

#endif
