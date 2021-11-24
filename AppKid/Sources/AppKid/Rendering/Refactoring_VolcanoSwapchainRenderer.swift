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

// public enum VolcanoSwapchainRendererError: Error {
//     case noPresentationQueueFound
// }

internal class VolcanoSwapchainRenderer1 {
    internal enum State {
        case idle
        case requestSent
        case buildingRenderOperations
        case renderOperationsReady
        case recordingCommandBuffer
        case commandBufferReady
        case swapchainFailed
        case invalidated
    }

    internal struct RecordFrameSteps: OptionSet {
        var rawValue: Int

        init(rawValue: Int) {
            self.rawValue = rawValue
        }

        static let operations = RecordFrameSteps(rawValue: 1 << 0)
        static let commandBuffer = RecordFrameSteps(rawValue: 1 << 0)
    }

    internal struct RecordedFrame {
        let windowNumber: Int
        let commandBuffer: CommandBuffer
        let texture: Texture
        let textureIndex: Int
        let textureReadySemaphore: Volcano.Semaphore
        let commandBufferExecutionCompleteSemaphore: Volcano.Semaphore
        let swapchain: Swapchain
        let disposalBag: DisposalBag
    }

    private(set) weak var window: Window?
    @Synchronized private(set) var windowKeepAlive: Window?

    internal var recreateSwapchainOnNextRun: Bool = false

    let renderStack: VolcanoRenderStack
    let presentationQueue: Queue

    let layerRenderer: VolcanoRenderer

    let textureReadySemaphore: Volcano.Semaphore
    let commandBufferExecutionCompleteSemaphore: Volcano.Semaphore

    let commandPool: CommandPool

    internal fileprivate(set) var surface: Surface

    internal var device: Device { renderStack.device }
    internal var textures: [Texture] = []

    @Synchronized internal var state: State = .idle

    var oldSwapchain: Swapchain?
    var swapchain: Swapchain!

    deinit {
        try? clearSwapchain()
        oldSwapchain = nil
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
        
        try setupSwapchain()
    }

    func setupSwapchain() throws {
        guard let window = window else {
            return
        }

        let windowSize = window.bounds.size
        let displayScale = window.nativeWindow.displayScale
        let desiredSize = VkExtent2D(width: CUnsignedInt(windowSize.width * displayScale), height: CUnsignedInt(windowSize.height * displayScale))
        
        try surface.refreshCapabilities()
        // let capabilities = surface.capabilities
        // let minSize = capabilities.minImageExtent
        // let maxSize = capabilities.maxImageExtent

        // let width = max(min(desiredSize.width, maxSize.width), minSize.width)
        // let height = max(min(desiredSize.height, maxSize.height), minSize.height)
        let width = desiredSize.width
        let height = desiredSize.height
        
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

    internal func withSwapchainRecreation<T>(_ body: () async throws -> (T)) async throws -> T {
        var skipRecreation = false
        
        repeat {
            do {
                return try await body()
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

    @MainActor func grabNextTextureAsync(semaphore: Volcano.Semaphore) async throws -> (index: Int, texture: Texture) {
        try await withSwapchainRecreation {
            let index = try swapchain.getNextImageIndex(semaphore: semaphore)

            return (index: index, texture: textures[index])
        }
    }

    @MainActor func recreateSwapchainAsync() async throws {
        if state == .invalidated {
            return
        }
        
        try clearSwapchain()
        try setupSwapchain()
    }

    @MainActor func buildRenderOperations() async throws {
        guard state == .requestSent else {
            return
        }

        state = .buildingRenderOperations

        try layerRenderer.buildRenderOperations()
    }

    func recordCommandBuffer() async throws {
        guard [.renderOperationsReady, .swapchainFailed].contains(state) else {
            return
        }

        state = .recordingCommandBuffer

        try layerRenderer.performRenderOperations()
    }

    @MainActor func recordFrame(steps: RecordFrameSteps = [.operations, .commandBuffer]) async throws -> RecordedFrame? {
        if [.requestSent, .swapchainFailed].contains(state) == false {
            return nil
        }

        windowKeepAlive = window
        // palkovnik:TODO: Test how this behaves, is it really called after recordFrameImplementation
        // defer {
        //     windowKeepAlive = nil
        // }
            
        do {
            let result = try await recordFrameImplementation(steps: steps)

            windowKeepAlive = nil

            return result
        } catch {
            windowKeepAlive = nil

            throw error
        }
    }
    
    @MainActor fileprivate func recordFrameImplementation(steps: RecordFrameSteps) async throws -> RecordedFrame? {
        // stupid nvidia driver on X11. the resize event is processed by the driver much earlier than x11 sends resize events to application. this always results in invalid swapchain on first frame after x11 have already resized it's framebuffer, but have not sent the event to application. bad interprocess communication and lack of synchronization results in application-side hacks i.e. swapchain has to be recreated even before the actual window is resized and it's contents have been layed out

        guard let window = window else {
            return nil
        }

        let windowNumber = window.windowNumber

        let disposalBag = layerRenderer.renderContext.disposalBag
        disposalBag.append(window)

        let (textureIndex, texture) = try await grabNextTextureAsync(semaphore: textureReadySemaphore)

        if state == .invalidated {
            return nil
        }

        try layerRenderer.setDestination(texture)

        if steps.contains(.operations) {
            try layerRenderer.beginFrame(atTime: 0)

            try await buildRenderOperations()

            if state == .invalidated {
                return nil
            }

            state = .renderOperationsReady
        }

        if steps.contains(.commandBuffer) {
            try await recordCommandBuffer()

            if state == .invalidated {
                return nil
            }

            state = .commandBufferReady
        }
                
        // let waitValue = try timelineSemaphore.value + 1

        // try await submit()

        // if state == .invalidated {
        //     windowKeepAlive = nil
        //     return
        // }
        
        // let _: Void = try await withUnsafeThrowingContinuation { continuation in
        //     do {
        //         try renderStack.semaphoreWatcher.add(semaphore: timelineSemaphore, waitValue: waitValue, continuation: continuation)
        //     } catch {
        //         continuation.resume(throwing: error)
        //     }
        // }

        if steps.contains(.operations) {
            try layerRenderer.endFrame()
        }

        return try RecordedFrame(windowNumber: windowNumber,
                                 commandBuffer: layerRenderer.commandBuffer,
                                 texture: texture,
                                 textureIndex: textureIndex,
                                 textureReadySemaphore: textureReadySemaphore,
                                 commandBufferExecutionCompleteSemaphore: commandBufferExecutionCompleteSemaphore,
                                 swapchain: swapchain,
                                 disposalBag: disposalBag)
    }

    internal func resetState(to state: State = .idle) {
        self.state = state
    }
}
