//
//  main.swift
//  vkthings
//
//  Created by Serhii Mumriak on 18.01.2022.
//

import Foundation
import ArgumentParser
@_exported import XMLCoder
import TinyFoundation
import VkThingsLib

struct VulkanStructureGenerator: ParsableCommand {
    enum GeneratedFileType: String, EnumerableFlag {
        case swiftStructs
        case swiftOptionSets
        case swiftEnums
        case cEnums
        case cOptionSets
        case swiftExtensions
    }

    @Argument(help: "Vulkan API registry file path")
    var registryFilePath: String = "/usr/share/vulkan/registry/vk.xml"

    @Option(name: .shortAndLong, help: "Location of the output swift code file")
    var outputFilePath: String

    @Flag(help: "")
    var generatedFileType: GeneratedFileType

    func run() throws {
        let generator: Generator

        switch generatedFileType {
            case .swiftStructs:
                generator = SwiftStructsGenerator()

            case .swiftEnums:
                generator = SwiftEnumsGenerator()

            case .swiftOptionSets:
                generator = SwiftOptionSetsGenerator()

            case .cEnums:
                generator = CEnumsGenerator(headerName: "VulkanEnums")

            case .cOptionSets:
                generator = COptionSetsGenerator(headerName: "VulkanOptionSets")

            case .swiftExtensions:
                generator = SwiftExtensionsGenerator()
        }
        
        let outputFileURL = URL(fileURLWithPath: outputFilePath, isDirectory: false)

        let parser = try Parser(registryFilePath: registryFilePath)
        try generator.write(to: outputFileURL, parser: parser)
    }
}

VulkanStructureGenerator.main()
