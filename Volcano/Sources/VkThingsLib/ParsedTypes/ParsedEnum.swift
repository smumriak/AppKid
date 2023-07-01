//
//  ParsedEnum.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public struct ParsedEnum: VulkanType {
    public struct Case: VulkanType {
        public let name: String
        public let value: String?
        public var cDefines: [String] = []
        public var swiftDefines: [String] = []

        public init(name: String, value: String?) {
            self.name = name
            self.value = value
        }
    }

    public var name: String
    public var cDefines: [String] = []
    public var swiftDefines: [String] = []
    public var cases: [Case] = []
    public let isOptionSet: Bool
    
    public init(enumerationDefinition: EnumerationDefinition) {
        assert(enumerationDefinition.subtype == .enumeration || enumerationDefinition.subtype == .bitmask)

        isOptionSet = enumerationDefinition.subtype == .bitmask

        name = enumerationDefinition.name
 
        cases = enumerationDefinition.cases.map {
            Case(name: $0.name, value: $0.value)
        }
    }

    public func convenienceCasesString(tags: [TagDefinition]) -> String {
        let enumTagToStrip = name.tagSuffix(tags: tags, withoutUnderscore: true, caseSensitive: false)
    
        var result: [String] = []

        result += swiftProtectiveIfs

        result.append(indentation + "public extension \(name) {")

        result += cases.compactMap {
            let strings = $0.convenienceGenerated(enumerationName: name, isOptionSet: isOptionSet, tags: tags, enumTagToStrip: enumTagToStrip)

            if strings.isEmpty {
                return nil
            }

            return strings.map {
                indentation + kIndentationUnit + $0
            }
            .joined(separator: .newline)
        }

        result.append(indentation + "}")

        result += swiftProtectiveEndifs

        return result.joined(separator: .newline)
    }

    public var cDeclaration: String {
        var result: [String] = []

        result += cProtectiveIfs

        if isOptionSet {
            result += [indentation + "AK_EXISTING_OPTIONS(\(name));"]
        } else {
            result += [indentation + "AK_EXISTING_ENUM(\(name));"]
        }

        result += cProtectiveEndifs
        return result.joined(separator: .newline)
    }
}

public extension ParsedEnum.Case {
    func convenienceGenerated(enumerationName: String, isOptionSet: Bool, tags: [TagDefinition], enumTagToStrip: String? = nil) -> [String] {
        let brokenNames: Set<String> = [
            "VK_SURFACE_COUNTER_VBLANK_EXT",
            "VK_PIPELINE_CREATE_DISPATCH_BASE",
            "VK_PERFORMANCE_COUNTER_DESCRIPTION_PERFORMANCE_IMPACTING_KHR",
            "VK_PERFORMANCE_COUNTER_DESCRIPTION_CONCURRENTLY_IMPACTED_KHR",
            "VK_STRUCTURE_TYPE_SURFACE_CAPABILITIES2_EXT",
        ]

        if brokenNames.contains(name) {
            return []
        }

        // if isOptionSet == true, let value = value, value == "0" {
        //     return []
        // }

        var result = name
            .replacingOccurrences(of: "_1D", with: "_ONE_DIMENSION")
            .replacingOccurrences(of: "_2D", with: "_TWO_DIMENSIONS")
            .replacingOccurrences(of: "_3D", with: "_THREE_DIMENSIONS")
            .replacingOccurrences(of: "_SRC", with: "_SOURCE")
            .replacingOccurrences(of: "_DST", with: "_DESTINATION")
            
        if isOptionSet {
            var withoutTag = result.strippingTagSuffix(tags: tags, withoutUnderscore: false)
            let tag = result.dropFirst(withoutTag.count)

            if withoutTag.hasSuffix("_BIT") {
                withoutTag = String(withoutTag.dropLast(4))
            }

            result = withoutTag + tag
        }

        result = result.camelcased(capitalizeFirst: true)

        var prefixToRemove = enumerationName
            .strippingTagSuffix(tags: tags, withoutUnderscore: true)

        if isOptionSet, let range = prefixToRemove.range(of: "FlagBits") {
            prefixToRemove.removeSubrange(range)
        }

        prefixToRemove = prefixToRemove.commonPrefix(with: result)

        result = String(result.dropFirst(prefixToRemove.count))

        if enumerationName == "VkFormat" {
            result = result.replacingOccurrences(of: "Unorm", with: "UNorm")
                .replacingOccurrences(of: "Snorm", with: "SNorm")
                .replacingOccurrences(of: "Uint", with: "UInt")
                .replacingOccurrences(of: "Sint", with: "SInt")
                .replacingOccurrences(of: "Uscaled", with: "UScaled")
                .replacingOccurrences(of: "Sscaled", with: "SScaled")
                .replacingOccurrences(of: "Ufloat", with: "UFloat")
                .replacingOccurrences(of: "Sfloat", with: "SFloat")
                .replacingOccurrences(of: "Sfloat", with: "SFloat")

                .replacingOccurrences(of: "R([0-9])", with: "r$1", options: .regularExpression)
                .replacingOccurrences(of: "G([0-9])", with: "g$1", options: .regularExpression)
                .replacingOccurrences(of: "B([0-9])", with: "b$1", options: .regularExpression)
                .replacingOccurrences(of: "A([0-9])", with: "a$1", options: .regularExpression)

                .replacingOccurrences(of: "rgb", with: "RGB", options: .caseInsensitive)
                .replacingOccurrences(of: "rgba", with: "RGBA", options: .caseInsensitive)
        }

        if isOptionSet && result.strippingTagSuffix(tags: tags, withoutUnderscore: true, caseSensitive: false).lowercased() == "none" {
            return []
        }

        if let enumTagToStrip = enumTagToStrip, result.lowercased().hasSuffix(enumTagToStrip.lowercased()) {
            result = String(result.dropLast(enumTagToStrip.count))
        }

        let digitsPrefix = result.prefix { $0.isNumber }

        if digitsPrefix.isEmpty == false {
            result = String(digitsPrefix).spelledOutNumberCamelcasedString + result.dropFirst(digitsPrefix.count)
        }

        result.lowercaseFirst()

        let keywords: Set<String> = [
            "repeat",
            "static",
            "default",
            "import",
        ]

        if keywords.contains(result) {
            result = "`" + result + "`"
        }

        var resultingArray: [String] = []
        resultingArray += swiftProtectiveIfs

        let adjustedName: String

        if isOptionSet == true, let value = value, value == "0" {
            adjustedName = "[]"
        } else {
            adjustedName = ".\(name)"
        }

        resultingArray += [indentation + "static let \(result): \(enumerationName) = \(adjustedName)"]

        resultingArray += swiftProtectiveEndifs

        return resultingArray
    }
}
