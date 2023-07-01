//
//  SwiftStructsGenerator.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public struct SwiftStructsGenerator: SwiftFileGenerator {
    public let license: String = Templates.vulkanSwiftStructuresLicense
    
    public init() {}
    
    public func resultString(with parser: __shared Parser) throws -> String {
        var result: [String] = try [header(from: parser)]

        result += [
            "",
            tinyFoundation,
            "",
        ]

        result += parser.structures.map { $0.value }
            .sorted { $0.name < $1.name }
            .flatMap {
                [
                    $0.exportString,
                    $0.vulkanStructureExtensionString,
                    "",
                ]
            }
                    
        return result.joined(separator: .newline)
    }
}
