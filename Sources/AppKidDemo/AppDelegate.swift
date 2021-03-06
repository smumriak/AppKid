//
//  AppDelegate.swift
//  AppKidDemo
//
//  Created by Serhii Mumriak on 20.04.2020.
//

import Foundation
import AppKid

@main
final class AppDelegate: ApplicationDelegate {
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [Application.LaunchOptionsKey: Any]? = nil) -> Bool {
        let window = Window(contentRect: CGRect(x: 0.0, y: 0.0, width: 400.0, height: 400.0))
        window.title = "AppKid Sample Demo"
        window.rootViewController = RootViewController()
        // window.rootViewController = PlainViewController()

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
