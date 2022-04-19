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
from libcpp.set cimport set as CPPSet


# @std::optional
cdef struct QueueFamilyIndices:
    uint32_t graphics_family
    bint graphics_family_has_value
    uint32_t present_family
    bint present_family_has_value


cdef QueueFamilyIndices find_queue_families(VkPhysicalDevice device, VkSurfaceKHR* surface):
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
        vkGetPhysicalDeviceSurfaceSupportKHR(device, i, surface[0], &present_support)
        if present_support:
            indices.present_family = i
            indices.present_family_has_value = True
        if queue_families[i].queueFlags & VK_QUEUE_GRAPHICS_BIT:
            indices.graphics_family = i
            indices.graphics_family_has_value = True
            break

    return indices


cdef bint is_device_suitable(VkPhysicalDevice device, VkSurfaceKHR* surface):
    cdef VkPhysicalDeviceProperties device_properties;
    vkGetPhysicalDeviceProperties(device, &device_properties)

    cdef VkPhysicalDeviceFeatures device_features;
    vkGetPhysicalDeviceFeatures(device, &device_features)

    cdef QueueFamilyIndices indices = find_queue_families(device, surface);

    return indices.graphics_family_has_value and indices.present_family_has_value


cdef VkPhysicalDevice pick_physical_device(VkInstance* instance, VkSurfaceKHR* surface):
    cdef VkPhysicalDevice physical_device
    cdef uint32_t device_count = 0

    vkEnumeratePhysicalDevices(instance[0], &device_count, NULL)

    if device_count == 0:
        CERROR("failed to find GPUs with Vulkan support!")

    cdef vector[VkPhysicalDevice] devices = vector[VkPhysicalDevice](device_count)
    vkEnumeratePhysicalDevices(instance[0], &device_count, devices.data())

    for device in devices:
        if is_device_suitable(device, surface):
            physical_device = device
            break
    else:
        CERROR("failed to find a suitable GPU!")

    return physical_device


cdef VkDevice create_logical_device(
        VkPhysicalDevice* physical_device,
        VkSurfaceKHR* surface,
        VkQueue* graphics_queue,
        VkQueue* present_queue,
        vector[char*]* validation_layers=NULL,
):
    cdef bint enable_validation_layers = validation_layers != NULL

    cdef QueueFamilyIndices indices = find_queue_families(physical_device[0], surface);

    cdef vector[VkDeviceQueueCreateInfo] queue_create_infos
    cdef CPPSet[uint32_t] unique_queue_families = {indices.graphics_family, indices.present_family};
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
    queue_create_info.queueFamilyIndex = indices.graphics_family
    queue_create_info.queueCount = 1
    queue_create_info.pQueuePriorities = &queue_priority

    create_info.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO
    create_info.queueCreateInfoCount = 1
    create_info.pQueueCreateInfos = &queue_create_info
    create_info.pEnabledFeatures = &device_features

    create_info.enabledExtensionCount = 0

    create_info.queueCreateInfoCount = <uint32_t> queue_create_infos.size()
    create_info.pQueueCreateInfos = queue_create_infos.data()

    if enable_validation_layers:
        create_info.enabledLayerCount = <uint32_t> validation_layers[0].size()
        create_info.ppEnabledLayerNames = validation_layers[0].data()
    else:
        create_info.enabledLayerCount = 0

    if vkCreateDevice(physical_device[0], &create_info, NULL, &device) != VK_SUCCESS:
        CERROR("failed to create logical device!")

    vkGetDeviceQueue(device, indices.graphics_family, 0, graphics_queue)
    vkGetDeviceQueue(device, indices.present_family, 0, present_queue)

    return device
