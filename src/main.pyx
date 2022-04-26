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


cdef GLFWwindow* create_window(int width, int height, char* windowName) nogil:
    glfwInit()

    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API)
    glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE)

    return glfwCreateWindow(width, height, windowName, NULL, NULL)


cdef void run() nogil:
    cdef GLFWwindow* window = create_window(WIDTH, HEIGHT, "Vulkan App")
    cdef VulkanHandle handle = ZeroInit[VulkanHandle]()

    handle.enable_validation_layers = enable_validation_layers
    handle.validation_layers = validation_layers
    handle.additional_extensions = additional_extensions
    handle.device_extensions = device_extensions
    handle.debug_callback = <PFN_vkDebugUtilsMessengerCallbackEXT> debugCallback
    handle.app_name = "Vulkan App"

    initialize_instance(handle)
    setup_debug_messenger(handle)
    create_surface(handle, window)
    pick_physical_device(handle)
    create_logical_device(handle)
    create_swap_chain(handle, window)
    create_image_views(handle)
    create_render_pass(handle)
    create_graphics_pipeline(
        handle,
        read_file(<CPPString> <char*> b"src/shaders/shader.frag.spv"),
        read_file(<CPPString> <char*> b"src/shaders/shader.vert.spv"),
    )
    create_frame_buffers(handle)
    create_command_pool(handle)
    create_command_buffer(handle)
    create_sync_objects(handle)

    while not glfwWindowShouldClose(window):
        glfwPollEvents()
        draw_frame(handle, window)

    vkDeviceWaitIdle(handle.device)

    handle.destroy()
    glfwDestroyWindow(window)
    glfwTerminate()


def main():
    run()
