//
//  VulkanViewController.swift
//  SwiftyFan
//
//  Created by Serhii Mumriak on 15.05.2020.
//

import Foundation
import CoreFoundation
import AppKid
import Volcano
import TinyFoundation
import CVulkan

class VulkanViewController: ViewController {
    var resizedNotificationToken: NSObjectProtocol? = nil
    var renderer: VulkanRenderer?

    deinit {
        if let notificationToken = resizedNotificationToken {
            NotificationCenter.default.removeObserver(notificationToken)
        }

        renderTimer.invalidate()
    }

    var frameStarted = CFAbsoluteTimeGetCurrent()
    var frameFinished = CFAbsoluteTimeGetCurrent()

    var swapchainStarted = CFAbsoluteTimeGetCurrent()
    var swapchainFinished = CFAbsoluteTimeGetCurrent()

    internal lazy var renderTimer: Timer = {
        return Timer(timeInterval: 1 / 30.0, repeats: true) { [weak self] _ in
            self?.cycle()
        }
    }()

    internal func cycle() {
        do {
            var happyFrame = false
            repeat {
                do {
                    self.frameStarted = CFAbsoluteTimeGetCurrent()
                    try self.renderer?.render()
                    self.frameFinished = CFAbsoluteTimeGetCurrent()
                    happyFrame = true
                } catch VulkanError.badResult(let errorCode) {
                    if errorCode == VK_ERROR_OUT_OF_DATE_KHR {
                        self.swapchainStarted = CFAbsoluteTimeGetCurrent()
                        try self.renderer?.clearSwapchain()
                        try self.renderer?.setupSwapchain()
                        self.swapchainFinished = CFAbsoluteTimeGetCurrent()
                        self.view.window?.nativeWindow.rendererResized = true
                    } else {
                        throw VulkanError.badResult(errorCode)
                    }
                }
            } while happyFrame == false
        } catch {
            fatalError("Failed to render with error: \(error)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        RunLoop.current.add(renderTimer, forMode: .common)

        resizedNotificationToken = NotificationCenter.default.addObserver(forName: .windowDidResize, object: nil, queue: nil) { [weak self] _ in
            self?.cycle()
        }
    }

    var renderStack: VulkanRenderStack!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let window = view.window else { return }
        do {
            let renderStack = try VulkanRenderStack()
            let renderer = try VulkanRenderer(window: window, renderStack: renderStack)
            try renderer.setupSwapchain()
            try renderer.render()

            self.renderStack = renderStack
            self.renderer = renderer
        } catch {
            fatalError("Failed to render with error: \(error)")
        }
    }
}
