//
//  VkThingsCommandPlugin.swift
//  Volcano
//
//  Created by Serhii Mumriak on 03.07.2023
//

import PackagePlugin
import Foundation

enum Vulkan {
    struct ValidUsage: Codable {
        let versionInfo: VersionInfo
        public enum CodingKeys: String, CodingKey {
            case versionInfo = "version info"
        }
    }

    struct VersionInfo: Codable {
        public let apiVersion: String
        public enum CodingKeys: String, CodingKey {
            case apiVersion = "api version"
        }
    }
}

@main
struct VkThingsCommandPlugin: CommandPlugin {
    func performCommand(
        context: PluginContext,
        arguments: [String]
    ) throws {
        // yea, this is shitcode because swiftpm plugins can not have any dependencies

        let swiftFiles = [
            (name: "VulkanStructureConformance", type: "--swift-structs"),
            (name: "VulkanEnums", type: "--swift-enums"),
            (name: "VulkanOptionSets", type: "--swift-option-sets"),
            (name: "VulkanExtensionsNames", type: "--swift-extensions"),
        ]
        
        let volcanoTarget = try context.package.targets(named: ["Volcano"]).first!

        let vkthings = try context.tool(named: "vkthings")
        let vkthingsURL = URL(fileURLWithPath: vkthings.path.string)

        var argumentsExtractor = ArgumentExtractor(arguments)
        let registryArgument = argumentsExtractor.extractOption(named: "registry")
        if registryArgument.count != 1 {
            Diagnostics.error("You need to supply one and only one option for registry path via --registry option")
        }
        let registryDirectoryPath = registryArgument.first!
        let registryDirectoryURL = URL(fileURLWithPath: registryDirectoryPath, isDirectory: true)
        let registryFileURL = registryDirectoryURL.appendingPathComponent("vk.xml")
        
        let version = try argumentsExtractor.extractOption(named: "vulkan-version").first.map { $0 } ?? {
            let validUsageURL = registryDirectoryURL.appendingPathComponent("validusage.json")
            let validUsage = try JSONDecoder().decode(Vulkan.ValidUsage.self, from: Data(contentsOf: validUsageURL))
            return validUsage.versionInfo.apiVersion
        }()

        let swiftOutputDirectoryURL = URL(fileURLWithPath: volcanoTarget.directory.string, isDirectory: true).appendingPathComponent("_Generated").appendingPathComponent(version, isDirectory: true)

        try FileManager.default.createDirectory(at: swiftOutputDirectoryURL, withIntermediateDirectories: true)

        try swiftFiles.map {
            (url: swiftOutputDirectoryURL.appendingPathComponent("\($0.name)_\(version).swift"), type: $0.type)
        }
        .map {
            var result = [
                registryFileURL.absoluteURL.path,
                "-o",
                $0.url.absoluteURL.path,
                $0.type,
                "--force",
            ]

            if version.isEmpty == false {
                result += [
                    "--vulkan-version",
                    version,
                ]
            }

            return result
        }
        .forEach {
            let process = try Process.run(vkthingsURL, arguments: $0)
            process.waitUntilExit()

            Diagnostics.remark("Running vkthings \($0.joined(separator: " "))")

            if process.terminationStatus != 0 {
                Diagnostics.error("vkthings failed miserably")
            } else {
                print("Successfully finished running vkthings")
            }
        }
    }
}
