//
//  VulkanCodegen.swift
//  vulkancodegen
//
//  Created by Serhii Mumriak on 03.07.2023
//

import Cuisine
import CuisineArgumentParser
import ArgumentParser
import SemanticVersion
import Foundation

@main
struct VulkanCodegen: CuisineParsableCommand {
    var pantry: Pantry = Pantry()

    @Option
    var minimalVersion: SemanticVersion

    @Option
    var maxPatch: UInt?

    @Option
    var outputDirectory: String = FileManager.default.currentDirectoryPath

    var versions: [SemanticVersion] {
        let maxPatch = maxPatch ?? minimalVersion.patchStrict

        return (minimalVersion.patchStrict...maxPatch).map {
            SemanticVersion(minimalVersion.major, minimalVersion.minorStrict, $0)
        }
    }

    var body: some Recipe {
        let version = versions.map {
            (
                $0,
                URL(string: "https://raw.githubusercontent.com/KhronosGroup/Vulkan-Docs/")!
                    .appendingPathComponent("v\($0)")
                    .appendingPathComponent("xml")
                    .appendingPathComponent("vk.xml")
            )
        }

        let tmpDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("vulkancodegen").absoluteURL

        // there's a race condition on file system somewhere. Cuisine is not very good with propagating errors yet, so for now it's sequential here
        ForEach(version, mode: .sequential) { version in
            let vulkanDirectory = tmpDirectory.appendingPathComponent("\(version.0)", isDirectory: true)

            ChDir(vulkanDirectory) {
                GetFile(version.1)
            }
            ChDir(outputDirectory) {
                Print("Generating \(version.0)")
                Run("swift") {
                    "package"
                    "--allow-writing-to-package-directory"
                    "vkthings"
                    "--registry"
                    "\(vulkanDirectory.path)"
                    "--vulkan-version"
                    "\(version.0)"
                }
            }
        }
    }
}

extension SemanticVersion: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(argument)
    }
}
