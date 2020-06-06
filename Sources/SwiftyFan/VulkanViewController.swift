//
//  VulkanViewController.swift
//  AppKid
//
//  Created by Serhii Mumriak on 15.05.2020.
//

import Foundation
import AppKid
import Volcano
import TinyFoundation
import CVulkan

class VulkanViewController: ViewController {
    lazy var vulkanInstance: Instance = Instance()
    var physicalDevice: PhysicalDevice!
    var surface: Surface!
    var device: Device!
    var swapchain: Swapchain!
    var preesentationQueue: Queue!
    var graphicsQueue: Queue!
    var images: [Image]!
    var imageViews: [ImageView]!
    var vertexShader: Shader!
    var fragmentShader: Shader!
    var commandPool: CommandPool!
    var commandBuffer: CommandBuffer!

    deinit {
        commandBuffer = nil
        commandPool = nil
        fragmentShader = nil
        vertexShader = nil
        imageViews = nil
        images = nil
        graphicsQueue = nil
        preesentationQueue = nil
        swapchain = nil
        device = nil
        surface = nil
        physicalDevice = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        do {
            guard let window = self.view.window else { return }

            guard let physicalDevice = vulkanInstance.discreteGPUDevices else { return }

            self.physicalDevice = physicalDevice

            let windowSize = window.bounds.size
            let displayScale = window.nativeWindow.displayScale
            let size = VkExtent2D(width: UInt32(windowSize.width * displayScale), height: UInt32(windowSize.height * displayScale))
            surface = try physicalDevice.createXlibSurface(display: window.nativeWindow.display, window:  window.nativeWindow.windowID)

            device = try Device(surface: surface)

            preesentationQueue = try Queue(device: device, familyIndex: device.presentationQueueFamilyIndex, queueIndex: 0)
            graphicsQueue = try Queue(device: device, familyIndex: device.graphicsQueueFamilyIndex, queueIndex: 0)

            swapchain = try Swapchain(device: device, surface: surface, size: size)

            images = try swapchain.getImages()
            imageViews = try images.map { try ImageView(image: $0) }

            let vertexShaderData = try Data(contentsOf: URL(fileURLWithPath: "/media/nfs/HQ505/NAS/swiftyfan/Volcano/Resources/TriangleVertexShader.spv"), options: [])
            let fragmentShaderData = try Data(contentsOf: URL(fileURLWithPath: "/media/nfs/HQ505/NAS/swiftyfan/Volcano/Resources/TriangleFragmentShader.spv"), options: [])

            vertexShader = try Shader(data: vertexShaderData, device: device)
            fragmentShader = try Shader(data: fragmentShaderData, device: device)

            commandPool = try CommandPool(device: device, queue: graphicsQueue)
            commandBuffer = try CommandBuffer(commandPool: commandPool)

            debugPrint("Vulcan loaded")
        } catch {
            fatalError("Failed to load vulkan with error: \(error)")
        }
    }
}
