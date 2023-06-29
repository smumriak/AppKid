//
//  SwiftStructsGenerator.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public struct SwiftStructsGenerator: SwiftFileGenerator {
    public init() {}
    
    public func resultString(with parser: Parser) throws -> String {
        var result: [String] = []

        result += [
            Templates.vulkanSwiftStructuresLicense,
            tinyFoundation,
        ]

        result += parser.structures.map { $0.value }
            .sorted {
                $0.name < $1.name
            }
            .flatMap {
                [
                    $0.exportString,
                    $0.vulkanStructureExtensionString,
                ]
            }
                    
        return result.joined(separator: "\n\n")
    }
}
