#cython: language_level=3

from VulkanSetup cimport *

# C libraries
from CyGlfw cimport *
from CyVulkan cimport *

# libc
from libc.stdint cimport int8_t, int16_t, int32_t, int64_t, uint8_t, uint16_t, uint32_t, uint64_t
from libc.stdio cimport *
from libc.stdlib cimport *
from libc.string cimport *

# C++ stl
from libcpp.vector cimport vector

DEF WIDTH = 800
DEF HEIGHT = 600

cdef bint enable_validation_layers = 1

cdef vector[char*] validation_layers = [b"VK_LAYER_KHRONOS_validation"]
cdef vector[char*] additional_extensions = [b"VK_KHR_win32_surface"]
# #define VK_KHR_SWAPCHAIN_EXTENSION_NAME VK_KHR_swapchain
cdef vector[char*] device_extensions = [b"VK_KHR_swapchain"]


# TODO: not cross platform as in linux __stdcall isn't used in vulkan
cdef VkBool32 __stdcall debugCallback(
        VkDebugUtilsMessageSeverityFlagBitsEXT messageSeverity,
        VkDebugUtilsMessageTypeFlagsEXT messageType,
        const VkDebugUtilsMessengerCallbackDataEXT* pCallbackData,
        void* pUserData
) nogil:
    fprintf(stderr, "validation layer: %s\n", pCallbackData.pMessage)
    return VK_FALSE


cdef GLFWwindow* create_window(int width, int height, char* windowName, GLFWframebuffersizefun frame_buffer_resize_callback, VulkanHandle* handle) nogil:
    glfwInit()

    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API)
    # glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE)
    glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE)

    cdef GLFWwindow* window = glfwCreateWindow(width, height, windowName, NULL, NULL)

    glfwSetWindowUserPointer(window, <void*> handle)
    glfwSetFramebufferSizeCallback(window, frame_buffer_resize_callback)

    return window


cdef void frame_buffer_resize_callback(GLFWwindow* window, int width, int height) nogil:
    cdef VulkanHandle* handle = <VulkanHandle*>glfwGetWindowUserPointer(window)
    handle.frame_buffer_resized = True


cdef void run() nogil:
    cdef VulkanHandle handle = ZeroInit[VulkanHandle]()
    cdef GLFWwindow* window = create_window(WIDTH, HEIGHT, "Vulkan App", <GLFWframebuffersizefun> frame_buffer_resize_callback, &handle)

    handle.window = window
    handle.enable_validation_layers = enable_validation_layers
    handle.validation_layers = validation_layers
    handle.additional_extensions = additional_extensions
    handle.device_extensions = device_extensions
    handle.debug_callback = <PFN_vkDebugUtilsMessengerCallbackEXT> debugCallback
    handle.app_name = "Vulkan App"
    handle.max_frames_in_flight = 2

    initialize_instance(handle)
    setup_debug_messenger(handle)
    create_surface(handle)
    pick_physical_device(handle)
    create_logical_device(handle)
    create_swapchain(handle)
    create_image_views(handle)
    create_render_pass(handle)
    create_graphics_pipeline(
        handle,
        read_file(<CPPString> <char*> b"src/shaders/shader.frag.spv"),
        read_file(<CPPString> <char*> b"src/shaders/shader.vert.spv"),
    )
    create_frame_buffers(handle)
    create_command_pool(handle)
    create_command_buffers(handle)
    create_sync_objects(handle)

    while not glfwWindowShouldClose(window):
        glfwPollEvents()
        draw_frame(handle)

    vkDeviceWaitIdle(handle.device)

    handle.destroy()
    glfwDestroyWindow(window)
    glfwTerminate()


def main():
    run()
