# Volcano

<!-- Convenient wrapper of Vulkan API in swift. -->

Volcano is a cross-platform toolkit for Vulkan API written in Swift. 

### Supported Platforms

Volcano aims to support all platforms that are supported by both Swift 5.5+ and Vulkan API. Currently it is developed on PopOS 21.10 and is known to support the following platforms:
- Ubuntu 20.04+
- macOS 11+

### Compatibility

Volcano follows [SemVer 2.0.0](https://semver.org/#semantic-versioning-200) and is periodically syncrhonized with Vulkan API version.

## Conceptual Overview

### Architecture

Vulkan API provides three top-level entities that create all other entities: `VkInstance`, `VkPhysicalDevice` and `VkDevice`. Vulkan requires that these top level objects are valid while their child objects are in use. Volcano has encapsulated them in dedicated class pairs:
    - `Instance` class wraps `VkInstance`. `InstanceEntity` has a strong reference to `Instance`
    - `PhysicalDevice` class wraps `VkPhysicalDevice`. `PhysicalDeviceEntity` has a strong reference to `PhysicalDevice`
    - `Device` class wraps `VkDevice`. `DeviceEntity` has a strong reference to `Device`

`PhysicalDevice` is `InstanceEntity`, `Device` is `PhysicalDeviceEntity`.

##  # VolcanoSL

VolcanoSL is a tool that parses Volcano dialect of glsl shader source code files and generates vanilla glsl to be compiled. 
Currently supported feature is `@in` and `@out` attributes declaration with type resolution based of external header files with automatic calculation of location layout.
