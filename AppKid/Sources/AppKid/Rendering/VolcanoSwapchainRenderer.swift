//
//  VolcanoSwapchainRenderer.swift
//  AppKid
//
//  Created by Serhii Mumriak on 23.08.2020.
//

internal let kMultisamplingEnabled: Bool = ProcessInfo.processInfo.environment["APPKID_MULTISAMPLED_RENDERING"] != nil

import Foundation
import CoreFoundation
import TinyFoundation
@_spi(AppKid) import ContentAnimation
import Volcano

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
    internal var aliasingTextures: [Texture] = []
    internal var swapchainTextures: [Texture] = []

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

        swapchain = try Swapchain(device: device, surface: surface, desiredPresentModes: [.mailbox, .fifo], size: size, graphicsQueue: renderStack.queues.graphics, presentationQueue: presentationQueue, usage: .colorAttachment, compositeAlpha: .opaque, oldSwapchain: oldSwapchain)

        swapchainTextures = try swapchain.createTextures()

        let textureDescriptor = TextureDescriptor.texture2DDescriptor(pixelFormat: swapchain.imageFormat, width: Int(swapchain.size.width), height: Int(swapchain.size.height), mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        textureDescriptor.tiling = .optimal
        textureDescriptor.setAccessQueues([renderStack.queues.graphics, renderStack.queues.transfer])
        if kMultisamplingEnabled {
            textureDescriptor.sampleCount = .four
        } else {
            textureDescriptor.sampleCount = .one
        }
        
        if kMultisamplingEnabled {
            aliasingTextures = try swapchainTextures.map { _ in
                try device.createTexture(with: textureDescriptor)
            }
        }

        oldSwapchain = nil
    }
    
    func clearSwapchain() throws {
        swapchainTextures.removeAll()
        layerRenderer.renderTargetsCache.clear()
        oldSwapchain = swapchain
        swapchain = nil
    }

    func grabNextTexture() throws -> (index: Int, texture: Texture) {
        let index = try swapchain.getNextImageIndex(semaphore: textureReadySemaphore)

        return (index: index, texture: swapchainTextures[index])
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

        // smumriak: trying to recreate swapchain only once per render request. if it fails for the second time - frame is skipped assuming there will be new render request following. maybe not the best thing to do because it's like a hidden logic. will re-evaluate
        var skipRecreation = false

        // smumriak: stupid nvidia driver on X11. the resize event is processed by the driver much earlier than x11 sends resize events to application. this always results in invalid swapchain on first frame after x11 have already resized it's framebuffer, but have not sent the event to application. bad interprocess communication and lack of synchronization results in application-side hacks i.e. swapchain has to be recreated even before the actual window is resized and it's contents have been layed out

        // smumriak: stupidity of X11 and different window managers sometimes keeps me awake at night. the code below works ok-ish on Nvidia GPU with X11 under Gnome. by ok-ish i mean there's no any artifacts rendered during resize and there's no flickering of any kind. the very same code does not work this well with Mesa driver on Intel GPU: when window is resized to bigger size there is a visible artifact presented on the right and bottom borders of the window. first it's a black line, but if you resize fast enough to make compositor render more stuff - you would see parts of framebuffer from other window, people on the internet call that "palinopsia". this thing does not happen on jetson nano with KDE. it's possible to eliminate this thing via setting a background color on X11 window (which for some reason is called "background pixel"), but it by itself introduces a flickering of the whole window during window resize on all of tested platforms. this is arguably worse. also signal, bitward and chrome itself have exactly same problem of "palinopsia" on resize. yay
        
        var index: Int?
        var swapchainTexture: Texture?

        while skipRecreation == false {
            do {
                (index, swapchainTexture) = try grabNextTexture()
                break
            } catch VulkanError.badResult(let errorCode) {
                if errorCode == .errorOutOfDateKhr || errorCode == .suboptimalKhr {
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

        guard let index = index, let swapchainTexture = swapchainTexture else {
            return
        }

        do {
            if kMultisamplingEnabled {
                let aliasingTexture = aliasingTextures[index]
                try layerRenderer.setDestination(target: aliasingTexture, resolve: swapchainTexture)
            } else {
                try layerRenderer.setDestination(target: swapchainTexture)
            }

            try layerRenderer.beginFrame(atTime: 0)

            try layerRenderer.render(waitSemaphores: [textureReadySemaphore], signalSemaphores: [commandBufferExecutionCompleteSemaphore], fence: fence)

            try fence.wait()
            try fence.reset()

            try presentationQueue.present(swapchains: [swapchain], waitSemaphores: [commandBufferExecutionCompleteSemaphore], imageIndices: [CUnsignedInt(index)])

            try layerRenderer.endFrame()
        } catch VulkanError.badResult(let errorCode) {
            if errorCode == .errorOutOfDateKhr || errorCode == .suboptimalKhr {
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
