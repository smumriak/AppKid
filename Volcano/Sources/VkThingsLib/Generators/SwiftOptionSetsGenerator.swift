//
//  SwiftOptionSetsGenerator.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public struct SwiftOptionSetsGenerator: SwiftFileGenerator {
    public init() {}
    
    public func resultString(with parser: Parser) throws -> String {
        var result: [String] = []

        result += [
            Templates.vulkanSwiftOptionSetsLicense,
            tinyFoundation,
        ]

        result += parser.optionSets.map { $0.value }
            .sorted {
                $0.name < $1.name
            }
            .filter {
                $0.cases.isEmpty == false
            }
            .flatMap {
                [
                    $0.exportString,
                    $0.convenienceCasesString(tags: parser.registry.tags.elements),
                ]
            }

        result += [""]

        return result.joined(separator: "\n\n")
    }
}
