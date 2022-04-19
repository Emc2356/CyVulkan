#cython: language_level=3

include "VulkanSetup.pyx"
include "PhysicalDevice.pyx"

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


# TODO: not cross platform as in linux __stdcall isn't used in vulkan
cdef VkBool32 __stdcall debugCallback(
        VkDebugUtilsMessageSeverityFlagBitsEXT messageSeverity,
        VkDebugUtilsMessageTypeFlagsEXT messageType,
        const VkDebugUtilsMessengerCallbackDataEXT* pCallbackData,
        void* pUserData
) nogil:
    fprintf(stderr, "validation layer: %s\n", pCallbackData.pMessage)
    return VK_FALSE


cdef GLFWwindow* create_window(int width, int height, char* windowName):
    glfwInit()

    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API)
    glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE)

    return glfwCreateWindow(width, height, windowName, NULL, NULL)


cdef struct VulkanHandle:
    VkInstance instance
    VkDebugUtilsMessengerEXT debug_messenger
    VkSurfaceKHR surface

    VkPhysicalDevice physical_device
    VkDevice device

    VkQueue graphics_queue
    VkQueue present_queue


cdef void cleanupVulkanHandle(VulkanHandle& handle):
    if enable_validation_layers:
        DestroyDebugUtilsMessengerEXT(handle.instance, handle.debug_messenger, NULL)

    vkDestroySurfaceKHR(handle.instance, handle.surface, NULL)
    vkDestroyDevice(handle.device, NULL)
    vkDestroyInstance(handle.instance, NULL)


cdef void run():
    cdef GLFWwindow* window = create_window(WIDTH, HEIGHT, "Vulkan App")
    cdef VulkanHandle handle
    memset(&handle, 0, sizeof(handle))

    handle.instance = create_instance("Vulkan App", &additional_extensions, &validation_layers, <PFN_vkDebugUtilsMessengerCallbackEXT> debugCallback)
    setupDebugMessenger(enable_validation_layers, &handle.instance, &handle.debug_messenger, <PFN_vkDebugUtilsMessengerCallbackEXT> debugCallback)
    create_surface(&handle.instance, window, &handle.surface)
    handle.physical_device = pick_physical_device(&handle.instance, &handle.surface)
    handle.device = create_logical_device(&handle.physical_device, &handle.surface, &handle.graphics_queue, &handle.present_queue)

    while not glfwWindowShouldClose(window):
        glfwPollEvents()

    cleanupVulkanHandle(handle)
    glfwDestroyWindow(window)
    glfwTerminate()


def main():
    run()
