//
//  main.swift
//  vkthings
//
//  Created by Serhii Mumriak on 18.01.2022.
//

import Foundation
import ArgumentParser
import XMLCoder

let spellOutNumberFormatter = NumberFormatter()
spellOutNumberFormatter.numberStyle = .spellOut
spellOutNumberFormatter.locale = Locale(identifier: "en_US")

let platformToDefine = [
    "xlib": "VOLCANO_PLATFORM_LINUX",
    "xlib_xrandr": "VOLCANO_PLATFORM_LINUX",
    "xcb": "VOLCANO_PLATFORM_LINUX",
    "wayland": "VOLCANO_PLATFORM_LINUX",
    "ios": "VOLCANO_PLATFORM_IOS",
    "macos": "VOLCANO_PLATFORM_MACOS",
    "android": "VOLCANO_PLATFORM_ANDROID",
    "win32": "VOLCANO_PLATFORM_WINDOWS",
]

struct Templates {
    static let outputStructureExtension =
        """
        extension <NAME>: VulkanOutStructure {
            public static let type: VkStructureType = <TYPE>
        }
        """

    static let inputStructureExtension =
        """
        extension <NAME>: VulkanInStructure {
            public static let type: VkStructureType = <TYPE>
        }
        """
}

struct RegistryDefinition: Codable, Equatable {
    let platforms: PlatformsContainer
    let types: TypesContainer
    let tags: TagsContainer
    let enumerations: [EnumerationDefinition]
    let features: [FeatureDefinition]
    let extensions: ExtensionsContainer

    enum CodingKeys: String, CodingKey {
        case platforms
        case types
        case tags
        case enumerations = "enums"
        case features = "feature"
        case extensions
    }
}

struct PlatformsContainer: Codable, Equatable {
    let elements: [PlatformDefinition]

    enum CodingKeys: String, CodingKey {
        case elements = "platform"
    }
}

struct PlatformDefinition: Codable, Equatable, DynamicNodeDecoding {
    let name: String
    let protectingDefine: String

    enum CodingKeys: String, CodingKey {
        case name
        case protectingDefine = "protect"
    }

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.name: return .attribute
            case CodingKeys.protectingDefine: return .attribute
            default: return .elementOrAttribute
        }
    }
}

struct TagsContainer: Codable, Equatable {
    let elements: [TagDefinition]

    enum CodingKeys: String, CodingKey {
        case elements = "tag"
    }
}

struct TagDefinition: Codable, Equatable {
    let name: String

    enum CodingKeys: String, CodingKey {
        case name
    }
}

struct ExtensionsContainer: Codable, Equatable {
    let elements: [ExtensionDefinition]

    enum CodingKeys: String, CodingKey {
        case elements = "extension"
    }
}

struct ExtensionDefinition: Codable, Equatable, DynamicNodeDecoding {
    enum ExtensionType: String, Codable, Equatable {
        case instance
        case device
    }

    enum Supported: String, Codable, Equatable {
        case vulkan
        case disabled
    }

    let name: String
    let number: String
    let extensionType: ExtensionType?
    let supported: Supported
    let requirements: [RequirementDefinition]?
    let platformName: String?

    enum CodingKeys: String, CodingKey {
        case name
        case number
        case extensionType = "type"
        case supported
        case requirements = "require"
        case platformName = "platform"
    }

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.name: return .attribute
            case CodingKeys.number: return .attribute
            case CodingKeys.extensionType: return .attribute
            case CodingKeys.supported: return .attribute
            case CodingKeys.requirements: return .element
            case CodingKeys.platformName: return .attribute
            default: return .elementOrAttribute
        }
    }
}

struct TypesContainer: Codable, Equatable, DynamicNodeDecoding {
    let elements: [TypeDefinition]
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case elements = "type"
        case comment
    }

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.elements: return .element
            case CodingKeys.comment: return .attribute
            default: return .elementOrAttribute
        }
    }
}

struct TypeDefinition: Codable, Equatable, DynamicNodeDecoding {
    enum Category: String, Codable, Equatable {
        case structure = "struct"
        case enumeration = "enum"
        case bitmask
        case include
        case define
        case basetype
        case handle
        case funcpointer
        case union
    }

    struct Member: Codable, Equatable, DynamicNodeDecoding {
        let textElements: [String]?
        let name: String
        let type: String
        let values: String?

        enum CodingKeys: String, CodingKey {
            case textElements = ""
            case name
            case type
            case values
        }

        static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
            switch key {
                case CodingKeys.textElements: return .element
                case CodingKeys.name: return .element
                case CodingKeys.type: return .element
                case CodingKeys.values: return .attribute
                default: return .elementOrAttribute
            }
        }
    }

    let name: String?
    let category: Category?
    let parent: String?
    let bandwidth: String?
    private(set) var members: [Member] = []

    enum CodingKeys: String, CodingKey {
        case name
        case category
        case members = "member"
        case parent
        case bandwidth
    }

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.name: return .elementOrAttribute
            case CodingKeys.category: return .attribute
            case CodingKeys.members: return .element
            case CodingKeys.parent: return .attribute
            case CodingKeys.bandwidth: return .elementOrAttribute
            default: return .elementOrAttribute
        }
    }
}

struct EnumerationDefinition: Codable, Equatable, DynamicNodeDecoding {
    struct Case: Codable, Equatable {
        let name: String
    }

    enum Subtype: String, Codable, Equatable {
        case unknown
        case enumeration = "enum"
        case bitmask
    }

    let cases: [Case]
    let name: String
    private let _subtype: Subtype?
    var subtype: Subtype { _subtype ?? .unknown }

    enum CodingKeys: String, CodingKey {
        case cases = "enum"
        case name
        case _subtype = "type"
    }

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.cases: return .element
            case CodingKeys.name: return .attribute
            case CodingKeys._subtype: return .attribute
            default: return .elementOrAttribute
        }
    }
}

struct RequirementDefinition: Codable, Equatable {
    struct Enumerant: Codable, Equatable {
        let name: String
        let extends: String?
        let protectingDefine: String?

        enum CodingKeys: String, CodingKey {
            case name
            case extends
            case protectingDefine = "protect"
        }
    }

    struct TypeEntry: Codable, Equatable {
        let name: String
    }

    let enumerants: [Enumerant]?
    let typeEntries: [TypeEntry]?

    enum CodingKeys: String, CodingKey {
        case enumerants = "enum"
        case typeEntries = "type"
    }

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.enumerants: return .element
            case CodingKeys.typeEntries: return .element
            default: return .elementOrAttribute
        }
    }
}

struct FeatureDefinition: Codable, Equatable, DynamicNodeDecoding {
    let api: String
    let name: String
    let number: String

    let requirements: [RequirementDefinition]

    enum CodingKeys: String, CodingKey {
        case api
        case name
        case number
        case requirements = "require"
    }

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.api: return .attribute
            case CodingKeys.name: return .attribute
            case CodingKeys.number: return .attribute
            case CodingKeys.requirements: return .element
            default: return .elementOrAttribute
        }
    }
}

struct VulkanStructureGenerator: ParsableCommand {
    @Argument(help: "Vulkan API registry file path")
    var registryFilePath: String = "/usr/share/vulkan/registry/vk.xml"

    @Option(name: .shortAndLong, help: "Location of the output swift code file")
    var outputFilePath: String

    func run() throws {
        let registryFileURL = URL(fileURLWithPath: registryFilePath, isDirectory: false)
        let registryXMLData = try Data(contentsOf: registryFileURL)

        let decoder = XMLDecoder()
        decoder.shouldProcessNamespaces = false
        decoder.trimValueWhitespaces = false

        let registry = try decoder.decode(RegistryDefinition.self, from: registryXMLData)
        
        var parsedStructures = Dictionary(uniqueKeysWithValues:
            registry.types.elements
                .filter { $0.category == .structure }
                .compactMap { ParsedStruct(typeDefinition: $0) }
                .map { ($0.name, $0) }
        )

        var parsedEnumerations = Dictionary(uniqueKeysWithValues:
            registry.enumerations
                .filter { $0.subtype == .enumeration }
                .map { ParsedEnum(enumerationDefinition: $0) }
                .map { ($0.name, $0) }
        )

        var parsedOptionSets = Dictionary(uniqueKeysWithValues:
            registry.enumerations
                .filter { $0.subtype == .bitmask }
                .map { ParsedEnum(enumerationDefinition: $0) }
                .map { ($0.name, $0) }
        )

        registry.features.forEach { feature in
            feature.requirements.forEach { requirement in
                requirement.enumerants?.forEach {
                    guard let extends = $0.extends else {
                        return
                    }

                    if var enumeration = parsedEnumerations[extends] {
                        var addedCase = ParsedEnum.Case(name: $0.name)

                        if let protectingDefine = $0.protectingDefine {
                            addedCase.cDefines.append(protectingDefine)
                        }

                        enumeration.cases.append(addedCase)

                        parsedEnumerations[extends] = enumeration
                    }

                    if var enumeration = parsedOptionSets[extends] {
                        var addedCase = ParsedEnum.Case(name: $0.name)

                        if let protectingDefine = $0.protectingDefine {
                            addedCase.cDefines.append(protectingDefine)
                        }

                        enumeration.cases.append(addedCase)

                        parsedOptionSets[extends] = enumeration
                    }
                }
            }
        }

        registry.extensions.elements.forEach { extensionItem in
            var shouldRemoveType = false
            var swiftDefine: String?
            if let platformName = extensionItem.platformName {
                if let swiftDefineForPlatform = platformToDefine[platformName] {
                    swiftDefine = swiftDefineForPlatform
                } else {
                    shouldRemoveType = true
                }
            }

            extensionItem.requirements?.forEach { requirement in
                requirement.typeEntries?.forEach {
                    if shouldRemoveType {
                        parsedStructures.removeValue(forKey: $0.name)
                        parsedEnumerations.removeValue(forKey: $0.name)
                        parsedOptionSets.removeValue(forKey: $0.name)
                    } else {
                        if var structure = parsedStructures[$0.name] {
                            swiftDefine.map {
                                structure.swiftDefines.append($0)
                            }

                            parsedStructures[$0.name] = structure
                        }

                        if var enumeration = parsedEnumerations[$0.name] {
                            swiftDefine.map {
                                enumeration.swiftDefines.append($0)
                            }
                            
                            parsedEnumerations[$0.name] = enumeration
                        }

                        if var optionSet = parsedOptionSets[$0.name] {
                            swiftDefine.map {
                                optionSet.swiftDefines.append($0)
                            }
                            
                            parsedOptionSets[$0.name] = optionSet
                        }
                    }
                }
                
                requirement.enumerants?.forEach {
                    guard let extends = $0.extends else {
                        return
                    }

                    if var enumeration = parsedEnumerations[extends] {
                        var addedCase = ParsedEnum.Case(name: $0.name)

                        $0.protectingDefine.map {
                            if enumeration.cDefines.contains($0) == false {
                                addedCase.cDefines.append($0)
                            }
                        }

                        swiftDefine.map {
                            if enumeration.swiftDefines.contains($0) == false {
                                addedCase.swiftDefines.append($0)
                            }
                        }
                            
                        enumeration.cases.append(addedCase)

                        parsedEnumerations[extends] = enumeration
                    }

                    if var optionSet = parsedOptionSets[extends] {
                        var addedCase = ParsedEnum.Case(name: $0.name)

                        $0.protectingDefine.map {
                            if optionSet.cDefines.contains($0) == false {
                                addedCase.cDefines.append($0)
                            }
                        }

                        swiftDefine.map {
                            if optionSet.swiftDefines.contains($0) == false {
                                addedCase.swiftDefines.append($0)
                            }
                        }

                        optionSet.cases.append(addedCase)

                        parsedOptionSets[extends] = optionSet
                    }
                }
            }
        }

        debugPrint("Starting")

        var result: [String] = []
        result += parsedStructures.map { $0.value }
            .sorted {
                $0.name < $1.name
            }
            .flatMap {
                [
                    // $0.exportString,
                    $0.vulkanStructureExtensionString,
                ]
            }
        // result += parsedEnumerations.map { $0.value }
        //     .sorted {
        //         $0.name < $1.name
        //     }
        //     .flatMap {
        //         [
        //             $0.exportString,
        //             $0.convenienceCasesString(tags: registry.tags.elements),
        //         ]
        //     }
        // result += parsedOptionSets.map { $0.value }
        //     .sorted {
        //         $0.name < $1.name
        //     }
        //     .flatMap {
        //         [
        //             $0.exportString,
        //             $0.convenienceCasesString(tags: registry.tags.elements),
        //         ]
        //     }

        let outputFileURL = URL(fileURLWithPath: outputFilePath, isDirectory: false)

        debugPrint("\(outputFileURL)")

        try result.joined(separator: "\n\n")
            .write(to: outputFileURL, atomically: true, encoding: .utf8)
    }
}

extension String {
    var snakecased: String {
        return snakecased(capitalizeFirst: false)
    }

    func snakecased(capitalizeFirst: Bool = false) -> String {
        return split(separator: "_")
            .enumerated()
            .map {
                if $0.offset == 0 && !capitalizeFirst {
                    return $0.element.lowercased()
                } else {
                    return $0.element.capitalized
                }
            }
            .joined()
    }

    mutating func stripTagSuffix(tags: [TagDefinition], isEnumName: Bool = false) {
        self = stripingTagSuffix(tags: tags, isEnumName: isEnumName)
    }

    func stripingTagSuffix(tags: [TagDefinition], isEnumName: Bool = false) -> String {
        for tag in tags {
            let suffix: String
            if isEnumName {
                suffix = tag.name
            } else {
                suffix = "_" + tag.name
            }
            if hasSuffix(suffix) {
                return String(dropLast(suffix.count))
            }
        }

        return self
    }

    mutating func lowercaseFirst() {
        self = lowercasedFirst()
    }

    func lowercasedFirst() -> String {
        if isEmpty {
            return ""
        }

        let afterFirst = dropFirst()
        return first!.lowercased() + afterFirst
    }

    var spelledOutNumberSnakecasedString: String {
        let number = Int(self)!
        if number < 100 {
            return spellOutNumberFormatter.string(from: NSNumber(value: number))!
                .replacingOccurrences(of: "-", with: "_")
                .snakecased
        } else {
            return enumerated().reduce("") { accumulator, element in
                let number = Int(String(element.element))!
                let result = spellOutNumberFormatter.string(from: NSNumber(value: number))!
                return accumulator + (element.offset == 0 ? result.lowercased() : result.capitalized)
            }
        }
    }
}

VulkanStructureGenerator.main()

protocol VulkanType {
    var name: String { get }
    var cDefines: [String] { get }
    var swiftDefines: [String] { get }
}

extension VulkanType {
    var exportString: String {
        var result: [String] = []

        result += swiftDefines.map {
            "#if \($0)"
        }

        result += ["public typealias \(name) = CVulkan.\(name)"]

        result += swiftDefines.map { _ in
            "#endif"
        }

        return result.joined(separator: "\n")
    }
}

extension ParsedEnum.Case {
    func convenienceGenerated(enumerationName: String, isOptionSet: Bool, tags: [TagDefinition]) -> [String] {
        var result = name
            .replacingOccurrences(of: "_1D", with: "_ONE_DIMENSION")
            .replacingOccurrences(of: "_2D", with: "_TWO_DIMENSIONS")
            .replacingOccurrences(of: "_3D", with: "_THREE_DIMENSIONS")

        // special case for vendors. in most cases Vendor ID == Tag
        if enumerationName != "VkVendorId" {
            result.stripTagSuffix(tags: tags, isEnumName: false)
        }
            
        if isOptionSet && result.hasSuffix("_BIT") {
            result = String(result.dropLast(4))
        }

        result = result.snakecased(capitalizeFirst: true)

        var prefixToRemove = enumerationName
            .stripingTagSuffix(tags: tags, isEnumName: true)

        if isOptionSet, let range = prefixToRemove.range(of: "FlagBits") {
            prefixToRemove.removeSubrange(range)
        }

        prefixToRemove = prefixToRemove.commonPrefix(with: result)

        result = String(result.dropFirst(prefixToRemove.count))

        let digitsPrefix = result.prefix {
            $0.isNumber
        }

        if digitsPrefix.isEmpty == false {
            result = String(digitsPrefix).spelledOutNumberSnakecasedString + result.dropFirst(digitsPrefix.count)
        }

        result.lowercaseFirst()

        var resultingArray: [String] = []
        resultingArray += swiftDefines.map {
            "#if \($0)"
        }

        resultingArray += [(swiftDefines.isEmpty ? "" : "    ") + "static let \(result): \(enumerationName) = .\(name)"]

        resultingArray += swiftDefines.map { _ in
            "#endif"
        }

        return resultingArray
    }
}

struct ParsedEnum: VulkanType {
    struct Case {
        let name: String
        var cDefines: [String] = []
        var swiftDefines: [String] = []
    }

    var name: String
    var cDefines: [String] = []
    var swiftDefines: [String] = []
    var cases: [Case] = []
    let isOptionSet: Bool
    
    init(enumerationDefinition: EnumerationDefinition) {
        assert(enumerationDefinition.subtype == .enumeration || enumerationDefinition.subtype == .bitmask)

        isOptionSet = enumerationDefinition.subtype == .bitmask

        name = enumerationDefinition.name

        cases = enumerationDefinition.cases.map {
            Case(name: $0.name)
        }
    }

    func convenienceCasesString(tags: [TagDefinition]) -> String {
        var result: [String] = []
        result.append("public extension \(name) {")

        result += cases.map {
            $0.convenienceGenerated(enumerationName: name, isOptionSet: isOptionSet, tags: tags)
                .map {
                    "    " + $0
                }
                .joined(separator: "\n")
        }

        result.append("}")

        return result.joined(separator: "\n")
    }

    var cDeclaration: String {
        var result: [String] = []

        result += cDefines.map {
            "#ifdef \($0)"
        }

        result += ["AK_EXISTING_ENUM(VkImageViewType);"]

        result += cDefines.map { _ in
            "#endif"
        }

        return result.joined(separator: "\n")
    }
}

struct ParsedStruct: VulkanType {
    let name: String
    var cDefines: [String] = []
    var swiftDefines: [String] = []
    let typeName: String
    let isInput: Bool

    init?(typeDefinition: TypeDefinition) {
        assert(typeDefinition.category == .structure)
        
        guard let structureName = typeDefinition.name else {
            return nil
        }

        let typeMember = typeDefinition.members.first {
            $0.name == "sType"
        }

        guard let typeMember = typeMember else {
            return nil
        }

        guard let structureTypeName = typeMember.values else {
            return nil
        }

        let nextMember = typeDefinition.members.first {
            $0.name == "pNext"
        }

        guard let nextMember = nextMember else {
            return nil
        }

        if let textElements = nextMember.textElements {
            isInput = textElements.contains {
                $0.hasPrefix("const")
            }
        } else {
            isInput = false
        }

        name = structureName
        typeName = structureTypeName
    }

    var vulkanStructureExtensionString: String {
        let template: String

        if isInput {
            template = Templates.inputStructureExtension
        } else {
            template = Templates.outputStructureExtension
        }

        var result: [String] = []

        result += swiftDefines.map {
            "#if \($0)"
        }

        result += [
            template
                .replacingOccurrences(of: "<NAME>", with: name)
                .replacingOccurrences(of: "<TYPE>", with: "." + typeName),
        ]

        result += swiftDefines.map { _ in
            "#endif"
        }

        return result.joined(separator: "\n")
    }
}
