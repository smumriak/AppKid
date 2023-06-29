//
//  COptionSetsGenerator.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public struct COptionSetsGenerator: CHeaderGenerator {
    public let headerName: String

    public init(headerName: String) {
        self.headerName = headerName
    }

    public func resultString(with parser: __shared Parser) throws -> String {
        var result: [String] = []

        result += [
            Templates.vulkanCOptionSetsLicense,
            top,
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
                    // $0.exportString,
                    $0.cDeclaration,
                ]
            }

        result += [
            bottom,
        ]

        return result.joined(separator: "\n")
    }
}