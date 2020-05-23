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
    lazy var vulkanInstance: VulkanInstance = VulkanInstance()
    var device: VulkanDevice!
    var physicalDevice: VulkanPhysicalDevice!
    var surface: VulkanSurface!
    var swapchain: VulkanSwapchain!
    var preesentationQueue: VulkanQueue!
    var graphicsQueue: VulkanQueue!
    var images: [VulkanImage]!
    var imageViews: [VulkanImageView]!
    var vertexShader: VulkanShader!
    var fragmentShader: VulkanShader!

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

            device = try VulkanDevice(surface: surface)

            preesentationQueue = try VulkanQueue(device: device, familyIndex: device.presentationQueueFamilyIndex, queueIndex: 0)
            graphicsQueue = try VulkanQueue(device: device, familyIndex: device.graphicsQueueFamilyIndex, queueIndex: 0)

            swapchain = try VulkanSwapchain(device: device, surface: surface, size: size)

            images = try swapchain.getImages()
            imageViews = try images.map { try VulkanImageView(image: $0) }

            let vertexShaderData = try Data(contentsOf: URL(fileURLWithPath: "/media/nfs/HQ505/NAS/swiftyfan/Volcano/Resources/TriangleVertexShader.spv"), options: [])
            let fragmentShaderData = try Data(contentsOf: URL(fileURLWithPath: "/media/nfs/HQ505/NAS/swiftyfan/Volcano/Resources/TriangleFragmentShader.spv"), options: [])

            vertexShader = try VulkanShader(data: vertexShaderData, device: device)
            fragmentShader = try VulkanShader(data: fragmentShaderData, device: device)

            

            debugPrint("Vulcan loaded")
        } catch {
            fatalError("Failed to load vulkan with error: \(error)")
        }
    }
}
