#ifndef _VULKAN_SETUP_H_
#define _VULKAN_SETUP_H_

#ifndef __cplusplus
#error C++ compiler needed
#endif

#include <optional>
#include <vector>
#include <set>
#include <string>
#include <iostream>
#include <fstream>
#include <cstdint>   // Necessary for uint32_t
#include <limits>    // Necessary for std::numeric_limits
#include <algorithm> // Necessary for std::clamp
#ifndef GLFW_INCLUDE_VULKAN
#define GLFW_INCLUDE_VULKAN
#endif // GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>
#include <vulkan/vulkan.h>
#include <string.h>

#define bint bool
#define streq(a, b) strcmp(a, b) == 0
#define CERROR(...)               \
    fprintf(stderr, "[ERROR] ");  \
    fprintf(stderr, __VA_ARGS__); \
    fputc('\n', stderr);          \
    exit(1)

typedef struct VulkanHandle {
    char *app_name;

    bool enable_validation_layers;

    std::vector<char *> validation_layers;
    std::vector<char *> additional_extensions;
    std::vector<char *> device_extensions;

    VkInstance instance;
    VkDebugUtilsMessengerEXT debug_messenger;
    PFN_vkDebugUtilsMessengerCallbackEXT debug_callback;
    VkSurfaceKHR surface;

    VkPhysicalDevice physical_device;
    VkDevice device;

    VkQueue graphics_queue;
    VkQueue present_queue;

    VkSwapchainKHR swapchain;
    std::vector<VkImage> swapchain_images;
    std::vector<VkImageView> swapchain_image_views;
    std::vector<VkFramebuffer> swapchain_frame_buffers;
    VkFormat swapchain_image_format;
    VkExtent2D swapchain_extent;

    VkPipelineLayout pipeline_layout;

    VkRenderPass render_pass;
    VkPipeline graphics_pipeline;

    VkCommandPool command_pool;
    VkCommandBuffer command_buffer;

    VkSemaphore image_available_semaphore;
    VkSemaphore render_finished_semaphore;
    VkFence in_flight_fence;

    void destroy();

} VulkanHandle;

typedef struct QueueFamilyIndices {
    std::optional<uint32_t> graphics_family;
    std::optional<uint32_t> present_family;

    bool iscomplete() {
        return graphics_family.has_value() && present_family.has_value();
    }
} QueueFamilyIndices;

typedef struct SwapChainSupportDetails {
    VkSurfaceCapabilitiesKHR capabilities;
    std::vector<VkSurfaceFormatKHR> formats;
    std::vector<VkPresentModeKHR> present_modes;
} SwapChainSupportDetails;

std::vector<char> read_file(const std::string &filename);
std::vector<char *> get_required_extensions(int enable_validation_layers);
bool check_validation_layer_support(VulkanHandle &handle);
VkResult CreateDebugUtilsMessengerEXT(VkInstance instance, const VkDebugUtilsMessengerCreateInfoEXT *pCreateInfo, const VkAllocationCallbacks *pAllocator, VkDebugUtilsMessengerEXT *pDebugMessenger);
void DestroyDebugUtilsMessengerEXT(VkInstance instance, VkDebugUtilsMessengerEXT debugMessenger, const VkAllocationCallbacks *pAllocator);
void initialize_instance(VulkanHandle &handle);
void setup_debug_messenger(VulkanHandle &handle);
void create_surface(VulkanHandle &handle, GLFWwindow *window);
QueueFamilyIndices find_queue_families(VulkanHandle &handle, VkPhysicalDevice &device);
bool check_device_extension_support(std::vector<char *> &device_extensions, VkPhysicalDevice &device);
bool is_device_suitable(VulkanHandle &handle, VkPhysicalDevice &device);
void pick_physical_device(VulkanHandle &handle);
void create_logical_device(VulkanHandle &handle);
SwapChainSupportDetails query_swap_chain_support(VulkanHandle &handle, VkPhysicalDevice &device);
VkSurfaceFormatKHR choose_swap_surface_format(const std::vector<VkSurfaceFormatKHR> &availableFormats);
VkPresentModeKHR choose_swap_present_mode(const std::vector<VkPresentModeKHR> &availablePresentModes);
VkExtent2D choose_swap_extent(const VkSurfaceCapabilitiesKHR &capabilities, GLFWwindow *window);
void create_swap_chain(VulkanHandle &handle, GLFWwindow *window);
void create_image_views(VulkanHandle &handle);
VkShaderModule create_shader_module(const std::vector<char> &code);
void create_render_pass(VulkanHandle &handle);
void create_graphics_pipeline(VulkanHandle &handle, std::vector<char> &fragment_shader_code, std::vector<char> &vertex_shader_code);
void create_frame_buffers(VulkanHandle &handle);
void create_command_pool(VulkanHandle &handle);
void create_command_buffer(VulkanHandle &handle);
void record_command_buffer(VulkanHandle &handle, VkCommandBuffer command_buffer, uint32_t image_index);
void draw_frame(VulkanHandle &handle, GLFWwindow *window);
void create_sync_objects(VulkanHandle &handle);

void VulkanHandle::destroy() {
    vkDestroySemaphore(device, image_available_semaphore, nullptr);
    vkDestroySemaphore(device, render_finished_semaphore, nullptr);
    vkDestroyFence(device, in_flight_fence, nullptr);
    vkDestroyCommandPool(device, command_pool, nullptr);
    for (auto &frame_buffer : swapchain_frame_buffers) {
        vkDestroyFramebuffer(device, frame_buffer, nullptr);
    }
    vkDestroyPipeline(device, graphics_pipeline, nullptr);
    vkDestroyPipelineLayout(device, pipeline_layout, nullptr);
    vkDestroyRenderPass(device, render_pass, nullptr);
    for (auto &image_view : swapchain_image_views) {
        vkDestroyImageView(device, image_view, nullptr);
    }
    if (enable_validation_layers) {
        DestroyDebugUtilsMessengerEXT(instance, debug_messenger, nullptr);
    }

    vkDestroySwapchainKHR(device, swapchain, nullptr);
    vkDestroySurfaceKHR(instance, surface, nullptr);
    vkDestroyDevice(device, nullptr);
    vkDestroyInstance(instance, nullptr);
}

std::vector<char> read_file(const std::string &filename) {
    std::ifstream file(filename, std::ios::ate | std::ios::binary);

    if (!file.is_open()) {
        CERROR("failed to open file!");
    }

    size_t fileSize = (size_t)file.tellg();
    std::vector<char> buffer(fileSize);

    file.seekg(0);
    file.read(buffer.data(), fileSize);

    file.close();

    return buffer;
}

std::vector<char *> get_required_extensions(int enable_validation_layers) {
    uint32_t glfw_extension_count = 0;
    char** glfw_extensions = (char**)glfwGetRequiredInstanceExtensions(&glfw_extension_count);

    std::vector<char *> extensions(glfw_extension_count, glfw_extensions[0]);

    if (enable_validation_layers) {
        extensions.push_back(VK_EXT_DEBUG_UTILS_EXTENSION_NAME);
    }

    return extensions;
}

bool check_validation_layer_support(VulkanHandle &handle) {
    uint32_t layer_count;
    vkEnumerateInstanceLayerProperties(&layer_count, nullptr);

    std::vector<VkLayerProperties> available_layers(layer_count);
    vkEnumerateInstanceLayerProperties(&layer_count, available_layers.data());

    for (const auto &layer_name : handle.validation_layers) {
        bool found = false;
        for (const auto &layer_properties : available_layers) {
            if (streq(layer_name, layer_properties.layerName)) {
                found = true;
                break;
            }
        }
        if (!found) {
            return false;
        }
    }

    return true;
}

VkResult CreateDebugUtilsMessengerEXT(VkInstance instance, const VkDebugUtilsMessengerCreateInfoEXT *pCreateInfo, const VkAllocationCallbacks *pAllocator, VkDebugUtilsMessengerEXT *pDebugMessenger) {
    PFN_vkCreateDebugUtilsMessengerEXT func = (PFN_vkCreateDebugUtilsMessengerEXT)vkGetInstanceProcAddr(instance, "vkCreateDebugUtilsMessengerEXT");
    if (func != nullptr) {
        return func(instance, pCreateInfo, pAllocator, pDebugMessenger);
    }
    else {
        return VK_ERROR_EXTENSION_NOT_PRESENT;
    }
}

void DestroyDebugUtilsMessengerEXT(VkInstance instance, VkDebugUtilsMessengerEXT debugMessenger, const VkAllocationCallbacks *pAllocator) {
    PFN_vkDestroyDebugUtilsMessengerEXT func = (PFN_vkDestroyDebugUtilsMessengerEXT)vkGetInstanceProcAddr(instance, "vkDestroyDebugUtilsMessengerEXT");
    if (func != nullptr) {
        func(instance, debugMessenger, pAllocator);
    }
}

void initialize_instance(VulkanHandle &handle) {
    bool enable_validation_layers = handle.enable_validation_layers;

    if (enable_validation_layers && !check_validation_layer_support(handle)) {
        CERROR("validation layers requested, but not available!");
    }

    VkApplicationInfo appInfo{};
    VkInstanceCreateInfo createInfo{};
    VkDebugUtilsMessengerCreateInfoEXT debugCreateInfo{};

    appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    appInfo.pApplicationName = handle.app_name;
    appInfo.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.pEngineName = "No Engine";
    appInfo.engineVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.apiVersion = VK_API_VERSION_1_0;

    createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    createInfo.pApplicationInfo = &appInfo;

    std::vector<char *> extensions(get_required_extensions(enable_validation_layers));
    std::vector<char *> extensions_diff;
    if (!handle.additional_extensions.empty()) {
        for (char *extension : extensions) {
            bool found = false;
            char *additional_extension;
            for (int i = 0; i < handle.additional_extensions.size(); i++) {
                additional_extension = handle.additional_extensions[i];
                if (streq(extension, additional_extension)) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                extensions_diff.push_back(additional_extension);
            }
            for (char *extension : extensions_diff) {
                extensions.push_back(extension);
            }
        }
    }

    createInfo.enabledExtensionCount = (uint32_t)extensions.size();
    createInfo.ppEnabledExtensionNames = extensions.data();

    if (enable_validation_layers) {
        createInfo.enabledLayerCount = (uint32_t)handle.validation_layers.size();
        createInfo.ppEnabledLayerNames = handle.validation_layers.data();

        debugCreateInfo.sType = VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;
        debugCreateInfo.flags = 0;
        debugCreateInfo.messageSeverity = VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT;
        debugCreateInfo.messageType = VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT;
        debugCreateInfo.pfnUserCallback = handle.debug_callback;

        createInfo.pNext = (VkDebugUtilsMessengerCreateInfoEXT *)&debugCreateInfo;
    }
    else {
        createInfo.enabledLayerCount = 0;
        createInfo.pNext = nullptr;
    }

    if (vkCreateInstance(&createInfo, nullptr, &handle.instance) != VK_SUCCESS) {
        CERROR("failed to create instance!");
    }
}

void setup_debug_messenger(VulkanHandle &handle) {
    if (!handle.enable_validation_layers) {
        return;
    }

    VkDebugUtilsMessengerCreateInfoEXT createInfo{};

    createInfo.sType = VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;
    createInfo.messageSeverity = VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT;
    createInfo.messageType = VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT;
    createInfo.pfnUserCallback = handle.debug_callback 

    if (CreateDebugUtilsMessengerEXT(handle.instance, &createInfo, nullptr, &handle.debug_messenger) != VK_SUCCESS) {
        CERROR("failed to set up debug messenger!");
    }
}

void create_surface(VulkanHandle &handle, GLFWwindow *window) {
    if (glfwCreateWindowSurface(handle.instance, window, nullptr, &handle.surface) != VK_SUCCESS) {
        CERROR("failed to create window surface!");
    }
}

QueueFamilyIndices find_queue_families(VulkanHandle &handle, VkPhysicalDevice &device) { 
    QueueFamilyIndices indices{};

    uint32_t queue_family_count = 0;
    vkGetPhysicalDeviceQueueFamilyProperties(device, &queue_family_count, nullptr);

    std::vector<VkQueueFamilyProperties> queue_families(queue_family_count);
    vkGetPhysicalDeviceQueueFamilyProperties(device, &queue_family_count, queue_families.data());

    for (int i = 0; i < queue_families.size(); i++) {
        VkBool32 present_support = VK_FALSE;
        vkGetPhysicalDeviceSurfaceSupportKHR(device, i, handle.surface, &present_support);
        if (present_support) {
            indices.present_family = i;
        }
        if (queue_families[i].queueFlags & VK_QUEUE_GRAPHICS_BIT) {
            indices.graphics_family = i;
            break;
        }
    }

    return indices;
}

bool check_device_extension_support(std::vector<char *> &device_extensions, VkPhysicalDevice &device) {
    uint32_t extension_count;
    vkEnumerateDeviceExtensionProperties(device, nullptr, &extension_count, nullptr);

    std::vector<VkExtensionProperties> available_extensions(extension_count);
    vkEnumerateDeviceExtensionProperties(device, nullptr, &extension_count, available_extensions.data());

    std::set<std::string> required_extensions(device_extensions.begin(), device_extensions.end());

    for (const auto &extension : available_extensions) {
        required_extensions.erase(extension.extensionName);
    }
    return required_extensions.empty();
}

bool is_device_suitable(VulkanHandle &handle, VkPhysicalDevice &device) {
    QueueFamilyIndices indices = find_queue_families(handle, device);
    bool extensions_supported = check_device_extension_support(handle.device_extensions, device);

    bool swap_chain_adequate = false;
    if (extensions_supported) {
        SwapChainSupportDetails swapChainSupport = query_swap_chain_support(handle, device);
        swap_chain_adequate = !swapChainSupport.formats.empty() && !swapChainSupport.present_modes.empty();
    }

    return indices.iscomplete() && extensions_supported && swap_chain_adequate;
}

void pick_physical_device(VulkanHandle &handle) {
    uint32_t device_count = 0;

    vkEnumeratePhysicalDevices(handle.instance, &device_count, nullptr);

    if (device_count == 0) {
        CERROR("failed to find GPUs with Vulkan support!");
    }

    std::vector<VkPhysicalDevice> devices(device_count);
    vkEnumeratePhysicalDevices(handle.instance, &device_count, devices.data());

    handle.physical_device = VK_NULL_HANDLE;
    for (VkPhysicalDevice &device : devices) {
        if (is_device_suitable(handle, device)) {
            handle.physical_device = device;
            break;
        }
    }
    if (handle.physical_device == VK_NULL_HANDLE) {
        CERROR("failed to find a suitable GPU!");
    }
}

void create_logical_device(VulkanHandle &handle) {
    QueueFamilyIndices indices = find_queue_families(handle, handle.physical_device);

    std::vector<VkDeviceQueueCreateInfo> queue_create_infos;
    std::set<uint32_t> unique_queue_families = {indices.graphics_family.value(), indices.present_family.value()};
    float queue_priority = 1.0;
    VkDeviceQueueCreateInfo queue_create_info;

    for (uint32_t queue_family : unique_queue_families) {
        memset(&queue_create_info, 0, sizeof(VkDeviceQueueCreateInfo));
        queue_create_info.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
        queue_create_info.queueFamilyIndex = queue_family;
        queue_create_info.queueCount = 1;
        queue_create_info.pQueuePriorities = &queue_priority;
        queue_create_infos.push_back(queue_create_info);
    }

    VkPhysicalDeviceFeatures device_features{};
    VkDeviceCreateInfo create_info{};
    queue_priority = 1.0;
    memset(&queue_create_info, 0, sizeof(VkDeviceQueueCreateInfo));

    queue_create_info.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
    queue_create_info.queueFamilyIndex = indices.graphics_family.value();
    queue_create_info.queueCount = 1;
    queue_create_info.pQueuePriorities = &queue_priority;

    create_info.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
    create_info.queueCreateInfoCount = 1;
    create_info.pQueueCreateInfos = &queue_create_info;
    create_info.pEnabledFeatures = &device_features;

    create_info.enabledExtensionCount = (uint32_t)handle.device_extensions.size();
    create_info.ppEnabledExtensionNames = handle.device_extensions.data();

    create_info.queueCreateInfoCount = (uint32_t)queue_create_infos.size();
    create_info.pQueueCreateInfos = queue_create_infos.data();

    if (handle.enable_validation_layers) {
        create_info.enabledLayerCount = (uint32_t)handle.validation_layers.size();
        create_info.ppEnabledLayerNames = handle.validation_layers.data();
    }
    else {
        create_info.enabledLayerCount = 0;
    }

    if (vkCreateDevice(handle.physical_device, &create_info, nullptr, &handle.device) != VK_SUCCESS) {
        CERROR("failed to create logical device!");
    }

    vkGetDeviceQueue(handle.device, indices.graphics_family.value(), 0, &handle.graphics_queue);
    vkGetDeviceQueue(handle.device, indices.present_family.value(), 0, &handle.present_queue);
}

SwapChainSupportDetails query_swap_chain_support(VulkanHandle &handle, VkPhysicalDevice &device) {
    SwapChainSupportDetails details{};

    vkGetPhysicalDeviceSurfaceCapabilitiesKHR(device, handle.surface, &details.capabilities);

    uint32_t format_count;
    vkGetPhysicalDeviceSurfaceFormatsKHR(device, handle.surface, &format_count, nullptr);

    if (format_count != 0) {
        details.formats.resize(format_count);
        vkGetPhysicalDeviceSurfaceFormatsKHR(device, handle.surface, &format_count, details.formats.data());
    }

    uint32_t present_mode_count;
    vkGetPhysicalDeviceSurfacePresentModesKHR(device, handle.surface, &present_mode_count, nullptr);

    if (present_mode_count != 0) {
        details.present_modes.resize(present_mode_count);
        vkGetPhysicalDeviceSurfacePresentModesKHR(device, handle.surface, &present_mode_count, details.present_modes.data());
    }

    return details;
}

VkSurfaceFormatKHR choose_swap_surface_format(const std::vector<VkSurfaceFormatKHR> &available_formats) {
    for (const auto &availableFormat : available_formats) {
        if (availableFormat.format == VK_FORMAT_B8G8R8A8_SRGB && availableFormat.colorSpace == VK_COLOR_SPACE_SRGB_NONLINEAR_KHR) {
            return availableFormat;
        }
    }

    return available_formats[0];
}

VkPresentModeKHR choose_swap_present_mode(const std::vector<VkPresentModeKHR> &available_present_modes) {
    for (const VkPresentModeKHR &available_present_mode : available_present_modes) {
        if (available_present_mode == VK_PRESENT_MODE_MAILBOX_KHR) {
            return available_present_mode;
        }
    }

    return VK_PRESENT_MODE_FIFO_KHR;
}

VkExtent2D choose_swap_extent(const VkSurfaceCapabilitiesKHR &capabilities, GLFWwindow *window) {
    if (capabilities.currentExtent.width != std::numeric_limits<uint32_t>::max()) {
        return capabilities.currentExtent;
    }
    else {
        int width, height;
        glfwGetFramebufferSize(window, &width, &height);

        VkExtent2D actualExtent = {
            static_cast<uint32_t>(width),
            static_cast<uint32_t>(height)
        };

        actualExtent.width = std::clamp(actualExtent.width, capabilities.minImageExtent.width, capabilities.maxImageExtent.width);
        actualExtent.height = std::clamp(actualExtent.height, capabilities.minImageExtent.height, capabilities.maxImageExtent.height);

        return actualExtent;
    }
}

void create_swap_chain(VulkanHandle &handle, GLFWwindow *window) {
    SwapChainSupportDetails swap_chain_support = query_swap_chain_support(handle, handle.physical_device);

    VkSurfaceFormatKHR surface_format = choose_swap_surface_format(swap_chain_support.formats);
    VkPresentModeKHR present_mode = choose_swap_present_mode(swap_chain_support.present_modes);
    VkExtent2D extent = choose_swap_extent(swap_chain_support.capabilities, window);

    uint32_t image_count = swap_chain_support.capabilities.minImageCount + 1;

    if (swap_chain_support.capabilities.maxImageCount > 0 && image_count > swap_chain_support.capabilities.maxImageCount) {
        image_count = swap_chain_support.capabilities.maxImageCount;
    }

    VkSwapchainCreateInfoKHR createInfo{};

    createInfo.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;
    createInfo.surface = handle.surface;
    createInfo.minImageCount = image_count;
    createInfo.imageFormat = surface_format.format;
    createInfo.imageColorSpace = surface_format.colorSpace;
    createInfo.imageExtent = extent;
    createInfo.imageArrayLayers = 1;
    createInfo.imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;

    QueueFamilyIndices indices = find_queue_families(handle, handle.physical_device);
    uint32_t queue_family_indices[] = {indices.graphics_family.value(), indices.present_family.value()};

    if (indices.graphics_family != indices.present_family) {
        createInfo.imageSharingMode = VK_SHARING_MODE_CONCURRENT;
        createInfo.queueFamilyIndexCount = 2;
        createInfo.pQueueFamilyIndices = queue_family_indices;
    }
    else {
        createInfo.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE;
        createInfo.queueFamilyIndexCount = 0;     // Optional
        createInfo.pQueueFamilyIndices = nullptr; // Optional
    }

    createInfo.preTransform = swap_chain_support.capabilities.currentTransform;
    createInfo.compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
    createInfo.presentMode = present_mode;
    createInfo.clipped = VK_TRUE;
    createInfo.oldSwapchain = VK_NULL_HANDLE;

    if (vkCreateSwapchainKHR(handle.device, &createInfo, nullptr, &handle.swapchain) != VK_SUCCESS) {
        CERROR("failed to create swap chain!");
    }

    vkGetSwapchainImagesKHR(handle.device, handle.swapchain, &image_count, nullptr);
    handle.swapchain_images.resize(image_count);
    vkGetSwapchainImagesKHR(handle.device, handle.swapchain, &image_count, handle.swapchain_images.data());

    handle.swapchain_image_format = surface_format.format;
    handle.swapchain_extent = extent;
}

void create_image_views(VulkanHandle &handle) {
    handle.swapchain_image_views.resize(handle.swapchain_images.size());

    for (size_t i = 0; i < handle.swapchain_images.size(); i++) {
        VkImageViewCreateInfo createInfo{};
        createInfo.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
        createInfo.image = handle.swapchain_images[i];
        createInfo.viewType = VK_IMAGE_VIEW_TYPE_2D;
        createInfo.format = handle.swapchain_image_format;
        createInfo.components.r = VK_COMPONENT_SWIZZLE_IDENTITY;
        createInfo.components.g = VK_COMPONENT_SWIZZLE_IDENTITY;
        createInfo.components.b = VK_COMPONENT_SWIZZLE_IDENTITY;
        createInfo.components.a = VK_COMPONENT_SWIZZLE_IDENTITY;
        createInfo.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
        createInfo.subresourceRange.baseMipLevel = 0;
        createInfo.subresourceRange.levelCount = 1;
        createInfo.subresourceRange.baseArrayLayer = 0;
        createInfo.subresourceRange.layerCount = 1;

        if (vkCreateImageView(handle.device, &createInfo, nullptr, &handle.swapchain_image_views[i]) != VK_SUCCESS) {
            CERROR("failed to create image views!");
        }
    }
}

VkShaderModule create_shader_module(VulkanHandle &handle, const std::vector<char> &code) {
    VkShaderModuleCreateInfo createInfo{};
    createInfo.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
    createInfo.codeSize = code.size();
    createInfo.pCode = reinterpret_cast<const uint32_t *>(code.data());

    VkShaderModule shader_module;
    if (vkCreateShaderModule(handle.device, &createInfo, nullptr, &shader_module) != VK_SUCCESS) {
        CERROR("failed to create shader module!");
    }
    return shader_module;
}

void create_render_pass(VulkanHandle &handle) {
    VkAttachmentDescription colorAttachment{};
    colorAttachment.format = handle.swapchain_image_format;
    colorAttachment.samples = VK_SAMPLE_COUNT_1_BIT;
    colorAttachment.loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;
    colorAttachment.storeOp = VK_ATTACHMENT_STORE_OP_STORE;
    colorAttachment.stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE;
    colorAttachment.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
    colorAttachment.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;
    colorAttachment.finalLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;

    VkAttachmentReference colorAttachmentRef{};
    colorAttachmentRef.attachment = 0;
    colorAttachmentRef.layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;

    VkSubpassDescription subpass{};
    subpass.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS;
    subpass.colorAttachmentCount = 1;
    subpass.pColorAttachments = &colorAttachmentRef;

    VkSubpassDependency dependency{};
    dependency.srcSubpass = VK_SUBPASS_EXTERNAL;
    dependency.dstSubpass = 0;
    dependency.srcStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
    dependency.srcAccessMask = 0;
    dependency.dstStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
    dependency.dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;

    VkRenderPassCreateInfo renderPassInfo{};
    renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
    renderPassInfo.attachmentCount = 1;
    renderPassInfo.pAttachments = &colorAttachment;
    renderPassInfo.subpassCount = 1;
    renderPassInfo.pSubpasses = &subpass;
    renderPassInfo.dependencyCount = 1;
    renderPassInfo.pDependencies = &dependency;

    if (vkCreateRenderPass(handle.device, &renderPassInfo, nullptr, &handle.render_pass) != VK_SUCCESS) {
        CERROR("failed to create render pass!");
    }
}

/* #region create_graphics_pipeline  */
void create_graphics_pipeline(VulkanHandle &handle, std::vector<char> &fragment_shader_code, std::vector<char> &vertex_shader_code) {
    std::vector<char> &vert_shader_code = vertex_shader_code;
    std::vector<char> &frag_shader_code = fragment_shader_code;

    VkShaderModule shader_module_vert = create_shader_module(handle, vert_shader_code);
    VkShaderModule shader_module_frag = create_shader_module(handle, frag_shader_code);

    VkPipelineShaderStageCreateInfo vertShaderStageInfo{};
    vertShaderStageInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
    vertShaderStageInfo.stage = VK_SHADER_STAGE_VERTEX_BIT;
    vertShaderStageInfo.module = shader_module_vert;
    vertShaderStageInfo.pName = "main";

    VkPipelineShaderStageCreateInfo fragShaderStageInfo{};
    fragShaderStageInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
    fragShaderStageInfo.stage = VK_SHADER_STAGE_FRAGMENT_BIT;
    fragShaderStageInfo.module = shader_module_frag;
    fragShaderStageInfo.pName = "main";

    VkPipelineShaderStageCreateInfo shaderStages[] = {vertShaderStageInfo, fragShaderStageInfo};

    VkPipelineVertexInputStateCreateInfo vertexInputInfo{};
    vertexInputInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO;
    vertexInputInfo.vertexBindingDescriptionCount = 0;
    vertexInputInfo.pVertexBindingDescriptions = nullptr; // Optional
    vertexInputInfo.vertexAttributeDescriptionCount = 0;
    vertexInputInfo.pVertexAttributeDescriptions = nullptr; // Optional

    VkPipelineInputAssemblyStateCreateInfo inputAssembly{};
    inputAssembly.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO;
    inputAssembly.topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
    inputAssembly.primitiveRestartEnable = VK_FALSE;

    VkViewport viewport{};
    viewport.x = 0.0f;
    viewport.y = 0.0f;
    viewport.width = (float)handle.swapchain_extent.width;
    viewport.height = (float)handle.swapchain_extent.height;
    viewport.minDepth = 0.0f;
    viewport.maxDepth = 1.0f;

    VkRect2D scissor{};
    scissor.offset = {0, 0};
    scissor.extent = handle.swapchain_extent;

    VkPipelineViewportStateCreateInfo viewportState{};
    viewportState.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO;
    viewportState.viewportCount = 1;
    viewportState.pViewports = &viewport;
    viewportState.scissorCount = 1;
    viewportState.pScissors = &scissor;

    VkPipelineRasterizationStateCreateInfo rasterizer{};
    rasterizer.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO;
    rasterizer.depthClampEnable = VK_FALSE;
    rasterizer.rasterizerDiscardEnable = VK_FALSE;
    rasterizer.polygonMode = VK_POLYGON_MODE_FILL;
    rasterizer.lineWidth = 1.0f;
    rasterizer.cullMode = VK_CULL_MODE_BACK_BIT;
    rasterizer.frontFace = VK_FRONT_FACE_CLOCKWISE;
    rasterizer.depthBiasEnable = VK_FALSE;
    rasterizer.depthBiasConstantFactor = 0.0f; // Optional
    rasterizer.depthBiasClamp = 0.0f;          // Optional
    rasterizer.depthBiasSlopeFactor = 0.0f;    // Optional

    VkPipelineMultisampleStateCreateInfo multisampling{};
    multisampling.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO;
    multisampling.sampleShadingEnable = VK_FALSE;
    multisampling.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT;
    multisampling.minSampleShading = 1.0f;          // Optional
    multisampling.pSampleMask = nullptr;            // Optional
    multisampling.alphaToCoverageEnable = VK_FALSE; // Optional
    multisampling.alphaToOneEnable = VK_FALSE;      // Optional

    VkPipelineColorBlendAttachmentState colorBlendAttachment{};
    colorBlendAttachment.colorWriteMask = VK_COLOR_COMPONENT_R_BIT | VK_COLOR_COMPONENT_G_BIT | VK_COLOR_COMPONENT_B_BIT | VK_COLOR_COMPONENT_A_BIT;
    colorBlendAttachment.blendEnable = VK_FALSE;
    colorBlendAttachment.srcColorBlendFactor = VK_BLEND_FACTOR_ONE;  // Optional
    colorBlendAttachment.dstColorBlendFactor = VK_BLEND_FACTOR_ZERO; // Optional
    colorBlendAttachment.colorBlendOp = VK_BLEND_OP_ADD;             // Optional
    colorBlendAttachment.srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE;  // Optional
    colorBlendAttachment.dstAlphaBlendFactor = VK_BLEND_FACTOR_ZERO; // Optional
    colorBlendAttachment.alphaBlendOp = VK_BLEND_OP_ADD;             // Optional

    VkPipelineColorBlendStateCreateInfo colorBlending{};
    colorBlending.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO;
    colorBlending.logicOpEnable = VK_FALSE;
    colorBlending.logicOp = VK_LOGIC_OP_COPY; // Optional
    colorBlending.attachmentCount = 1;
    colorBlending.pAttachments = &colorBlendAttachment;
    colorBlending.blendConstants[0] = 0.0f; // Optional
    colorBlending.blendConstants[1] = 0.0f; // Optional
    colorBlending.blendConstants[2] = 0.0f; // Optional
    colorBlending.blendConstants[3] = 0.0f; // Optional

#if 0
    std::vector<VkDynamicState> dynamicStates = {
        VK_DYNAMIC_STATE_VIEWPORT,
        VK_DYNAMIC_STATE_LINE_WIDTH
    };

    VkPipelineDynamicStateCreateInfo dynamicState{};
    dynamicState.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO;
    dynamicState.dynamicStateCount = static_cast<uint32_t>(dynamicStates.size());
    dynamicState.pDynamicStates = dynamicStates.data();
#endif

    VkPipelineLayoutCreateInfo pipelineLayoutInfo{};
    pipelineLayoutInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
    pipelineLayoutInfo.setLayoutCount = 0;            // Optional
    pipelineLayoutInfo.pSetLayouts = nullptr;         // Optional
    pipelineLayoutInfo.pushConstantRangeCount = 0;    // Optional
    pipelineLayoutInfo.pPushConstantRanges = nullptr; // Optional

    if (vkCreatePipelineLayout(handle.device, &pipelineLayoutInfo, nullptr, &handle.pipeline_layout) != VK_SUCCESS) {
        CERROR("failed to create pipeline layout!");
    }

    VkGraphicsPipelineCreateInfo pipelineInfo{};
    pipelineInfo.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO;
    pipelineInfo.stageCount = 2;
    pipelineInfo.pStages = shaderStages;
    pipelineInfo.pVertexInputState = &vertexInputInfo;
    pipelineInfo.pInputAssemblyState = &inputAssembly;
    pipelineInfo.pViewportState = &viewportState;
    pipelineInfo.pRasterizationState = &rasterizer;
    pipelineInfo.pMultisampleState = &multisampling;
    pipelineInfo.pDepthStencilState = nullptr; // Optional
    pipelineInfo.pColorBlendState = &colorBlending;
    pipelineInfo.pDynamicState = nullptr; // Optional
    pipelineInfo.layout = handle.pipeline_layout;
    pipelineInfo.renderPass = handle.render_pass;
    pipelineInfo.subpass = 0;
    pipelineInfo.basePipelineHandle = VK_NULL_HANDLE; // Optional
    pipelineInfo.basePipelineIndex = -1;              // Optional
    pipelineInfo.basePipelineHandle = VK_NULL_HANDLE; // Optional
    pipelineInfo.basePipelineIndex = -1;              // Optional

    if (vkCreateGraphicsPipelines(handle.device, VK_NULL_HANDLE, 1, &pipelineInfo, nullptr, &handle.graphics_pipeline) != VK_SUCCESS) {
        CERROR("failed to create graphics pipeline!");
    }

    vkDestroyShaderModule(handle.device, shader_module_frag, nullptr);
    vkDestroyShaderModule(handle.device, shader_module_vert, nullptr);
}
/* #endregion */

void create_frame_buffers(VulkanHandle &handle) {
    handle.swapchain_frame_buffers.resize(handle.swapchain_image_views.size());

    for (size_t i = 0; i < handle.swapchain_image_views.size(); i++) {
        VkImageView attachments[] = {handle.swapchain_image_views[i]};

        VkFramebufferCreateInfo framebufferInfo{};
        framebufferInfo.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO;
        framebufferInfo.renderPass = handle.render_pass;
        framebufferInfo.attachmentCount = 1;
        framebufferInfo.pAttachments = attachments;
        framebufferInfo.width = handle.swapchain_extent.width;
        framebufferInfo.height = handle.swapchain_extent.height;
        framebufferInfo.layers = 1;

        if (vkCreateFramebuffer(handle.device, &framebufferInfo, nullptr, &handle.swapchain_frame_buffers[i]) != VK_SUCCESS) {
            CERROR("failed to create framebuffer!");
        }
    }
}

void create_command_pool(VulkanHandle &handle) {
    QueueFamilyIndices queue_family_indices = find_queue_families(handle, handle.physical_device);

    VkCommandPoolCreateInfo poolInfo{};
    poolInfo.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
    poolInfo.flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;
    poolInfo.queueFamilyIndex = queue_family_indices.graphics_family.value();

    if (vkCreateCommandPool(handle.device, &poolInfo, nullptr, &handle.command_pool) != VK_SUCCESS) {
        CERROR("failed to create command pool!");
    }
}

void record_command_buffer(VulkanHandle &handle, VkCommandBuffer command_buffer, uint32_t image_index) {
    VkCommandBufferBeginInfo beginInfo{};
    beginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
    beginInfo.flags = 0;                  // Optional
    beginInfo.pInheritanceInfo = nullptr; // Optional

    if (vkBeginCommandBuffer(command_buffer, &beginInfo) != VK_SUCCESS) {
        CERROR("failed to begin recording command buffer!");
    }

    VkRenderPassBeginInfo renderPassInfo{};
    renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
    renderPassInfo.renderPass = handle.render_pass;
    renderPassInfo.framebuffer = handle.swapchain_frame_buffers[image_index];
    renderPassInfo.renderArea.offset = {0, 0};
    renderPassInfo.renderArea.extent = handle.swapchain_extent;

    VkClearValue clearColor = {{{0.0f, 0.0f, 0.0f, 1.0f}}};
    renderPassInfo.clearValueCount = 1;
    renderPassInfo.pClearValues = &clearColor;

    vkCmdBeginRenderPass(command_buffer, &renderPassInfo, VK_SUBPASS_CONTENTS_INLINE);
    vkCmdBindPipeline(command_buffer, VK_PIPELINE_BIND_POINT_GRAPHICS, handle.graphics_pipeline);
    vkCmdDraw(command_buffer, 3, 1, 0, 0);
    vkCmdEndRenderPass(command_buffer);

    if (vkEndCommandBuffer(command_buffer) != VK_SUCCESS) {
        CERROR("failed to record command buffer!");
    }
}

void create_command_buffer(VulkanHandle &handle) {
    VkCommandBufferAllocateInfo allocInfo{};
    allocInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
    allocInfo.commandPool = handle.command_pool;
    allocInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    allocInfo.commandBufferCount = 1;

    if (vkAllocateCommandBuffers(handle.device, &allocInfo, &handle.command_buffer) != VK_SUCCESS) {
        CERROR("failed to allocate command buffers!");
    }
}

void create_sync_objects(VulkanHandle &handle) {
    VkSemaphoreCreateInfo semaphoreInfo{};
    semaphoreInfo.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO;

    VkFenceCreateInfo fenceInfo{};
    fenceInfo.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
    fenceInfo.flags = VK_FENCE_CREATE_SIGNALED_BIT;

    if (vkCreateSemaphore(handle.device, &semaphoreInfo, nullptr, &handle.image_available_semaphore) != VK_SUCCESS ||
        vkCreateSemaphore(handle.device, &semaphoreInfo, nullptr, &handle.render_finished_semaphore) != VK_SUCCESS ||
        vkCreateFence(handle.device, &fenceInfo, nullptr, &handle.in_flight_fence) != VK_SUCCESS) {
        CERROR("failed to create semaphores!");
    }
}

void draw_frame(VulkanHandle &handle, GLFWwindow *window) {
    vkWaitForFences(handle.device, 1, &handle.in_flight_fence, VK_TRUE, UINT64_MAX);
    vkResetFences(handle.device, 1, &handle.in_flight_fence);

    uint32_t imageIndex;
    vkAcquireNextImageKHR(handle.device, handle.swapchain, UINT64_MAX, handle.image_available_semaphore, VK_NULL_HANDLE, &imageIndex);

    vkResetCommandBuffer(handle.command_buffer, /*VkCommandBufferResetFlagBits*/ 0);
    record_command_buffer(handle, handle.command_buffer, imageIndex);

    VkSubmitInfo submitInfo{};
    submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO;

    VkSemaphore waitSemaphores[] = {handle.image_available_semaphore};
    VkPipelineStageFlags waitStages[] = {VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT};
    submitInfo.waitSemaphoreCount = 1;
    submitInfo.pWaitSemaphores = waitSemaphores;
    submitInfo.pWaitDstStageMask = waitStages;

    submitInfo.commandBufferCount = 1;
    submitInfo.pCommandBuffers = &handle.command_buffer;

    VkSemaphore signalSemaphores[] = {handle.render_finished_semaphore};
    submitInfo.signalSemaphoreCount = 1;
    submitInfo.pSignalSemaphores = signalSemaphores;

    if (vkQueueSubmit(handle.graphics_queue, 1, &submitInfo, handle.in_flight_fence) != VK_SUCCESS) {
        throw std::runtime_error("failed to submit draw command buffer!");
    }

    VkPresentInfoKHR presentInfo{};
    presentInfo.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;

    presentInfo.waitSemaphoreCount = 1;
    presentInfo.pWaitSemaphores = signalSemaphores;

    VkSwapchainKHR swapChains[] = {handle.swapchain};
    presentInfo.swapchainCount = 1;
    presentInfo.pSwapchains = swapChains;

    presentInfo.pImageIndices = &imageIndex;

    vkQueuePresentKHR(handle.present_queue, &presentInfo);
}

#endif // _VULKAN_SETUP_H_
