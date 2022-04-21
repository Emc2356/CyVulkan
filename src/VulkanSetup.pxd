#cython: language_level=3

from utils cimport *

# C libraries
from CyGlfw cimport *
from CyVulkan cimport *

# libc
from libc.stdint cimport int8_t, int16_t, int32_t, int64_t, uint8_t, uint16_t, uint32_t, uint64_t
from libc.stdio cimport *
from libc.stdlib cimport *
from libc.string cimport *

# libcpp
from libcpp.vector cimport vector


cdef struct VulkanHandle:
    bint enable_validation_layers

    vector[char *] validation_layers
    vector[char *] additional_extensions
    vector[char *] device_extensions

    VkInstance instance
    VkDebugUtilsMessengerEXT debug_messenger
    PFN_vkDebugUtilsMessengerCallbackEXT debug_callback
    VkSurfaceKHR surface

    VkPhysicalDevice physical_device
    VkDevice device

    VkQueue graphics_queue
    VkQueue present_queue


cdef struct QueueFamilyIndices:
    optional[uint32_t] graphics_family
    optional[uint32_t] present_family


cdef vector[char*] get_required_extensions(bint enable_validation_layers)
cdef bint check_validation_layer_support(VulkanHandle& handle)
cdef void initialize_instance(char* app_name, VulkanHandle& handle)
cdef VkResult CreateDebugUtilsMessengerEXT(VkInstance instance, const VkDebugUtilsMessengerCreateInfoEXT* pCreateInfo, const VkAllocationCallbacks* pAllocator, VkDebugUtilsMessengerEXT* pDebugMessenger)
cdef void DestroyDebugUtilsMessengerEXT(VkInstance instance, VkDebugUtilsMessengerEXT debugMessenger, const VkAllocationCallbacks* pAllocator)
cdef void setupDebugMessenger(VulkanHandle& handle)
cdef void create_surface(VulkanHandle& handle, GLFWwindow* window)
cdef QueueFamilyIndices find_queue_families(VulkanHandle& handle, VkPhysicalDevice& device)
cdef bint check_device_extension_support(vector[char*]& device_extensions, VkPhysicalDevice& device)
cdef bint is_device_suitable(VulkanHandle& handle, VkPhysicalDevice& device)
cdef VkPhysicalDevice pick_physical_device(VulkanHandle& handle)
cdef VkDevice create_logical_device(VulkanHandle& handle)
