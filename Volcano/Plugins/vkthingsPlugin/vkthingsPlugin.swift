//
//  vkthingsPlugin.swift
//  Volcano
//
//  Created by Serhii Mumriak on 28.06.2023
//

import PackagePlugin
import Foundation

@main
struct VKThingsPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        // let string = try String(contentsOf: URL(fileURLWithPath: "/usr/include/vulkan/vulkan.h"))
        // print(string)
        return []
    }
}
