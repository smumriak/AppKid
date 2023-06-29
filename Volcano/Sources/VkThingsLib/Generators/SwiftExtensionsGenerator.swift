//
//  SwiftExtensionsGenerator.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public struct SwiftExtensionsGenerator: SwiftFileGenerator {
    public init() {}
    
    public func resultString(with parser: Parser) throws -> String {
        var result: [String] = []
                
        result += [
            Templates.vulkanSwiftExtensionsLicense,
            "",
            "import Foundation",
            "import TinyFoundation",
            "",
            "",
        ]

        result += ["public enum InstanceExtension: String {"]

        result += parser.instanceExtensions.map {
            $0.1.caseName(tags: parser.registry.tags.elements)
        }

        result += ["}", ""]

        result += ["public enum DeviceExtension: String {"]

        result += parser.deviceExtensions.map {
            $0.1.caseName(tags: parser.registry.tags.elements)
        }

        result += ["}", ""]

        return result.joined(separator: "\n")
    }
}
