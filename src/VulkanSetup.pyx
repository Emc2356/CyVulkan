#cython: language_level=3

from utils cimport *

from VulkanSetup cimport *

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
from libcpp.set cimport set as CPPSet
from libcpp.string cimport string as CPPString


cdef vector[char*] get_required_extensions(bint enable_validation_layers):
    cdef uint32_t glfwExtensionCount = 0
    cdef char** glfwExtensions = <char**> glfwGetRequiredInstanceExtensions(&glfwExtensionCount)

    cdef char_ptr_vector extensions = char_ptr_vector(glfwExtensionCount, glfwExtensions[0])

    if enable_validation_layers:
        extensions.push_back(VK_EXT_DEBUG_UTILS_EXTENSION_NAME)

    return extensions


cdef bint check_validation_layer_support(VulkanHandle& handle):
    cdef uint32_t layer_count
    vkEnumerateInstanceLayerProperties(&layer_count, NULL)

    cdef vector[VkLayerProperties] available_ayers = vector[VkLayerProperties](layer_count);
    vkEnumerateInstanceLayerProperties(&layer_count, available_ayers.data())

    for layer_name in handle.validation_layers:
        for layer_properties in available_ayers:
            if streq(layer_name, layer_properties.layerName):
                break

        else:
            return False

    return True


cdef void initialize_instance(char* app_name, VulkanHandle& handle):
    cdef bint enable_validation_layers = handle.enable_validation_layers

    if enable_validation_layers and not check_validation_layer_support(handle):
        CERROR("validation layers requested, but not available!")

    cdef VkApplicationInfo appInfo
    cdef VkInstanceCreateInfo createInfo
    cdef VkDebugUtilsMessengerCreateInfoEXT debugCreateInfo
    memset(&appInfo, 0, sizeof(VkApplicationInfo))
    memset(&createInfo, 0, sizeof(VkInstanceCreateInfo))
    memset(&debugCreateInfo, 0, sizeof(VkDebugUtilsMessengerCreateInfoEXT))

    appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO
    appInfo.pApplicationName = app_name
    appInfo.applicationVersion = VK_MAKE_VERSION(1, 0, 0)
    appInfo.pEngineName = "No Engine"
    appInfo.engineVersion = VK_MAKE_VERSION(1, 0, 0)
    appInfo.apiVersion = VK_API_VERSION_1_0

    createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
    createInfo.pApplicationInfo = &appInfo

    cdef vector[char*] extensions = get_required_extensions(enable_validation_layers)
    cdef char* extension
    cdef char* additional_extension
    cdef vector[char*] extensions_diff
    if not handle.additional_extensions.empty():
        for extension in extensions:
            for additional_extension in handle.additional_extensions:
                if streq(extension, additional_extension):
                    break
            else:
                extensions_diff.push_back(additional_extension)
        for extension in extensions_diff:
            extensions.push_back(extension)

    createInfo.enabledExtensionCount = <uint32_t>extensions.size()
    createInfo.ppEnabledExtensionNames = extensions.data()

    if enable_validation_layers:
        createInfo.enabledLayerCount = <uint32_t>handle.validation_layers.size()
        createInfo.ppEnabledLayerNames = handle.validation_layers.data()

        debugCreateInfo.sType = VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT
        debugCreateInfo.pNext = NULL
        debugCreateInfo.flags = 0
        debugCreateInfo.messageSeverity = VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT
        debugCreateInfo.messageType = VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT
        debugCreateInfo.pfnUserCallback = handle.debug_callback
        debugCreateInfo.pUserData = NULL

        createInfo.pNext = <VkDebugUtilsMessengerCreateInfoEXT*> &debugCreateInfo
    else:
        createInfo.enabledLayerCount = 0
        createInfo.pNext = NULL

    if vkCreateInstance(&createInfo, NULL, &handle.instance) != VK_SUCCESS:
        CERROR("failed to create instance!")


cdef VkResult CreateDebugUtilsMessengerEXT(VkInstance instance, const VkDebugUtilsMessengerCreateInfoEXT* pCreateInfo, const VkAllocationCallbacks* pAllocator, VkDebugUtilsMessengerEXT* pDebugMessenger):
    cdef PFN_vkCreateDebugUtilsMessengerEXT func = <PFN_vkCreateDebugUtilsMessengerEXT> vkGetInstanceProcAddr(instance, "vkCreateDebugUtilsMessengerEXT");
    if func != NULL:
        return func(instance, pCreateInfo, pAllocator, pDebugMessenger)
    else:
        return VK_ERROR_EXTENSION_NOT_PRESENT


cdef void DestroyDebugUtilsMessengerEXT(VkInstance instance, VkDebugUtilsMessengerEXT debugMessenger, const VkAllocationCallbacks* pAllocator):
    cdef PFN_vkDestroyDebugUtilsMessengerEXT func = <PFN_vkDestroyDebugUtilsMessengerEXT> vkGetInstanceProcAddr(instance, "vkDestroyDebugUtilsMessengerEXT")
    if func != NULL:
        func(instance, debugMessenger, pAllocator)


cdef void setupDebugMessenger(VulkanHandle& handle):
    if not handle.enable_validation_layers:
        return

    cdef VkDebugUtilsMessengerCreateInfoEXT createInfo

    createInfo.sType = VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT
    createInfo.pNext = NULL
    createInfo.flags = 0
    createInfo.messageSeverity = VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT
    createInfo.messageType = VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT
    createInfo.pfnUserCallback = handle.debug_callback
    createInfo.pUserData = NULL

    if CreateDebugUtilsMessengerEXT(handle.instance, &createInfo, NULL, &handle.debug_messenger) != VK_SUCCESS:
        CERROR("failed to set up debug messenger!")


cdef void create_surface(VulkanHandle& handle, GLFWwindow* window):
    if glfwCreateWindowSurface(handle.instance, window, NULL, &handle.surface) != VK_SUCCESS:
        CERROR("failed to create window surface!")


cdef QueueFamilyIndices find_queue_families(VulkanHandle& handle, VkPhysicalDevice& device):
    cdef QueueFamilyIndices indices

    cdef uint32_t queue_family_count = 0
    vkGetPhysicalDeviceQueueFamilyProperties(device, &queue_family_count, NULL)

    cdef vector[VkQueueFamilyProperties] queue_families = vector[VkQueueFamilyProperties](queue_family_count)
    vkGetPhysicalDeviceQueueFamilyProperties(device, &queue_family_count, queue_families.data())

    cdef int i = 0
    cdef VkQueueFamilyProperties queue_family
    cdef VkBool32 present_support = VK_FALSE

    for i in range(queue_families.size()):
        present_support = VK_FALSE
        vkGetPhysicalDeviceSurfaceSupportKHR(device, i, handle.surface, &present_support)
        if present_support:
            indices.present_family.set(i)
        if queue_families[i].queueFlags & VK_QUEUE_GRAPHICS_BIT:
            indices.graphics_family.set(i)
            break

    return indices


cdef bint check_device_extension_support(vector[char*]& device_extensions, VkPhysicalDevice& device):
    cdef uint32_t extensionCount
    vkEnumerateDeviceExtensionProperties(device, NULL, &extensionCount, NULL)

    cdef vector[VkExtensionProperties] availableExtensions = vector[VkExtensionProperties](extensionCount)
    vkEnumerateDeviceExtensionProperties(device, NULL, &extensionCount, availableExtensions.data())

    cdef CPPSet[CPPString] requiredExtensions = CPPSet[CPPString]()
    for device_extension in device_extensions:
        requiredExtensions.insert(device_extension)

    cdef VkExtensionProperties extension
    for extension in availableExtensions:
        requiredExtensions.erase(extension.extensionName)

    return requiredExtensions.empty()


cdef bint is_device_suitable(VulkanHandle& handle, VkPhysicalDevice& device):
    cdef QueueFamilyIndices indices = find_queue_families(handle, device)
    cdef bint extensionsSupported = check_device_extension_support(handle.device_extensions, device)

    return indices.graphics_family.has_value() and indices.present_family.has_value() and extensionsSupported


cdef VkPhysicalDevice pick_physical_device(VulkanHandle& handle):
    cdef VkPhysicalDevice physical_device
    cdef uint32_t device_count = 0

    vkEnumeratePhysicalDevices(handle.instance, &device_count, NULL)

    if device_count == 0:
        CERROR("failed to find GPUs with Vulkan support!")

    cdef vector[VkPhysicalDevice] devices = vector[VkPhysicalDevice](device_count)
    vkEnumeratePhysicalDevices(handle.instance, &device_count, devices.data())

    for device in devices:
        if is_device_suitable(handle, device):
            physical_device = device
            break
    else:
        CERROR("failed to find a suitable GPU!")

    return physical_device


cdef VkDevice create_logical_device(VulkanHandle& handle):
    cdef QueueFamilyIndices indices = find_queue_families(handle, handle.physical_device);

    cdef vector[VkDeviceQueueCreateInfo] queue_create_infos
    cdef CPPSet[uint32_t] unique_queue_families = {indices.graphics_family.value(), indices.present_family.value()};
    cdef float queue_priority = 1.0
    cdef VkDeviceQueueCreateInfo queue_create_info

    for queue_family in unique_queue_families:
        memset(&queue_create_info, 0, sizeof(VkDeviceQueueCreateInfo))
        queue_create_info.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
        queue_create_info.queueFamilyIndex = queue_family
        queue_create_info.queueCount = 1
        queue_create_info.pQueuePriorities = &queue_priority
        queue_create_infos.push_back(queue_create_info)

    cdef VkPhysicalDeviceFeatures device_features
    cdef VkDeviceCreateInfo create_info
    cdef VkDevice device
    queue_priority = 1.0
    memset(&queue_create_info, 0, sizeof(VkDeviceQueueCreateInfo))
    memset(&device_features, 0, sizeof(VkPhysicalDeviceFeatures))
    memset(&create_info, 0, sizeof(VkDeviceCreateInfo))
    memset(&device, 0, sizeof(VkDevice))

    queue_create_info.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
    queue_create_info.queueFamilyIndex = indices.graphics_family.value()
    queue_create_info.queueCount = 1
    queue_create_info.pQueuePriorities = &queue_priority

    create_info.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO
    create_info.queueCreateInfoCount = 1
    create_info.pQueueCreateInfos = &queue_create_info
    create_info.pEnabledFeatures = &device_features

    create_info.enabledExtensionCount = 0

    create_info.queueCreateInfoCount = <uint32_t> queue_create_infos.size()
    create_info.pQueueCreateInfos = queue_create_infos.data()

    if handle.enable_validation_layers:
        create_info.enabledLayerCount = <uint32_t> handle.validation_layers.size()
        create_info.ppEnabledLayerNames = handle.validation_layers.data()
    else:
        create_info.enabledLayerCount = 0

    if vkCreateDevice(handle.physical_device, &create_info, NULL, &device) != VK_SUCCESS:
        CERROR("failed to create logical device!")

    vkGetDeviceQueue(device, indices.graphics_family.value(), 0, &handle.graphics_queue)
    vkGetDeviceQueue(device, indices.present_family.value(), 0, &handle.present_queue)

    return device
