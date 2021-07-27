//
//  VolcanoSwapchainRenderer.swift
//  AppKid
//
//  Created by Serhii Mumriak on 23.08.2020.
//

import Foundation
import CoreFoundation
import TinyFoundation
@_spi(AppKid) import ContentAnimation
import Volcano
import Glibc

public enum VolcanoSwapchainRendererError: Error {
    case noPresentationQueueFound
}

internal class VolcanoSwapchainRenderer {
    let window: Window
    let renderStack: VolcanoRenderStack
    let presentationQueue: Queue

    let layerRenderer: VolcanoRenderer

    let commandPool: CommandPool

    internal fileprivate(set) var surface: Surface

    internal let imageAvailableSemaphore: Volcano.Semaphore
    internal let renderFinishedSemaphore: Volcano.Semaphore
    internal let fence: Fence
    internal let timelineSemaphore: TimelineSemaphore

    internal var device: Device { renderStack.device }
    internal var textures: [Texture] = []

    internal let lock = NSLock()

    internal var isRendering: Bool = false {
        willSet {
            lock.lock()
        }
        didSet {
            lock.unlock()
        }
    }

    var oldSwapchain: Swapchain?
    var swapchain: Swapchain!

    deinit {
        try? clearSwapchain()
        oldSwapchain = nil
    }

    init(window: Window, renderStack: VolcanoRenderStack) throws {
        self.window = window
        self.renderStack = renderStack
        let device = renderStack.device
        let surface = try renderStack.createSurface(for: window)
        self.surface = surface

        guard let presentationQueue = try device.allQueues.first(where: { try surface.supportsPresenting(on: $0) }) else {
            throw VolcanoSwapchainRendererError.noPresentationQueueFound
        }

        self.presentationQueue = presentationQueue

        imageAvailableSemaphore = try Semaphore(device: device)
        renderFinishedSemaphore = try Semaphore(device: device)

        fence = try Fence(device: device)
        try fence.reset()

        timelineSemaphore = try TimelineSemaphore(device: device, initialValue: 0)

        commandPool = try renderStack.queues.graphics.createCommandPool(flags: .resetCommandBuffer)

        layerRenderer = try VolcanoRenderer(pixelFormat: surface.imageFormat, commandPool: commandPool)
        layerRenderer.layer = window.layer
        
        try setupSwapchain()
    }

    func setupSwapchain() throws {
        let windowSize = window.bounds.size
        let displayScale = window.nativeWindow.displayScale
        let desiredSize = VkExtent2D(width: UInt32(windowSize.width * displayScale), height: UInt32(windowSize.height * displayScale))
        
        try surface.refreshCapabilities()
        let capabilities = surface.capabilities
        let minSize = capabilities.minImageExtent
        let maxSize = capabilities.maxImageExtent

        let width = max(min(desiredSize.width, maxSize.width), minSize.width)
        let height = max(min(desiredSize.height, maxSize.height), minSize.height)
        let size = VkExtent2D(width: width, height: height)

        swapchain = try Swapchain(device: device, surface: surface, desiredPresentMode: .fifo, size: size, graphicsQueue: renderStack.queues.graphics, presentationQueue: presentationQueue, usage: .colorAttachment, compositeAlpha: .opaque, oldSwapchain: oldSwapchain)

        textures = try swapchain.creteTextures()

        oldSwapchain = nil
    }

    func clearSwapchain() throws {
        try device.waitForIdle()

        textures.removeAll()
        layerRenderer.renderTargetsCache.clear()
        oldSwapchain = swapchain
        swapchain = nil
    }

    func grabNextTexture() throws -> (index: Int, texture: Texture) {
        let index = try swapchain.getNextImageIndex(semaphore: imageAvailableSemaphore)

        return (index: index, texture: textures[index])
    }

    @MainActor func grabNextTextureAsync() async throws -> (index: Int, texture: Texture) {
        let index = try swapchain.getNextImageIndex(semaphore: imageAvailableSemaphore)

        return (index: index, texture: textures[index])
    }

    @MainActor func recreateSwapchainAsync() async throws {
        try clearSwapchain()
        try setupSwapchain()
    }

    @MainActor func prepareRenderContext() async throws {
        try layerRenderer.prepareRenderContext()
    }

    func executeRenderOperations() async throws {
        try layerRenderer.executeRenderOperations()
    }

    @MainActor func submit() async throws {
        try layerRenderer.submitCommandBuffer(waitSemaphores: [imageAvailableSemaphore], signalSemaphores: [renderFinishedSemaphore], signalTimelineSemaphores: [timelineSemaphore], fence: fence)
    }

    @MainActor func present(index: Int) async throws {
        try presentationQueue.present(swapchains: [swapchain], waitSemaphores: [renderFinishedSemaphore], imageIndices: [CUnsignedInt(index)])
    }

    func wait() async throws {
        try fence.wait()
    }

    func resetFence() async throws {
        try fence.reset()
    }

    @MainActor func asyncRender() async throws {
        if isRendering {
            return
        }

        isRendering = true

        // trying to recreate swapchain only once per render request. if it fails for the second time - frame is skipped assuming there will be new render request following. maybe not the best thing to do because it's like a hidden logic. will re-evaluate
        var skipRecreation = false

        // stupid nvidia driver on X11. the resize event is processed by the driver much earlier than x11 sends resize events to application. this always results in invalid swapchain on first frame after x11 have already resized it's framebuffer, but have not sent the event to application. bad interprocess communication and lack of synchronization results in application-side hacks i.e. swapchain has to be recreated even before the actual window is resized and it's contents have been layed out

        while true {
            do {
                let (index, texture) = try await grabNextTextureAsync()

                try layerRenderer.setDestination(texture)

                try layerRenderer.beginFrame(atTime: 0)

                try await prepareRenderContext()

                try await executeRenderOperations()

                let waitValue = try timelineSemaphore.value + 1

                try await submit()

                let _: Void = try await withUnsafeThrowingContinuation { continuation in
                    do {
                        try renderStack.semaphoreWatcher.add(semaphore: timelineSemaphore, waitValue: waitValue) {
                            continuation.resume()
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }

                try await resetFence()

                try await present(index: index)

                try layerRenderer.endFrame()

                isRendering = false
                break
            } catch VulkanError.badResult(let errorCode) {
                if errorCode == .errorOutOfDate {
                    if skipRecreation == true {
                        break
                    }

                    try await recreateSwapchainAsync()

                    skipRecreation = true
                } else {
                    isRendering = false
                    throw VulkanError.badResult(errorCode)
                }
            }
        }
    }

    func render() throws {
        if isRendering {
            return
        }

        isRendering = true
        defer { isRendering = false }

        // trying to recreate swapchain only once per render request. if it fails for the second time - frame is skipped assuming there will be new render request following. maybe not the best thing to do because it's like a hidden logic. will re-evaluate
        var skipRecreation = false

        // stupid nvidia driver on X11. the resize event is processed by the driver much earlier than x11 sends resize events to application. this always results in invalid swapchain on first frame after x11 have already resized it's framebuffer, but have not sent the event to application. bad interprocess communication and lack of synchronization results in application-side hacks i.e. swapchain has to be recreated even before the actual window is resized and it's contents have been layed out

        while true {
            do {
                let (index, texture) = try grabNextTexture()

                try layerRenderer.setDestination(texture)

                try layerRenderer.beginFrame(atTime: 0)

                try layerRenderer.render(waitSemaphores: [imageAvailableSemaphore], signalSemaphores: [renderFinishedSemaphore], fence: fence)

                try fence.wait()
                try fence.reset()

                try presentationQueue.present(swapchains: [swapchain], waitSemaphores: [renderFinishedSemaphore], imageIndices: [CUnsignedInt(index)])

                try layerRenderer.endFrame()

                break
            } catch VulkanError.badResult(let errorCode) {
                if errorCode == .errorOutOfDate {
                    if skipRecreation == true {
                        break
                    }

                    try clearSwapchain()
                    try setupSwapchain()

                    skipRecreation = true
                } else {
                    throw VulkanError.badResult(errorCode)
                }
            }
        }

        // previous rendering code that would not skip swapchain recreation. keeping here till re-evaluating the solution
//        var happyFrame = false
//        repeat {
//            do {
//                try drawFrame()
//                happyFrame = true
//            } catch VulkanError.badResult(let errorCode) {
//                if errorCode == .errorOutOfDate {
//                    try clearSwapchain()
//                    try setupSwapchain()
//                } else {
//                    throw VulkanError.badResult(errorCode)
//                }
//            }
//        } while happyFrame == false
    }
}