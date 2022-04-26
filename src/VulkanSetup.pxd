#cython: language_level=3

from utils cimport *

# C libraries
from CyGlfw cimport *
from CyVulkan cimport *

# libc
from libc.stdint cimport uint32_t

# libcpp
from libcpp.vector cimport vector
from libcpp.string cimport string as CPPString


cdef extern from "VulkanSetup.hpp" nogil:
    cdef cppclass VulkanHandle:
        char* app_name

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

        VkSwapchainKHR swapchain
        vector[VkImage] swapchain_images
        vector[VkImageView] swapchain_image_views
        VkFormat swapchain_image_format
        VkExtent2D swapchain_extent
        vector[VkFramebuffer] swapchain_frame_buffers

        VkPipelineLayout pipeline_layout

        VkRenderPass render_pass
        VkPipeline graphics_pipeline

        VkCommandPool command_pool
        VkCommandBuffer command_buffer

        VkSemaphore image_available_semaphore;
        VkSemaphore render_finished_semaphore;
        VkFence in_flight_fence;

        void destroy()

    cdef vector[char] read_file(const CPPString& filename)
    cdef void cleanupVulkanHandle(VulkanHandle& handle)
    cdef void initialize_instance(VulkanHandle& handle)
    cdef void setup_debug_messenger(VulkanHandle& handle)
    cdef void create_surface(VulkanHandle& handle, GLFWwindow* window)
    cdef void pick_physical_device(VulkanHandle& handle)
    cdef void create_logical_device(VulkanHandle& handle)
    cdef void create_swap_chain(VulkanHandle& handle, GLFWwindow* window)
    cdef void create_image_views(VulkanHandle& handle)
    cdef void create_graphics_pipeline(VulkanHandle& handle, vector[char]& fragment_shader_code, vector[char]& vertex_shader_code)
    cdef void create_render_pass(VulkanHandle& handle)
    cdef void create_frame_buffers(VulkanHandle& handle)
    cdef void create_command_pool(VulkanHandle& handle)
    cdef void create_command_buffer(VulkanHandle& handle)
    cdef void draw_frame(VulkanHandle& handle, GLFWwindow* window)
    cdef void create_sync_objects(VulkanHandle& handle)
