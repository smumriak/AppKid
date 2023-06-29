//
//  ParsedExtension.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public protocol ParsedExtension {
    var name: String { get }
    var version: String { get }
    var cDefines: [String] { get }
    var swiftDefines: [String] { get }
}

public extension ParsedExtension {
    func caseName(tags: [TagDefinition]) -> String {
        var result = name
            .strippingVKPrevix

        let tagPrefix = result.tagPrefix(tags: tags)

        result = result.strippingTagPrefix(tags: tags)
            .camelcased

        let digitsPrefix = result.prefix { $0.isNumber }

        if digitsPrefix.isEmpty == false {
            result = String(digitsPrefix).spelledOutNumberCamelcasedString + result.dropFirst(digitsPrefix.count)
        }

        result.lowercaseFirst()

        if let tagPrefix = tagPrefix {
            result += tagPrefix.camelcased(capitalizeFirst: true)
        }

        return "case \(result) = \"\(name)\""
    }
}
