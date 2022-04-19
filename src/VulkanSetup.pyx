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


cdef vector[char*] get_required_extensions(bint enable_validation_layers):
    cdef uint32_t glfwExtensionCount = 0
    cdef char** glfwExtensions = <char**> glfwGetRequiredInstanceExtensions(&glfwExtensionCount)

    cdef char_ptr_vector extensions = char_ptr_vector(glfwExtensionCount, glfwExtensions[0])

    if enable_validation_layers:
        extensions.push_back(VK_EXT_DEBUG_UTILS_EXTENSION_NAME)

    return extensions

cdef bint check_validation_layer_support(vector[char*]& validation_layers):
    cdef uint32_t layer_count
    vkEnumerateInstanceLayerProperties(&layer_count, NULL)

    cdef vector[VkLayerProperties] available_ayers = vector[VkLayerProperties](layer_count);
    vkEnumerateInstanceLayerProperties(&layer_count, available_ayers.data())

    for layer_name in validation_layers:
        for layer_properties in available_ayers:
            if streq(layer_name, layer_properties.layerName):
                break

        else:
            return False

    return True


cdef VkInstance create_instance(
        char* app_name,
        vector[char*]* additional_extensions=NULL,
        vector[char*]* validation_layers=NULL,
        PFN_vkDebugUtilsMessengerCallbackEXT debug_callback=NULL,
):
    cdef bint enable_validation_layers = validation_layers != NULL

    if enable_validation_layers and not check_validation_layer_support(validation_layers[0]):
        CERROR("validation layers requested, but not available!")

    cdef VkInstance instance
    cdef VkApplicationInfo appInfo
    cdef VkInstanceCreateInfo createInfo
    cdef VkDebugUtilsMessengerCreateInfoEXT debugCreateInfo
    memset(&instance, 0, sizeof(VkInstance))
    memset(&appInfo, 0, sizeof(VkApplicationInfo))
    memset(&createInfo, 0, sizeof(VkInstanceCreateInfo))
    memset(&debugCreateInfo, 0, sizeof(VkDebugUtilsMessengerCreateInfoEXT))

    appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO
    appInfo.pApplicationName = app_name
    appInfo.applicationVersion = VK_MAKE_VERSION(1, 2, 0)
    appInfo.pEngineName = "No Engine"
    appInfo.engineVersion = VK_MAKE_VERSION(1, 2, 0)
    appInfo.apiVersion = VK_API_VERSION_1_0

    createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
    createInfo.pApplicationInfo = &appInfo

    cdef vector[char*] extensions = get_required_extensions(enable_validation_layers);
    cdef char* extension
    cdef char* additional_extension
    cdef vector[char*] extensions_diff
    if additional_extensions != NULL:
        for extension in extensions:
            for additional_extension in additional_extensions[0]:
                if streq(extension, additional_extension):
                    break
            else:
                extensions_diff.push_back(additional_extension)
        for extension in extensions_diff:
            extensions.push_back(extension)

    createInfo.enabledExtensionCount = <uint32_t>extensions.size()
    createInfo.ppEnabledExtensionNames = extensions.data()

    if enable_validation_layers:
        createInfo.enabledLayerCount = <uint32_t>validation_layers[0].size()
        createInfo.ppEnabledLayerNames = validation_layers[0].data()

        debugCreateInfo.sType = VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT
        debugCreateInfo.pNext = NULL
        debugCreateInfo.flags = 0
        debugCreateInfo.messageSeverity = VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT
        debugCreateInfo.messageType = VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT
        debugCreateInfo.pfnUserCallback = <PFN_vkDebugUtilsMessengerCallbackEXT> debug_callback
        debugCreateInfo.pUserData = NULL

        createInfo.pNext = <VkDebugUtilsMessengerCreateInfoEXT*> &debugCreateInfo
    else:
        createInfo.enabledLayerCount = 0
        createInfo.pNext = NULL

    if vkCreateInstance(&createInfo, NULL, &instance) != VK_SUCCESS:
        CERROR("failed to create instance!")

    return instance


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


cdef void setupDebugMessenger(bint enable_validation_layers, VkInstance* instance, VkDebugUtilsMessengerEXT* debug_messenger, PFN_vkDebugUtilsMessengerCallbackEXT debug_callback):
    if not enable_validation_layers:
        return

    cdef VkDebugUtilsMessengerCreateInfoEXT createInfo

    createInfo.sType = VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT
    createInfo.pNext = NULL
    createInfo.flags = 0
    createInfo.messageSeverity = VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT
    createInfo.messageType = VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT
    createInfo.pfnUserCallback = debug_callback
    createInfo.pUserData = NULL

    if CreateDebugUtilsMessengerEXT(instance[0], &createInfo, NULL, debug_messenger) != VK_SUCCESS:
        CERROR("failed to set up debug messenger!")


cdef void create_surface(VkInstance* instance, GLFWwindow* window, VkSurfaceKHR* surface):
    if glfwCreateWindowSurface(instance[0], window, NULL, surface) != VK_SUCCESS:
        CERROR("failed to create window surface!")
