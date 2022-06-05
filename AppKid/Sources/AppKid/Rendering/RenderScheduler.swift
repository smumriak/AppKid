//
//  RenderScheduler.swift
//  AppKid
//
//  Created by Serhii Mumriak on 11.08.2021.
//

import Foundation
import CoreFoundation
import TinyFoundation
@_spi(AppKid) import ContentAnimation
import Volcano

internal class RenderScheduler {
    private var syncRenderers: [Int: VolcanoSwapchainRenderer] = [:]
    private var asyncRenderers: [Int: VolcanoSwapchainRenderer1] = [:]
    // private var lastRenderStartedDates: [Int: Date] = [:]
    // private var lastRenderFinishedDate: [Int: Date] = [:]

    private var presentationQueues: [Int: Queue] = [:]
    private let renderStack: VolcanoRenderStack
    private var observer: CFRunLoopObserver? = nil
    private let async: Bool

    internal let submitSemaphore: Volcano.Semaphore
    internal let submitTimelineSemaphore: TimelineSemaphore
    
    deinit {
        if let observer = observer {
            CFRunLoopObserverInvalidate(observer)
        }
    }

    init(renderStack: VolcanoRenderStack, runLoop: CFRunLoop, async: Bool = false) throws {
        self.renderStack = renderStack
        self.async = async
        submitSemaphore = try Semaphore(device: renderStack.device)
        submitTimelineSemaphore = try TimelineSemaphore(device: renderStack.device, initialValue: 0)

        let activity: CFRunLoopActivity = [.afterWaiting]
        let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, activity.rawValue, true, CFIndex.max) { [unowned self] observer, activity in
            self.sendRenderRequests()
        }

        CFRunLoopAddObserver(runLoop, observer, CFRunLoopCommonModesConstant)

        self.observer = observer
    }

    func createRenderer(for window: Window) throws {
        let surface = try renderStack.createSurface(for: window)

        guard let presentationQueue = try renderStack.device.allQueues.first(where: { try surface.supportsPresenting(on: $0) }) else {
            throw VolcanoSwapchainRendererError.noPresentationQueueFound
        }

        presentationQueues[window.windowNumber] = presentationQueue

        if async {
            let renderer = try VolcanoSwapchainRenderer1(window: window, surface: surface, presentationQueue: presentationQueue, renderStack: VolcanoRenderStack.global)
            asyncRenderers[window.windowNumber] = renderer
        } else {
            let renderer = try VolcanoSwapchainRenderer(window: window, surface: surface, presentationQueue: presentationQueue, renderStack: VolcanoRenderStack.global)
            syncRenderers[window.windowNumber] = renderer
        }
    }

    func removeRenderer(for window: Window) throws {
        let windowNumber = window.windowNumber

        if async {
            // asyncRenderers[windowNumber]?.resetState(to: .invalidated)
            asyncRenderers.removeValue(forKey: windowNumber)
        } else {
            // syncRenderers[windowNumber]?.resetState(to: .invalidated)
            syncRenderers.removeValue(forKey: windowNumber)
        }

        presentationQueues.removeValue(forKey: windowNumber)
    }

    func windowWasResized(_ window: Window) {
        if async {
            // let renderer = asyncRenderers[window.windowNumber]
        } else {
            let renderer = syncRenderers[window.windowNumber]
            renderer?.recreateSwapchainOnNextRun = true
        }
    }

    func sendRenderRequests() {
        // let currentDate = Date()
        // if currentDate.timeIntervalSince(lastRenderFinishedDate) < 1 / 60.0 || currentDate.timeIntervalSince(lastRenderStartedDate) < 1 / 60.0 {
        //     return
        // }

        if self.async {
            Task(priority: .userInitiated) { @MainActor in
                do {
                    try await self.sendAsyncRenderRequests()
                } catch {
                    fatalError("Failed to render with error: \(error)")
                }
            }
        } else {
            do {
                try self.sendSyncRenderRequests()
            } catch {
                fatalError("Failed to render with error: \(error)")
            }
        }
    }

    func sendSyncRenderRequests() throws {
        let renderesToRecord = syncRenderers.values
            .filter {
                guard let window = $0.window else {
                    return false
                }

                return window.nativeWindow.syncRequested == false
                    && window.isMapped == true
                    && [.idle].contains($0.state)
            }

        if renderesToRecord.isEmpty {
            return
        }

        try renderesToRecord.forEach { renderer in
            renderer.window?.beforeFrameRender()
            
            try renderer.render()

            renderer.window?.afterFrameRender()
        }
    }

    @MainActor func sendAsyncRenderRequests() async throws {
        let renderesToRecord = asyncRenderers.values
            .filter {
                guard let window = $0.window else {
                    return false
                }

                return window.nativeWindow.syncRequested == false
                    && window.isMapped == true
                    && [.idle, .swapchainFailed].contains($0.state)
                // && window.dirtyRect != nil
            }

        if renderesToRecord.isEmpty {
            return
        }

        // lastRenderStartedDate = Date()

        do {
            let recordedFrames: [VolcanoSwapchainRenderer1.RecordedFrame] = try await withThrowingTaskGroup(of: VolcanoSwapchainRenderer1.RecordedFrame?.self) { @MainActor taskGroup in
                renderesToRecord.forEach { renderer in
                    let recordFrameSteps: VolcanoSwapchainRenderer1.RecordFrameSteps

                    if renderer.state == .idle {
                        recordFrameSteps = [.operations, .commandBuffer]
                    } else {
                        recordFrameSteps = .commandBuffer
                    }

                    renderer.state = .requestSent

                    taskGroup.addTask {
                        return try await renderer.recordFrame(steps: recordFrameSteps)
                    }
                }

                return try await taskGroup
                    .compactMap { $0 }
                    .reduce([]) {
                        $0 + [$1]
                    }
            }

            if recordedFrames.isEmpty {
                // lastRenderFinishedDate = Date()\
                return
            }

            let waitValue = try submitTimelineSemaphore.value + 1

            try await submit(recordedFrames: recordedFrames)

            try await present(recordedFrames: recordedFrames)
      
            let _: Void = try await withUnsafeThrowingContinuation { continuation in
                do {
                    // try renderStack.semaphoreWatcher.add(semaphore: submitTimelineSemaphore, waitValue: waitValue, continuation: continuation)
                    try renderStack.semaphoreWatcher.add(semaphore: submitTimelineSemaphore, waitValue: waitValue) {
                        continuation.resume()
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }

            // lastRenderFinishedDate = Date()

            renderesToRecord.forEach {
                $0.resetState()
            }
        } catch VulkanError.badResult(let errorCode) {
            if errorCode == .errorOutOfDateKhr || errorCode == .suboptimalKhr {
                renderesToRecord.forEach {
                    $0.resetState(to: .swapchainFailed)
                }
            } else {
                throw VulkanError.badResult(errorCode)
            }
        } catch {
            fatalError("Failed to render with error: \(error)")
        }
    }

    @MainActor func submit(recordedFrames: [VolcanoSwapchainRenderer1.RecordedFrame]) async throws {
        let commandBuffers = recordedFrames.map { $0.commandBuffer }
        let waitSemaphores = recordedFrames.map { $0.textureReadySemaphore }
        let signalSemaphores = recordedFrames.map { $0.commandBufferExecutionCompleteSemaphore }

        let descriptor = SubmitDescriptor(commandBuffers: commandBuffers)
        try waitSemaphores.forEach {
            try descriptor.add(.wait($0, stages: .colorAttachmentOutput))
        }

        try signalSemaphores.forEach {
            try descriptor.add(.signal($0))
        }

        try descriptor.add(.signal(submitTimelineSemaphore))

        try renderStack.queues.graphics.submit(with: descriptor)
    }

    @MainActor func present(recordedFrames: [VolcanoSwapchainRenderer1.RecordedFrame]) async throws {
        var submitBatchDictionary: [Queue: [VolcanoSwapchainRenderer1.RecordedFrame]] = [:]

        recordedFrames.forEach {
            guard let presentationQueue = presentationQueues[$0.windowNumber] else {
                return
            }

            submitBatchDictionary[presentationQueue] = (submitBatchDictionary[presentationQueue] ?? []) + [$0]
        }
        
        try submitBatchDictionary.forEach { queue, frames in
            let swapchains = frames.map { $0.swapchain }
            let textureIndices = frames.map { CUnsignedInt($0.textureIndex) }
            let waitSemaphores = frames.map { $0.commandBufferExecutionCompleteSemaphore }

            try queue.present(swapchains: swapchains, waitSemaphores: waitSemaphores, imageIndices: textureIndices)
        }
    }
}
