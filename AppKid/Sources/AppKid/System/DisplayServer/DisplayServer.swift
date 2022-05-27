//
//  DisplayServer.swift
//  AppKid
//
//  Created by Serhii Mumriak on 21.04.2020.
//

import Foundation

internal protocol DisplayServer: AnyObject {
    var applicationName: String { get }
    var hasEvents: Bool { get set }

    init(applicationName appName: String)

    func activate()
    func deactivate()

    func serviceEventsQueue()
    func createNativeWindow(contentRect: CGRect, title: String) -> X11NativeWindow
}
