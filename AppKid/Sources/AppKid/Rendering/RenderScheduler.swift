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
    // private var lastRenderStartedDates: [Int: Date] = [:]
    // private var lastRenderFinishedDate: [Int: Date] = [:]

    private var presentationQueues: [Int: Queue] = [:]
    private let renderStack: VolcanoRenderStack
    private var observer: CFRunLoopObserver? = nil

    internal let submitSemaphore: Volcano.Semaphore
    internal let submitTimelineSemaphore: TimelineSemaphore
    
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

        let renderer = try VolcanoSwapchainRenderer(window: window, surface: surface, presentationQueue: presentationQueue, renderStack: VolcanoRenderStack.global)
        syncRenderers[window.windowNumber] = renderer
    }

    func removeRenderer(for window: Window) throws {
        let windowNumber = window.windowNumber

        // syncRenderers[windowNumber]?.resetState(to: .invalidated)
        syncRenderers.removeValue(forKey: windowNumber)

        presentationQueues.removeValue(forKey: windowNumber)
    }

    func windowWasResized(_ window: Window) {
        let renderer = syncRenderers[window.windowNumber]
        renderer?.recreateSwapchainOnNextRun = true
    }

    func sendRenderRequests() {
        // let currentDate = Date()
        // if currentDate.timeIntervalSince(lastRenderFinishedDate) < 1 / 60.0 || currentDate.timeIntervalSince(lastRenderStartedDate) < 1 / 60.0 {
        //     return
        // }

        do {
            try self.sendSyncRenderRequests()
        } catch {
            fatalError("Failed to render with error: \(error)")
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
}
