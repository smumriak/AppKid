//
//  SwiftExtensionsGenerator.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public struct SwiftExtensionsGenerator: SwiftFileGenerator {
    public let license: String = Templates.vulkanSwiftExtensionsLicense
    
    public init() {}
    
    public func resultString(with parser: __shared Parser) throws -> String {
        var result: [String] = try [header(from: parser)]
                
        result += [
            "",
            foundation,
            tinyFoundation,
            "",
        ]

        result += ["public enum InstanceExtension: String {"]

        result += parser.instanceExtensions
            .map { $0.1.caseName(tags: parser.registry.tags.elements) }
            .sorted { $0 < $1 }
            .map { kIndentationUnit + $0 }

        result += [
            "}",
            "",
        ]

        result += ["public enum DeviceExtension: String {"]

        result += parser.deviceExtensions
            .map { $0.1.caseName(tags: parser.registry.tags.elements) }
            .sorted { $0 < $1 }
            .map { kIndentationUnit + $0 }

        result += [
            "}",
            "",
        ]

        return result.joined(separator: .newline)
    }
}
