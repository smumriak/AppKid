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
import Glibc

internal class RenderScheduler {
    private var renderers: [Int: VolcanoSwapchainRenderer1] = [:]
    private var presentationQueues: [Int: Queue] = [:]
    let renderStack: VolcanoRenderStack
    var observer: CFRunLoopObserver? = nil

    internal let submitSemaphore: Volcano.Semaphore
    internal let submitTimelineSemaphore: TimelineSemaphore

    @Synchronized internal var lastRenderStartedDate = Date(timeIntervalSinceReferenceDate: 0)
    @Synchronized internal var lastRenderFinishedDate = Date(timeIntervalSinceReferenceDate: 0)
    
    deinit {
        if let observer = observer {
            CFRunLoopObserverInvalidate(observer)
        }
    }

    init(renderStack: VolcanoRenderStack, runLoop: CFRunLoop) throws {
        self.renderStack = renderStack
        submitSemaphore = try Semaphore(device: renderStack.device)
        submitTimelineSemaphore = try TimelineSemaphore(device: renderStack.device, initialValue: 0)

        let activity: CFRunLoopActivity = [.beforeWaiting]
        let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, activity.rawValue, true, CFIndex.max) { [unowned self] observer, activity in
            // let currentDate = Date()
            // if currentDate.timeIntervalSince(lastRenderFinishedDate) < 1 / 60.0 || currentDate.timeIntervalSince(lastRenderStartedDate) < 1 / 60.0 {
            //     return
            // }

            Task(priority: .userInitiated) { @MainActor in
                do {
                    try await self.sendRenderRequests()
                } catch {
                    fatalError("Failed to render with error: \(error)")
                }
            }
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

        let renderer = try VolcanoSwapchainRenderer1(window: window, surface: surface, presentationQueue: presentationQueue, renderStack: VolcanoRenderStack.global)
        renderers[window.windowNumber] = renderer
    }

    func removeRenderer(for window: Window) throws {
        renderers.removeValue(forKey: window.windowNumber)
        presentationQueues.removeValue(forKey: window.windowNumber)
    }

    @MainActor func sendRenderRequests() async throws {
        let renderesToRecord = renderers.values.filter {
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

        lastRenderStartedDate = Date()

        do {
            let recordedFrames: [VolcanoSwapchainRenderer1.RecordedFrame] = try await withThrowingTaskGroup(of: VolcanoSwapchainRenderer1.RecordedFrame?.self) { @MainActor taskGroup in
                renderesToRecord.forEach { renderer in
                    taskGroup.addTask {
                        var recordFrameSteps: VolcanoSwapchainRenderer1.RecordFrameSteps = [.commandBuffer]

                        if renderer.state == .idle {
                            recordFrameSteps.insert(.operations)
                        }

                        let result = try await renderer.recordFrame(steps: recordFrameSteps)

                        return result
                    }
                }

                // try await taskGroup.waitForAll()

                return try await taskGroup
                    .compactMap { $0 }
                    .reduce([]) {
                        $0 + [$1]
                    }
            }

            if recordedFrames.isEmpty {
                // lastRenderFinishedDate = Date()
                return
            }

            let waitValue = try submitTimelineSemaphore.value + 1

            try await submit(recordedFrames: recordedFrames)

            try await present(recordedFrames: recordedFrames)
      
            let _: Void = try await withUnsafeThrowingContinuation { continuation in
                do {
                    try renderStack.semaphoreWatcher.add(semaphore: submitTimelineSemaphore, waitValue: waitValue, continuation: continuation)
                } catch {
                    continuation.resume(throwing: error)
                }
            }

            lastRenderFinishedDate = Date()

            renderesToRecord.forEach {
                $0.resetState()
            }
        } catch VulkanError.badResult(let errorCode) {
            if errorCode == .errorOutOfDate {
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
        let signalSemaphores = recordedFrames.map { $0.presentationFinishedSemaphore }

        var descriptor = SubmitDescriptor(commandBuffers: commandBuffers)
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
            let waitSemaphores = frames.map { $0.presentationFinishedSemaphore }

            try queue.present(swapchains: swapchains, waitSemaphores: waitSemaphores, imageIndices: textureIndices)
        }
    }
}
