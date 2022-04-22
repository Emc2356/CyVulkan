# WARNING: auto generated code, do not edit directly

from libc.stdint cimport uint64_t, uint32_t
from CyVulkan cimport *

cdef extern from "<GLFW/glfw3.h>" nogil:
    ctypedef void (*GLFWglproc)()
    ctypedef void (*GLFWvkproc)()
    ctypedef struct GLFWmonitor:
        pass
    ctypedef struct GLFWwindow:
        pass
    ctypedef struct GLFWcursor:
        pass
    ctypedef void (* GLFWerrorfun)(int error_code, const char* description)
    ctypedef void (* GLFWwindowposfun)(GLFWwindow* window, int xpos, int ypos)
    ctypedef void (* GLFWwindowsizefun)(GLFWwindow* window, int width, int height)
    ctypedef void (* GLFWwindowclosefun)(GLFWwindow* window)
    ctypedef void (* GLFWwindowrefreshfun)(GLFWwindow* window)
    ctypedef void (* GLFWwindowfocusfun)(GLFWwindow* window, int focused)
    ctypedef void (* GLFWwindowiconifyfun)(GLFWwindow* window, int iconified)
    ctypedef void (* GLFWwindowmaximizefun)(GLFWwindow* window, int maximized)
    ctypedef void (* GLFWframebuffersizefun)(GLFWwindow* window, int width, int height)
    ctypedef void (* GLFWwindowcontentscalefun)(GLFWwindow* window, float xscale, float yscale)
    ctypedef void (* GLFWmousebuttonfun)(GLFWwindow* window, int button, int action, int mods)
    ctypedef void (* GLFWcursorposfun)(GLFWwindow* window, double xpos, double ypos)
    ctypedef void (* GLFWcursorenterfun)(GLFWwindow* window, int entered)
    ctypedef void (* GLFWscrollfun)(GLFWwindow* window, double xoffset, double yoffset)
    ctypedef void (* GLFWkeyfun)(GLFWwindow* window, int key, int scancode, int action, int mods)
    ctypedef void (* GLFWcharfun)(GLFWwindow* window, unsigned int codepoint)
    ctypedef void (* GLFWcharmodsfun)(GLFWwindow* window, unsigned int codepoint, int mods)
    ctypedef void (* GLFWdropfun)(GLFWwindow* window, int path_count, const char* paths[])
    ctypedef void (* GLFWmonitorfun)(GLFWmonitor* monitor, int event)
    ctypedef void (* GLFWjoystickfun)(int jid, int event)
    ctypedef struct GLFWvidmode:
        int width
        int height
        int redBits
        int greenBits
        int blueBits
        int refreshRate
    ctypedef struct GLFWgammaramp:
        unsigned short* red
        unsigned short* green
        unsigned short* blue
        unsigned int size
    ctypedef struct GLFWimage:
        int width
        int height
        unsigned char* pixels
    ctypedef struct GLFWgamepadstate:
        unsigned char buttons[15]
        float axes[6]
    int glfwInit()
    void glfwTerminate()
    void glfwInitHint(int hint, int value)
    void glfwGetVersion(int* major, int* minor, int* rev)
    const char* glfwGetVersionString()
    int glfwGetError(const char** description)
    GLFWerrorfun glfwSetErrorCallback(GLFWerrorfun callback)
    GLFWmonitor** glfwGetMonitors(int* count)
    GLFWmonitor* glfwGetPrimaryMonitor()
    void glfwGetMonitorPos(GLFWmonitor* monitor, int* xpos, int* ypos)
    void glfwGetMonitorWorkarea(GLFWmonitor* monitor, int* xpos, int* ypos, int* width, int* height)
    void glfwGetMonitorPhysicalSize(GLFWmonitor* monitor, int* widthMM, int* heightMM)
    void glfwGetMonitorContentScale(GLFWmonitor* monitor, float* xscale, float* yscale)
    const char* glfwGetMonitorName(GLFWmonitor* monitor)
    void glfwSetMonitorUserPointer(GLFWmonitor* monitor, void* pointer)
    void* glfwGetMonitorUserPointer(GLFWmonitor* monitor)
    GLFWmonitorfun glfwSetMonitorCallback(GLFWmonitorfun callback)
    const GLFWvidmode* glfwGetVideoModes(GLFWmonitor* monitor, int* count)
    const GLFWvidmode* glfwGetVideoMode(GLFWmonitor* monitor)
    void glfwSetGamma(GLFWmonitor* monitor, float gamma)
    const GLFWgammaramp* glfwGetGammaRamp(GLFWmonitor* monitor)
    void glfwSetGammaRamp(GLFWmonitor* monitor, const GLFWgammaramp* ramp)
    void glfwDefaultWindowHints()
    void glfwWindowHint(int hint, int value)
    void glfwWindowHintString(int hint, const char* value)
    GLFWwindow* glfwCreateWindow(int width, int height, const char* title, GLFWmonitor* monitor, GLFWwindow* share)
    void glfwDestroyWindow(GLFWwindow* window)
    int glfwWindowShouldClose(GLFWwindow* window)
    void glfwSetWindowShouldClose(GLFWwindow* window, int value)
    void glfwSetWindowTitle(GLFWwindow* window, const char* title)
    void glfwSetWindowIcon(GLFWwindow* window, int count, const GLFWimage* images)
    void glfwGetWindowPos(GLFWwindow* window, int* xpos, int* ypos)
    void glfwSetWindowPos(GLFWwindow* window, int xpos, int ypos)
    void glfwGetWindowSize(GLFWwindow* window, int* width, int* height)
    void glfwSetWindowSizeLimits(GLFWwindow* window, int minwidth, int minheight, int maxwidth, int maxheight)
    void glfwSetWindowAspectRatio(GLFWwindow* window, int numer, int denom)
    void glfwSetWindowSize(GLFWwindow* window, int width, int height)
    void glfwGetFramebufferSize(GLFWwindow* window, int* width, int* height)
    void glfwGetWindowFrameSize(GLFWwindow* window, int* left, int* top, int* right, int* bottom)
    void glfwGetWindowContentScale(GLFWwindow* window, float* xscale, float* yscale)
    float glfwGetWindowOpacity(GLFWwindow* window)
    void glfwSetWindowOpacity(GLFWwindow* window, float opacity)
    void glfwIconifyWindow(GLFWwindow* window)
    void glfwRestoreWindow(GLFWwindow* window)
    void glfwMaximizeWindow(GLFWwindow* window)
    void glfwShowWindow(GLFWwindow* window)
    void glfwHideWindow(GLFWwindow* window)
    void glfwFocusWindow(GLFWwindow* window)
    void glfwRequestWindowAttention(GLFWwindow* window)
    GLFWmonitor* glfwGetWindowMonitor(GLFWwindow* window)
    void glfwSetWindowMonitor(GLFWwindow* window, GLFWmonitor* monitor, int xpos, int ypos, int width, int height, int refreshRate)
    int glfwGetWindowAttrib(GLFWwindow* window, int attrib)
    void glfwSetWindowAttrib(GLFWwindow* window, int attrib, int value)
    void glfwSetWindowUserPointer(GLFWwindow* window, void* pointer)
    void* glfwGetWindowUserPointer(GLFWwindow* window)
    GLFWwindowposfun glfwSetWindowPosCallback(GLFWwindow* window, GLFWwindowposfun callback)
    GLFWwindowsizefun glfwSetWindowSizeCallback(GLFWwindow* window, GLFWwindowsizefun callback)
    GLFWwindowclosefun glfwSetWindowCloseCallback(GLFWwindow* window, GLFWwindowclosefun callback)
    GLFWwindowrefreshfun glfwSetWindowRefreshCallback(GLFWwindow* window, GLFWwindowrefreshfun callback)
    GLFWwindowfocusfun glfwSetWindowFocusCallback(GLFWwindow* window, GLFWwindowfocusfun callback)
    GLFWwindowiconifyfun glfwSetWindowIconifyCallback(GLFWwindow* window, GLFWwindowiconifyfun callback)
    GLFWwindowmaximizefun glfwSetWindowMaximizeCallback(GLFWwindow* window, GLFWwindowmaximizefun callback)
    GLFWframebuffersizefun glfwSetFramebufferSizeCallback(GLFWwindow* window, GLFWframebuffersizefun callback)
    GLFWwindowcontentscalefun glfwSetWindowContentScaleCallback(GLFWwindow* window, GLFWwindowcontentscalefun callback)
    void glfwPollEvents()
    void glfwWaitEvents()
    void glfwWaitEventsTimeout(double timeout)
    void glfwPostEmptyEvent()
    int glfwGetInputMode(GLFWwindow* window, int mode)
    void glfwSetInputMode(GLFWwindow* window, int mode, int value)
    int glfwRawMouseMotionSupported()
    const char* glfwGetKeyName(int key, int scancode)
    int glfwGetKeyScancode(int key)
    int glfwGetKey(GLFWwindow* window, int key)
    int glfwGetMouseButton(GLFWwindow* window, int button)
    void glfwGetCursorPos(GLFWwindow* window, double* xpos, double* ypos)
    void glfwSetCursorPos(GLFWwindow* window, double xpos, double ypos)
    GLFWcursor* glfwCreateCursor(const GLFWimage* image, int xhot, int yhot)
    GLFWcursor* glfwCreateStandardCursor(int shape)
    void glfwDestroyCursor(GLFWcursor* cursor)
    void glfwSetCursor(GLFWwindow* window, GLFWcursor* cursor)
    GLFWkeyfun glfwSetKeyCallback(GLFWwindow* window, GLFWkeyfun callback)
    GLFWcharfun glfwSetCharCallback(GLFWwindow* window, GLFWcharfun callback)
    GLFWcharmodsfun glfwSetCharModsCallback(GLFWwindow* window, GLFWcharmodsfun callback)
    GLFWmousebuttonfun glfwSetMouseButtonCallback(GLFWwindow* window, GLFWmousebuttonfun callback)
    GLFWcursorposfun glfwSetCursorPosCallback(GLFWwindow* window, GLFWcursorposfun callback)
    GLFWcursorenterfun glfwSetCursorEnterCallback(GLFWwindow* window, GLFWcursorenterfun callback)
    GLFWscrollfun glfwSetScrollCallback(GLFWwindow* window, GLFWscrollfun callback)
    GLFWdropfun glfwSetDropCallback(GLFWwindow* window, GLFWdropfun callback)
    int glfwJoystickPresent(int jid)
    const float* glfwGetJoystickAxes(int jid, int* count)
    const unsigned char* glfwGetJoystickButtons(int jid, int* count)
    const unsigned char* glfwGetJoystickHats(int jid, int* count)
    const char* glfwGetJoystickName(int jid)
    const char* glfwGetJoystickGUID(int jid)
    void glfwSetJoystickUserPointer(int jid, void* pointer)
    void* glfwGetJoystickUserPointer(int jid)
    int glfwJoystickIsGamepad(int jid)
    GLFWjoystickfun glfwSetJoystickCallback(GLFWjoystickfun callback)
    int glfwUpdateGamepadMappings(const char* string)
    const char* glfwGetGamepadName(int jid)
    int glfwGetGamepadState(int jid, GLFWgamepadstate* state)
    void glfwSetClipboardString(GLFWwindow* window, const char* string)
    const char* glfwGetClipboardString(GLFWwindow* window)
    double glfwGetTime()
    void glfwSetTime(double time)
    uint64_t glfwGetTimerValue()
    uint64_t glfwGetTimerFrequency()
    void glfwMakeContextCurrent(GLFWwindow* window)
    GLFWwindow* glfwGetCurrentContext()
    void glfwSwapBuffers(GLFWwindow* window)
    void glfwSwapInterval(int interval)
    int glfwExtensionSupported(const char* extension)
    GLFWglproc glfwGetProcAddress(const char* procname)
    int glfwVulkanSupported()
    const char** glfwGetRequiredInstanceExtensions(uint32_t* count)
    GLFWvkproc glfwGetInstanceProcAddress(VkInstance instance, const char* procname)
    int glfwGetPhysicalDevicePresentationSupport(VkInstance instance, VkPhysicalDevice device, uint32_t queuefamily)
    VkResult glfwCreateWindowSurface(VkInstance instance, GLFWwindow* window, const VkAllocationCallbacks* allocator, VkSurfaceKHR* surface)
    int GLFW_VERSION_MAJOR
    int GLFW_VERSION_MINOR
    int GLFW_VERSION_REVISION
    int GLFW_TRUE
    int GLFW_FALSE
    int GLFW_RELEASE
    int GLFW_PRESS
    int GLFW_REPEAT
    int GLFW_HAT_CENTERED
    int GLFW_HAT_UP
    int GLFW_HAT_RIGHT
    int GLFW_HAT_DOWN
    int GLFW_HAT_LEFT
    int GLFW_HAT_RIGHT_UP
    int GLFW_HAT_RIGHT_DOWN
    int GLFW_HAT_LEFT_UP
    int GLFW_HAT_LEFT_DOWN
    int GLFW_KEY_UNKNOWN
    int GLFW_KEY_SPACE
    int GLFW_KEY_APOSTROPHE
    int GLFW_KEY_COMMA
    int GLFW_KEY_MINUS
    int GLFW_KEY_PERIOD
    int GLFW_KEY_SLASH
    int GLFW_KEY_0
    int GLFW_KEY_1
    int GLFW_KEY_2
    int GLFW_KEY_3
    int GLFW_KEY_4
    int GLFW_KEY_5
    int GLFW_KEY_6
    int GLFW_KEY_7
    int GLFW_KEY_8
    int GLFW_KEY_9
    int GLFW_KEY_SEMICOLON
    int GLFW_KEY_EQUAL
    int GLFW_KEY_A
    int GLFW_KEY_B
    int GLFW_KEY_C
    int GLFW_KEY_D
    int GLFW_KEY_E
    int GLFW_KEY_F
    int GLFW_KEY_G
    int GLFW_KEY_H
    int GLFW_KEY_I
    int GLFW_KEY_J
    int GLFW_KEY_K
    int GLFW_KEY_L
    int GLFW_KEY_M
    int GLFW_KEY_N
    int GLFW_KEY_O
    int GLFW_KEY_P
    int GLFW_KEY_Q
    int GLFW_KEY_R
    int GLFW_KEY_S
    int GLFW_KEY_T
    int GLFW_KEY_U
    int GLFW_KEY_V
    int GLFW_KEY_W
    int GLFW_KEY_X
    int GLFW_KEY_Y
    int GLFW_KEY_Z
    int GLFW_KEY_LEFT_BRACKET
    int GLFW_KEY_BACKSLASH
    int GLFW_KEY_RIGHT_BRACKET
    int GLFW_KEY_GRAVE_ACCENT
    int GLFW_KEY_WORLD_1
    int GLFW_KEY_WORLD_2
    int GLFW_KEY_ESCAPE
    int GLFW_KEY_ENTER
    int GLFW_KEY_TAB
    int GLFW_KEY_BACKSPACE
    int GLFW_KEY_INSERT
    int GLFW_KEY_DELETE
    int GLFW_KEY_RIGHT
    int GLFW_KEY_LEFT
    int GLFW_KEY_DOWN
    int GLFW_KEY_UP
    int GLFW_KEY_PAGE_UP
    int GLFW_KEY_PAGE_DOWN
    int GLFW_KEY_HOME
    int GLFW_KEY_END
    int GLFW_KEY_CAPS_LOCK
    int GLFW_KEY_SCROLL_LOCK
    int GLFW_KEY_NUM_LOCK
    int GLFW_KEY_PRINT_SCREEN
    int GLFW_KEY_PAUSE
    int GLFW_KEY_F1
    int GLFW_KEY_F2
    int GLFW_KEY_F3
    int GLFW_KEY_F4
    int GLFW_KEY_F5
    int GLFW_KEY_F6
    int GLFW_KEY_F7
    int GLFW_KEY_F8
    int GLFW_KEY_F9
    int GLFW_KEY_F10
    int GLFW_KEY_F11
    int GLFW_KEY_F12
    int GLFW_KEY_F13
    int GLFW_KEY_F14
    int GLFW_KEY_F15
    int GLFW_KEY_F16
    int GLFW_KEY_F17
    int GLFW_KEY_F18
    int GLFW_KEY_F19
    int GLFW_KEY_F20
    int GLFW_KEY_F21
    int GLFW_KEY_F22
    int GLFW_KEY_F23
    int GLFW_KEY_F24
    int GLFW_KEY_F25
    int GLFW_KEY_KP_0
    int GLFW_KEY_KP_1
    int GLFW_KEY_KP_2
    int GLFW_KEY_KP_3
    int GLFW_KEY_KP_4
    int GLFW_KEY_KP_5
    int GLFW_KEY_KP_6
    int GLFW_KEY_KP_7
    int GLFW_KEY_KP_8
    int GLFW_KEY_KP_9
    int GLFW_KEY_KP_DECIMAL
    int GLFW_KEY_KP_DIVIDE
    int GLFW_KEY_KP_MULTIPLY
    int GLFW_KEY_KP_SUBTRACT
    int GLFW_KEY_KP_ADD
    int GLFW_KEY_KP_ENTER
    int GLFW_KEY_KP_EQUAL
    int GLFW_KEY_LEFT_SHIFT
    int GLFW_KEY_LEFT_CONTROL
    int GLFW_KEY_LEFT_ALT
    int GLFW_KEY_LEFT_SUPER
    int GLFW_KEY_RIGHT_SHIFT
    int GLFW_KEY_RIGHT_CONTROL
    int GLFW_KEY_RIGHT_ALT
    int GLFW_KEY_RIGHT_SUPER
    int GLFW_KEY_MENU
    int GLFW_KEY_LAST
    int GLFW_MOD_SHIFT
    int GLFW_MOD_CONTROL
    int GLFW_MOD_ALT
    int GLFW_MOD_SUPER
    int GLFW_MOD_CAPS_LOCK
    int GLFW_MOD_NUM_LOCK
    int GLFW_MOUSE_BUTTON_1
    int GLFW_MOUSE_BUTTON_2
    int GLFW_MOUSE_BUTTON_3
    int GLFW_MOUSE_BUTTON_4
    int GLFW_MOUSE_BUTTON_5
    int GLFW_MOUSE_BUTTON_6
    int GLFW_MOUSE_BUTTON_7
    int GLFW_MOUSE_BUTTON_8
    int GLFW_MOUSE_BUTTON_LAST
    int GLFW_MOUSE_BUTTON_LEFT
    int GLFW_MOUSE_BUTTON_RIGHT
    int GLFW_MOUSE_BUTTON_MIDDLE
    int GLFW_JOYSTICK_1
    int GLFW_JOYSTICK_2
    int GLFW_JOYSTICK_3
    int GLFW_JOYSTICK_4
    int GLFW_JOYSTICK_5
    int GLFW_JOYSTICK_6
    int GLFW_JOYSTICK_7
    int GLFW_JOYSTICK_8
    int GLFW_JOYSTICK_9
    int GLFW_JOYSTICK_10
    int GLFW_JOYSTICK_11
    int GLFW_JOYSTICK_12
    int GLFW_JOYSTICK_13
    int GLFW_JOYSTICK_14
    int GLFW_JOYSTICK_15
    int GLFW_JOYSTICK_16
    int GLFW_JOYSTICK_LAST
    int GLFW_GAMEPAD_BUTTON_A
    int GLFW_GAMEPAD_BUTTON_B
    int GLFW_GAMEPAD_BUTTON_X
    int GLFW_GAMEPAD_BUTTON_Y
    int GLFW_GAMEPAD_BUTTON_LEFT_BUMPER
    int GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER
    int GLFW_GAMEPAD_BUTTON_BACK
    int GLFW_GAMEPAD_BUTTON_START
    int GLFW_GAMEPAD_BUTTON_GUIDE
    int GLFW_GAMEPAD_BUTTON_LEFT_THUMB
    int GLFW_GAMEPAD_BUTTON_RIGHT_THUMB
    int GLFW_GAMEPAD_BUTTON_DPAD_UP
    int GLFW_GAMEPAD_BUTTON_DPAD_RIGHT
    int GLFW_GAMEPAD_BUTTON_DPAD_DOWN
    int GLFW_GAMEPAD_BUTTON_DPAD_LEFT
    int GLFW_GAMEPAD_BUTTON_LAST
    int GLFW_GAMEPAD_BUTTON_CROSS
    int GLFW_GAMEPAD_BUTTON_CIRCLE
    int GLFW_GAMEPAD_BUTTON_SQUARE
    int GLFW_GAMEPAD_BUTTON_TRIANGLE
    int GLFW_GAMEPAD_AXIS_LEFT_X
    int GLFW_GAMEPAD_AXIS_LEFT_Y
    int GLFW_GAMEPAD_AXIS_RIGHT_X
    int GLFW_GAMEPAD_AXIS_RIGHT_Y
    int GLFW_GAMEPAD_AXIS_LEFT_TRIGGER
    int GLFW_GAMEPAD_AXIS_RIGHT_TRIGGER
    int GLFW_GAMEPAD_AXIS_LAST
    int GLFW_NO_ERROR
    int GLFW_NOT_INITIALIZED
    int GLFW_NO_CURRENT_CONTEXT
    int GLFW_INVALID_ENUM
    int GLFW_INVALID_VALUE
    int GLFW_OUT_OF_MEMORY
    int GLFW_API_UNAVAILABLE
    int GLFW_VERSION_UNAVAILABLE
    int GLFW_PLATFORM_ERROR
    int GLFW_FORMAT_UNAVAILABLE
    int GLFW_NO_WINDOW_CONTEXT
    int GLFW_FOCUSED
    int GLFW_ICONIFIED
    int GLFW_RESIZABLE
    int GLFW_VISIBLE
    int GLFW_DECORATED
    int GLFW_AUTO_ICONIFY
    int GLFW_FLOATING
    int GLFW_MAXIMIZED
    int GLFW_CENTER_CURSOR
    int GLFW_TRANSPARENT_FRAMEBUFFER
    int GLFW_HOVERED
    int GLFW_FOCUS_ON_SHOW
    int GLFW_RED_BITS
    int GLFW_GREEN_BITS
    int GLFW_BLUE_BITS
    int GLFW_ALPHA_BITS
    int GLFW_DEPTH_BITS
    int GLFW_STENCIL_BITS
    int GLFW_ACCUM_RED_BITS
    int GLFW_ACCUM_GREEN_BITS
    int GLFW_ACCUM_BLUE_BITS
    int GLFW_ACCUM_ALPHA_BITS
    int GLFW_AUX_BUFFERS
    int GLFW_STEREO
    int GLFW_SAMPLES
    int GLFW_SRGB_CAPABLE
    int GLFW_REFRESH_RATE
    int GLFW_DOUBLEBUFFER
    int GLFW_CLIENT_API
    int GLFW_CONTEXT_VERSION_MAJOR
    int GLFW_CONTEXT_VERSION_MINOR
    int GLFW_CONTEXT_REVISION
    int GLFW_CONTEXT_ROBUSTNESS
    int GLFW_OPENGL_FORWARD_COMPAT
    int GLFW_OPENGL_DEBUG_CONTEXT
    int GLFW_OPENGL_PROFILE
    int GLFW_CONTEXT_RELEASE_BEHAVIOR
    int GLFW_CONTEXT_NO_ERROR
    int GLFW_CONTEXT_CREATION_API
    int GLFW_SCALE_TO_MONITOR
    int GLFW_COCOA_RETINA_FRAMEBUFFER
    int GLFW_COCOA_FRAME_NAME
    int GLFW_COCOA_GRAPHICS_SWITCHING
    int GLFW_X11_CLASS_NAME
    int GLFW_X11_INSTANCE_NAME
    int GLFW_NO_API
    int GLFW_OPENGL_API
    int GLFW_OPENGL_ES_API
    int GLFW_NO_ROBUSTNESS
    int GLFW_NO_RESET_NOTIFICATION
    int GLFW_LOSE_CONTEXT_ON_RESET
    int GLFW_OPENGL_ANY_PROFILE
    int GLFW_OPENGL_CORE_PROFILE
    int GLFW_OPENGL_COMPAT_PROFILE
    int GLFW_CURSOR
    int GLFW_STICKY_KEYS
    int GLFW_STICKY_MOUSE_BUTTONS
    int GLFW_LOCK_KEY_MODS
    int GLFW_RAW_MOUSE_MOTION
    int GLFW_CURSOR_NORMAL
    int GLFW_CURSOR_HIDDEN
    int GLFW_CURSOR_DISABLED
    int GLFW_ANY_RELEASE_BEHAVIOR
    int GLFW_RELEASE_BEHAVIOR_FLUSH
    int GLFW_RELEASE_BEHAVIOR_NONE
    int GLFW_NATIVE_CONTEXT_API
    int GLFW_EGL_CONTEXT_API
    int GLFW_OSMESA_CONTEXT_API
    int GLFW_ARROW_CURSOR
    int GLFW_IBEAM_CURSOR
    int GLFW_CROSSHAIR_CURSOR
    int GLFW_HAND_CURSOR
    int GLFW_HRESIZE_CURSOR
    int GLFW_VRESIZE_CURSOR
    int GLFW_CONNECTED
    int GLFW_DISCONNECTED
    int GLFW_JOYSTICK_HAT_BUTTONS
    int GLFW_COCOA_CHDIR_RESOURCES
    int GLFW_COCOA_MENUBAR
    int GLFW_DONT_CARE
