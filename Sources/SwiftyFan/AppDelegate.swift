//
//  AppDelegate.swift
//  SwiftyFan
//
//  Created by Serhii Mumriak on 20.04.2020.
//

import Foundation
import AppKid

@main
final class AppDelegate: NSObject, ApplicationDelegate {
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]? = nil) -> Bool {
        let window = Window(contentRect: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0))
        window.rootViewController = RootViewController()

        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ application: Application) -> Bool {
        #if os(Linux)
            return true
        #else
            return false
        #endif
    }
}
