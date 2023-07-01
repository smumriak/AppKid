//
//  main.swift
//  vkthings
//
//  Created by Serhii Mumriak on 18.01.2022.
//

import Foundation
import ArgumentParser
import XMLCoder
import TinyFoundation
import VkThingsLib
import Yams

var defaultRegistryFilePath: String {
    get throws {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false

        #if os(Linux)
            let possibleLocations = [
                "/usr/share/vulkan/registry/vk.xml",
            ]
        #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            #error("FIX ME")
        #elseif os(Android)
            #error("FIX ME")
        #elseif os(Windows)
            #error("FIX ME")
        #endif

        for path in possibleLocations {
            if fileManager.fileExists(atPath: path, isDirectory: &isDirectory) && isDirectory.boolValue == false {
                return path
            }
        }

        throw VulkanStructureGenerator.Error.vulkanRegistryNotFound
    }
}

struct VulkanStructureGenerator: ParsableCommand {
    enum Error: Swift.Error {
        case vulkanRegistryNotFound
        case validUsageNotFound

        public var localizedDescription: String {
            switch self {
                case .vulkanRegistryNotFound:
                    return "Unable to find Vulkan registry directory in known locations. Is Vulkan SDK installed?"

                case .validUsageNotFound:
                    return "Unable to find validusage.json file under Vulkan registry directory. Is Vulkan SDK installed?"
            }
        }
    }

    enum GeneratedFileType: String, EnumerableFlag {
        case swiftStructs
        case swiftOptionSets
        case swiftEnums
        case cEnums
        case cOptionSets
        case swiftExtensions
    }

    @Argument(help: "Vulkan API registry file path")
    var registryFilePath: String = ""

    @Option(name: .shortAndLong, help: "Location of the output swift code file")
    var outputFilePath: String

    @Flag(help: "")
    var generatedFileType: GeneratedFileType

    @Flag(name: .shortAndLong)
    var force: Bool = false

    mutating func run() throws {
        if registryFilePath.isEmpty {
            registryFilePath = try defaultRegistryFilePath
        }

        let registryFileURL = URL(fileURLWithPath: registryFilePath, isDirectory: false)

        let needsGeneration: Bool = try {
            if force {
                return true
            } else {
                if FileManager.default.fileExists(atPath: outputFilePath) == false {
                    return true
                }
            }

            var metadataHeader: [String] = []
            var headerFound = false

            try String(contentsOfFile: outputFilePath).enumerateLines { line, stop in
                if line.starts(with: kMetadataSerializedPrefix) {
                    headerFound = true
                    metadataHeader.append(line)
                } else if headerFound == true {
                    stop = true
                }
            }
            
            if metadataHeader.isEmpty {
                return true
            }

            let metadataString = metadataHeader
                .map { $0.dropFirst(kMetadataSerializedPrefix.count) }
                .joined(separator: .newline)

            let yamlDecoder = YAMLDecoder()

            let metadataVersion = try yamlDecoder.decode(MetadataHeaderVersionCheck.self, from: metadataString)

            let validUsage = try VulkanValidUsage(registryFileURL: registryFileURL)

            switch metadataVersion.version {
                case .v1:
                    let metadata = try yamlDecoder.decode(MetadataHeader_v1.self, from: metadataString)

                    return metadata.vulkanVersion != validUsage.versionInfo.apiVersion
            }
        }()

        if needsGeneration == false {
            return
        }

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

        let parser = try Parser(registryFileURL: registryFileURL)
        try generator.write(to: outputFileURL, parser: parser)
    }
}

VulkanStructureGenerator.main()
