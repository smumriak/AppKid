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
    internal enum State {
        case idle
        case preparingRenderContext
        case renderContextReady
        case preparingCommandBuffer
        case commandBufferReady
        case invalidated
    }

    private(set) weak var window: Window?
    private(set) var windowKeepAlive: Window?

    internal var recreateSwapchainOnNextRun: Bool = false

    let renderStack: VolcanoRenderStack
    let presentationQueue: Queue

    let layerRenderer: VolcanoRenderer

    let commandPool: CommandPool

    internal fileprivate(set) var surface: Surface

    internal let textureReadySemaphore: Volcano.Semaphore
    internal let commandBufferExecutionCompleteSemaphore: Volcano.Semaphore
    internal let fence: Fence
    internal let timelineSemaphore: TimelineSemaphore

    internal var device: Device { renderStack.device }
    internal var textures: [Texture] = []

    @Synchronized internal var state: State = .idle

    @Synchronized internal var isRendering: Bool = false

    var oldSwapchain: Swapchain?
    var swapchain: Swapchain!

    deinit {
        try? clearSwapchain()
        oldSwapchain = nil
        windowKeepAlive = nil
    }

    init(window: Window, surface: Surface, presentationQueue: Queue, renderStack: VolcanoRenderStack) throws {
        self.window = window
        self.renderStack = renderStack
        let device = renderStack.device
        self.surface = surface
        self.presentationQueue = presentationQueue

        textureReadySemaphore = try Semaphore(device: device)
        commandBufferExecutionCompleteSemaphore = try Semaphore(device: device)

        commandPool = try renderStack.queues.graphics.createCommandPool(flags: .resetCommandBuffer)

        layerRenderer = try VolcanoRenderer(pixelFormat: surface.imageFormat, commandPool: commandPool)
        layerRenderer.layer = window.layer

        fence = try Fence(device: device)
        try fence.reset()
        
        timelineSemaphore = try TimelineSemaphore(device: device, initialValue: 0)

        try setupSwapchain()
    }

    func setupSwapchain() throws {
        guard let window = window else {
            return
        }

        let windowSize = window.bounds.size
        let displayScale = window.nativeWindow.displayScale
        let desiredSize = VkExtent2D(width: UInt32(windowSize.width * displayScale), height: UInt32(windowSize.height * displayScale))
        
        try surface.refreshCapabilities()
        let capabilities = surface.capabilities
        let minSize = capabilities.minImageExtent
        let maxSize = capabilities.maxImageExtent

        let width = max(min(desiredSize.width, maxSize.width), minSize.width)
        let height = max(min(desiredSize.height, maxSize.height), minSize.height)
        // let width = desiredSize.width
        // let height = desiredSize.height
        
        let size = VkExtent2D(width: width, height: height)

        swapchain = try Swapchain(device: device, surface: surface, desiredPresentMode: .fifo, size: size, graphicsQueue: renderStack.queues.graphics, presentationQueue: presentationQueue, usage: .colorAttachment, compositeAlpha: .opaque, oldSwapchain: oldSwapchain)

        textures = try swapchain.creteTextures()

        oldSwapchain = nil
    }
    
    func clearSwapchain() throws {
        textures.removeAll()
        layerRenderer.renderTargetsCache.clear()
        oldSwapchain = swapchain
        swapchain = nil
    }

    func grabNextTexture() throws -> (index: Int, texture: Texture) {
        let index = try swapchain.getNextImageIndex(semaphore: textureReadySemaphore)

        return (index: index, texture: textures[index])
    }

    @MainActor func grabNextTextureAsync() async throws -> (index: Int, texture: Texture) {
        var skipRecreation = false
        
        repeat {
            do {
                let index = try swapchain.getNextImageIndex(semaphore: textureReadySemaphore)

                return (index: index, texture: textures[index])
            } catch VulkanError.badResult(let errorCode) {
                if errorCode == .errorOutOfDate || errorCode == .suboptimal {
                    if skipRecreation == true {
                        throw VulkanError.badResult(errorCode)
                    }

                    try await recreateSwapchainAsync()

                    skipRecreation = true
                } else {
                    throw VulkanError.badResult(errorCode)
                }
            }
        } while !skipRecreation

        throw VulkanError.badResult(.errorOutOfDate)
    }

    @MainActor func recreateSwapchainAsync() async throws {
        if state == .invalidated {
            return
        }
        
        try clearSwapchain()
        try setupSwapchain()
    }

    @MainActor func prepareRenderContext() async throws {
        guard state == .preparingRenderContext else {
            return
        }

        try layerRenderer.buildRenderOperations()
    }

    func executeRenderOperations() async throws {
        guard state == .renderContextReady else {
            return
        }

        state = .preparingCommandBuffer

        try layerRenderer.performRenderOperations()
    }

    @MainActor func submit() async throws {
        try layerRenderer.submitCommandBuffer(waitSemaphores: [textureReadySemaphore], signalSemaphores: [commandBufferExecutionCompleteSemaphore], signalTimelineSemaphores: [timelineSemaphore], fence: fence)
    }

    @MainActor func present(index: Int) async throws {
        try presentationQueue.present(swapchains: [swapchain], waitSemaphores: [commandBufferExecutionCompleteSemaphore], imageIndices: [CUnsignedInt(index)])
    }

    func wait() async throws {
        try fence.wait()
    }

    func resetFence() async throws {
        try fence.reset()
    }

    @MainActor func prepareCommandBuffer() async throws {
        if state != .idle {
            return
        }

        // windowKeepAlive = window

        // stupid nvidia driver on X11. the resize event is processed by the driver much earlier than x11 sends resize events to application. this always results in invalid swapchain on first frame after x11 have already resized it's framebuffer, but have not sent the event to application. bad interprocess communication and lack of synchronization results in application-side hacks i.e. swapchain has to be recreated even before the actual window is resized and it's contents have been layed out

        state = .preparingRenderContext

        do {
            let (_, texture) = try await grabNextTextureAsync()

            if state == .invalidated {
                windowKeepAlive = nil
                return
            }

            try layerRenderer.setDestination(texture)

            try layerRenderer.beginFrame(atTime: 0)

            try await prepareRenderContext()

            if state == .invalidated {
                windowKeepAlive = nil
                return
            }

            state = .renderContextReady
        
            try await executeRenderOperations()

            if state == .invalidated {
                windowKeepAlive = nil
                return
            }
                
            let waitValue = try timelineSemaphore.value + 1

            try await submit()

            if state == .invalidated {
                windowKeepAlive = nil
                return
            }
        
            let _: Void = try await withUnsafeThrowingContinuation { continuation in
                do {
                    try renderStack.semaphoreWatcher.add(semaphore: timelineSemaphore, waitValue: waitValue, continuation: continuation)
                } catch {
                    continuation.resume(throwing: error)
                }
            }

            try await resetFence()

            try layerRenderer.endFrame()

            state = .idle
        } catch {
            windowKeepAlive = nil
            throw error
        }
    }

    @MainActor func asyncRender() async throws {
        if isRendering {
            return
        }

        if state != .idle {
            return
        }

        isRendering = true

        // windowKeepAlive = window

        // trying to recreate swapchain only once per render request. if it fails for the second time - frame is skipped assuming there will be new render request following. maybe not the best thing to do because it's like a hidden logic. will re-evaluate
        var skipRecreation = false

        // stupid nvidia driver on X11. the resize event is processed by the driver much earlier than x11 sends resize events to application. this always results in invalid swapchain on first frame after x11 have already resized it's framebuffer, but have not sent the event to application. bad interprocess communication and lack of synchronization results in application-side hacks i.e. swapchain has to be recreated even before the actual window is resized and it's contents have been layed out

        state = .preparingRenderContext

        while true {
            do {
                let (index, texture) = try await grabNextTextureAsync()

                try layerRenderer.setDestination(texture)

                try layerRenderer.beginFrame(atTime: 0)

                try await prepareRenderContext()

                state = .renderContextReady
        
                try await executeRenderOperations()

                state = .commandBufferReady

                let waitValue = try timelineSemaphore.value + 1

                try await submit()

                let _: Void = try await withUnsafeThrowingContinuation { continuation in
                    do {
                        try renderStack.semaphoreWatcher.add(semaphore: timelineSemaphore, waitValue: waitValue, continuation: continuation)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }

                try await resetFence()

                try await present(index: index)

                try layerRenderer.endFrame()

                isRendering = false

                state = .idle

                break
            } catch VulkanError.badResult(let errorCode) {
                if errorCode == .errorOutOfDate || errorCode == .suboptimal {
                    if skipRecreation == true {
                        isRendering = false
                        windowKeepAlive = nil
                        break
                    }

                    do {
                        try await recreateSwapchainAsync()
                    } catch {
                        isRendering = false
                        windowKeepAlive = nil
                        throw error
                    }

                    skipRecreation = true
                } else {
                    isRendering = false
                    windowKeepAlive = nil
                    throw VulkanError.badResult(errorCode)
                }
            } catch {
                isRendering = false
                windowKeepAlive = nil
                throw error
            }
        }
    }

    func render() throws {
        if isRendering {
            return
        }

        isRendering = true
        defer { isRendering = false }

        if recreateSwapchainOnNextRun {
            recreateSwapchainOnNextRun = false
            
            try clearSwapchain()
            try setupSwapchain()
        }

        // trying to recreate swapchain only once per render request. if it fails for the second time - frame is skipped assuming there will be new render request following. maybe not the best thing to do because it's like a hidden logic. will re-evaluate
        var skipRecreation = false

        // stupid nvidia driver on X11. the resize event is processed by the driver much earlier than x11 sends resize events to application. this always results in invalid swapchain on first frame after x11 have already resized it's framebuffer, but have not sent the event to application. bad interprocess communication and lack of synchronization results in application-side hacks i.e. swapchain has to be recreated even before the actual window is resized and it's contents have been layed out

        var index: Int?
        var texture: Texture?

        while skipRecreation == false {
            do {
                (index, texture) = try grabNextTexture()
                break
            } catch VulkanError.badResult(let errorCode) {
                if errorCode == .errorOutOfDate || errorCode == .suboptimal {
                    if skipRecreation == true {
                        recreateSwapchainOnNextRun = true
                        return
                    }

                    try clearSwapchain()
                    try setupSwapchain()

                    skipRecreation = true
                } else {
                    throw VulkanError.badResult(errorCode)
                }
            }
        }

        guard let index = index, let texture = texture else {
            return
        }

        do {
            try layerRenderer.setDestination(texture)

            try layerRenderer.beginFrame(atTime: 0)

            try layerRenderer.render(waitSemaphores: [textureReadySemaphore], signalSemaphores: [commandBufferExecutionCompleteSemaphore], fence: fence)

            try fence.wait()
            try fence.reset()

            try presentationQueue.present(swapchains: [swapchain], waitSemaphores: [commandBufferExecutionCompleteSemaphore], imageIndices: [CUnsignedInt(index)])

            try layerRenderer.endFrame()
        } catch VulkanError.badResult(let errorCode) {
            if errorCode == .errorOutOfDate || errorCode == .suboptimal {
                recreateSwapchainOnNextRun = true
            } else {
                throw VulkanError.badResult(errorCode)
            }
        }
    }

    internal func resetState(to state: State = .idle) {
        self.state = state
    }
}
