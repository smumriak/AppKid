//
//  VkThingsBuildToolPlugin.swift
//  Volcano
//
//  Created by Serhii Mumriak on 28.06.2023
//

import PackagePlugin
import Foundation

@main
struct VkThingsBuildToolPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        // smumriak: plugins can generate only swift code. sad
        let files = [
            (name: "VulkanStructureConformance-generated.swift", type: "--swift-structs"),
            (name: "VulkanEnums-generated.swift", type: "--swift-enums"),
            (name: "VulkanOptionSets-generated.swift", type: "--swift-option-sets"),
            (name: "VulkanExtensionsNames-generated.swift", type: "--swift-extensions"),
        ]

        // smumriak: it looks like build command works fine with empty inputFiles argument. so for now it's what is going to be used
        return try files.map {
            return try .buildCommand(
                displayName: "Generating \($0.name)",
                executable: context.tool(named: "vkthings").path,
                arguments: [
                    "-o",
                    context.pluginWorkDirectory.appending($0.name),
                    $0.type,
                ],
                inputFiles: [],
                outputFiles: [context.pluginWorkDirectory.appending($0.name)]
            )
        }
    }
}
