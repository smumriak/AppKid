# Volcano

<!-- Convenient wrapper of Vulkan API in swift. -->

Volcano is a cross-platform toolkit for Vulkan API written in Swift. 

## Conceptual Overview

```swift
let instance = try Instance()
let physicalDevice = instance.physicalDevices.first {
    $0.features.samplerAnisotropy.bool == true
}
let device = try Device(physicalDevice: physicalDevice)
let queue = device.allQueues.first(where: { $0.type.contains(.graphics) })!

<replace with dot dot dot till we actually render something>
        let format = VkSurfaceFormatKHR(format: .b8g8r8a8SRGB, colorSpace: .srgbNonlinear)
        let surface = try Surface(physicalDevice: self, display: display, window: window, desiredFormat: desiredSurfaceFormat)
        let size = VkSize2D
        let swapchain = try Swapchain(device: device, surface: surface, size: size, graphicsQueue: queue, presentationQueue: queue, usage: .colorAttachment)
        let textures = try swapchain.createTextures()
        let semaphore = try Semaphore(device: device)
        let textureIndex = try swapchain.getNextImageIndex(semaphore: semaphore)
        let texture = textures[index]
        let fragmentShader = try device.shader(named: "FragmentShader")
        let vertexShader = try device.shader(named: "VertexShader")
        let pipelineDescriptor = GraphicsPipelineDescriptor()
        pipelineDescriptor.vertexShader = vertexShader
        pipelineDescriptor.fragmentShader = fragmentShader
        let pipeline = try GraphicsPipeline(device: device, descriptor: descriptor, renderPass: self, subpassIndex: subpassIndex)

let submitDescriptor = try SubmitDescriptor(commandBuffers: [commandBuffer], fence: fence)
try submitDescriptor.add(.wait(semaphore, stages: .colorAttachmentOutput))
```

Volcano - wrapper, VolcanoSL - shading language dialect, vkthings - generator, memory allocator and DSL.
### Architecture

Vulkan API provides three top-level entities that create all other entities: `VkInstance`, `VkPhysicalDevice` and `VkDevice`. Vulkan requires that these top level objects are valid while their child objects are in use. Volcano has encapsulated them in dedicated class pairs:
    - `Instance` class wraps `VkInstance`. `InstanceEntity` has a strong reference to `Instance`
    - `PhysicalDevice` class wraps `VkPhysicalDevice`. `PhysicalDeviceEntity` has a strong reference to `PhysicalDevice`
    - `Device` class wraps `VkDevice`. `DeviceEntity` has a strong reference to `Device`

## VolcanoSL

VolcanoSL is a tool that parses Volcano dialect of glsl shader source code files and generates vanilla glsl to be compiled. 
Currently supported feature is `@in` and `@out` attributes declaration with type resolution based of external header files with automatic calculation of location layout.

### Supported Platforms

Volcano aims to support all platforms that are supported by both Swift 5.5+ and Vulkan API. Currently it is developed on PopOS 21.10 and is known to support the following platforms:
- Ubuntu 20.04+
- macOS 11+

### Compatibility

Volcano follows [SemVer 2.0.0](https://semver.org/#semantic-versioning-200) and is periodically syncrhonized with Vulkan API version.

