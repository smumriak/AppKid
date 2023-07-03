//
//  SwiftOptionSetsGenerator.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public struct SwiftOptionSetsGenerator: SwiftFileGenerator {
    public let license: String = Templates.vulkanSwiftOptionSetsLicense
    
    public init() {}
    
    public func resultString(with parser: __shared Parser) throws -> String {
        var result: [String] = try [header(from: parser)]

        result += [
            tinyFoundation,
            "",
        ]

        result += parser.optionSets.map { $0.value }
            .filter { $0.cases.isEmpty == false }
            .sorted { $0.name < $1.name }
            .flatMap {
                [
                    $0.exportString,
                    $0.convenienceCasesString(tags: parser.registry.tags.elements),
                    "",
                ]
            }

        try result.append(footer(from: parser))

        return result.joined(separator: .newline)
    }
}
