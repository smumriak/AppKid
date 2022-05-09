//
//  main.swift
//  vkthings
//
//  Created by Serhii Mumriak on 18.01.2022.
//

import Foundation
import ArgumentParser
import XMLCoder

// palkovnik: The code below is extremely bad. Abstraction is bad, a lot of hardcoded values and it was written in three nights. But vk.xml is a crappy format for specification anyway, so crappy input deserves crappy tool

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
    "metal": "VOLCANO_PLATFORM_APPLE_METAL",
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

    static let vulkanCEnumsLicense =
        """
        //
        //  VulkanEnums.h
        //  Volcano
        //
        //  Created by Serhii Mumriak on 17.08.2020.
        //
        """

    static let vulkanCOptionSetsLicense =
        """
        //
        //  VulkanOptionSets.h
        //  Volcano
        //
        //  Created by Serhii Mumriak on 17.08.2020.
        //
        """

    static let vulkanSwiftStructuresLicense =
        """
        //
        //  VulkanStructureConformance.swift
        //  Volcano
        //
        //  Created by Serhii Mumriak on 28.01.2021.
        //
        """

    static let vulkanSwiftEnumsLicense =
        """
        //
        //  VulkanEnums.swift
        //  Volcano
        //
        //  Created by Serhii Mumriak on 28.01.2021.
        //
        """

    static let vulkanSwiftOptionSetsLicense =
        """
        //
        //  VulkanOptionSets.swift
        //  Volcano
        //
        //  Created by Serhii Mumriak on 28.01.2021.
        //
        """

    static let vulkanSwiftExtensionsLicense =
        """
        //
        //  VulkanExtensionsNames.swift
        //  Volcano
        //
        //  Created by Serhii Mumriak on 20.07.2021.
        //
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
    var byName: [String: PlatformDefinition] {
        Dictionary(uniqueKeysWithValues: elements.map { ($0.name, $0) })
    }

    enum CodingKeys: String, CodingKey {
        case elements = "platform"
    }
}

struct PlatformDefinition: Codable, Equatable, DynamicNodeDecoding {
    let name: String
    let protectingDefine: String?

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
    enum GeneratedFileType: String, EnumerableFlag {
        case swiftStructs
        case swiftOptionSets
        case swiftEnums
        case cEnums
        case cOptionSets
        case swiftExtensions
    }

    @Argument(help: "Vulkan API registry file path")
    var registryFilePath: String = "/usr/share/vulkan/registry/vk.xml"

    @Option(name: .shortAndLong, help: "Location of the output swift code file")
    var outputFilePath: String

    @Flag(help: "")
    var generatedFileType: GeneratedFileType

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
                .filter {
                    $0.name != "VkAccessFlagBits2"
                        && $0.name != "VkFormatFeatureFlagBits2"
                        && $0.name != "VkPipelineStageFlagBits2"
                }
                .map { ParsedEnum(enumerationDefinition: $0) }
                .map { ($0.name, $0) }
        )

        let enabledExtensions = registry.extensions.elements
            .filter { $0.supported != .disabled }

        let parsedInstanceExtensions = Dictionary(uniqueKeysWithValues:
            enabledExtensions
                .filter { $0.extensionType == .instance }
                .map { ParsedInstanceExtension(extensionDefinition: $0) }
                .map { ($0.name, $0) }
        )

        let parsedDeviceExtensions = Dictionary(uniqueKeysWithValues:
            enabledExtensions
                .filter { $0.extensionType == .device }
                .map { ParsedDeviceExtension(extensionDefinition: $0) }
                .map { ($0.name, $0) }
        )

        registry.features.forEach { feature in
            feature.requirements.forEach { requirement in
                requirement.enumerants?.forEach {
                    guard let extends = $0.extends else {
                        return
                    }

                    if let protectingDefine = $0.protectingDefine, protectingDefine == "VK_ENABLE_BETA_EXTENSIONS" {
                        return
                    }

                    if var enumeration = parsedEnumerations[extends] {
                        var addedCase = ParsedEnum.Case(name: $0.name)

                        if let protectingDefine = $0.protectingDefine {
                            addedCase.cDefines.append(protectingDefine)
                        }

                        let alreadyExists = enumeration.cases.contains {
                            $0.name == addedCase.name
                        }

                        if alreadyExists == false {
                            enumeration.cases.append(addedCase)
                        }

                        parsedEnumerations[extends] = enumeration
                    }

                    if var optionSet = parsedOptionSets[extends] {
                        var addedCase = ParsedEnum.Case(name: $0.name)

                        if let protectingDefine = $0.protectingDefine {
                            addedCase.cDefines.append(protectingDefine)
                        }

                        let alreadyExists = optionSet.cases.contains {
                            $0.name == addedCase.name
                        }

                        if alreadyExists == false {
                            optionSet.cases.append(addedCase)
                        }

                        parsedOptionSets[extends] = optionSet
                    }
                }
            }
        }

        registry.extensions.elements.forEach { extensionItem in
            var shouldRemoveType = false
            var swiftDefine: String?
            var cDefine: String?
            
            if let platformName = extensionItem.platformName {
                if let swiftDefineForPlatform = platformToDefine[platformName] {
                    swiftDefine = swiftDefineForPlatform
                } else {
                    shouldRemoveType = true
                }

                if let platform = registry.platforms.byName[platformName] {
                    cDefine = platform.protectingDefine
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

                            cDefine.map {
                                if structure.cDefines.contains($0) == false {
                                    structure.cDefines.append($0)
                                }
                            }

                            parsedStructures[$0.name] = structure
                        }

                        if var enumeration = parsedEnumerations[$0.name] {
                            swiftDefine.map {
                                enumeration.swiftDefines.append($0)
                            }

                            cDefine.map {
                                if enumeration.cDefines.contains($0) == false {
                                    enumeration.cDefines.append($0)
                                }
                            }

                            parsedEnumerations[$0.name] = enumeration
                        }

                        if var optionSet = parsedOptionSets[$0.name] {
                            swiftDefine.map {
                                optionSet.swiftDefines.append($0)
                            }

                            cDefine.map {
                                if optionSet.cDefines.contains($0) == false {
                                    optionSet.cDefines.append($0)
                                }
                            }

                            parsedOptionSets[$0.name] = optionSet
                        }
                    }
                }

                if extensionItem.supported == .disabled {
                    return
                }

                requirement.enumerants?.forEach {
                    guard let extends = $0.extends else {
                        return
                    }

                    if let protectingDefine = $0.protectingDefine, protectingDefine == "VK_ENABLE_BETA_EXTENSIONS" {
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
                            
                        let alreadyExists = enumeration.cases.contains {
                            $0.name == addedCase.name
                        }

                        if alreadyExists == false {
                            enumeration.cases.append(addedCase)
                        }

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

                        let alreadyExists = optionSet.cases.contains {
                            $0.name == addedCase.name
                        }

                        if alreadyExists == false {
                            optionSet.cases.append(addedCase)
                        }

                        parsedOptionSets[extends] = optionSet
                    }
                }
            }
        }

        let resultString: String
        switch generatedFileType {
            case .swiftStructs:
                var result: [String] = []

                result += [
                    Templates.vulkanSwiftStructuresLicense,
                    """
                    import TinyFoundation
                    import CVulkan
                    """,
                ]

                result += parsedStructures.map { $0.value }
                    .sorted {
                        $0.name < $1.name
                    }
                    .flatMap {
                        [
                            $0.exportString,
                            $0.vulkanStructureExtensionString,
                        ]
                    }
                    
                resultString = result.joined(separator: "\n\n")

            case .swiftEnums:
                var result: [String] = []

                result += [
                    Templates.vulkanSwiftEnumsLicense,
                    """
                    import TinyFoundation
                    import CVulkan
                    """,
                ]

                result += parsedEnumerations.map { $0.value }
                    .sorted {
                        $0.name < $1.name
                    }
                    .filter {
                        $0.cases.isEmpty == false
                    }
                    .flatMap {
                        [
                            $0.exportString,
                            $0.convenienceCasesString(tags: registry.tags.elements),
                        ]
                    }

                resultString = result.joined(separator: "\n\n")

            case .swiftOptionSets:
                var result: [String] = []

                result += [
                    Templates.vulkanSwiftOptionSetsLicense,
                    """
                    import TinyFoundation
                    import CVulkan
                    """,
                ]

                result += parsedOptionSets.map { $0.value }
                    .sorted {
                        $0.name < $1.name
                    }
                    .filter {
                        $0.cases.isEmpty == false
                    }
                    .flatMap {
                        [
                            $0.exportString,
                            $0.convenienceCasesString(tags: registry.tags.elements),
                        ]
                    }

                result += [""]

                resultString = result.joined(separator: "\n\n")

            case .cEnums:
                var result: [String] = []

                result += [
                    Templates.vulkanCEnumsLicense,
                    "",
                    "#ifndef VulkanEnums_h",
                    "#define VulkanEnums_h 1",
                    "",
                    "#include \"../../../CCore/include/CCore.h\"",
                    "",
                ]
                
                result += parsedEnumerations.map { $0.value }
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
                    "",
                    "#endif /* VulkanEnums_h */",
                    "",
                ]

                resultString = result.joined(separator: "\n")

            case .cOptionSets:
                var result: [String] = []

                result += [
                    Templates.vulkanCOptionSetsLicense,
                    "",
                    "#ifndef VulkanOptionSets_h",
                    "#define VulkanOptionSets_h 1",
                    "",
                    "#include \"../../../CCore/include/CCore.h\"",
                    "",
                ]
                
                result += parsedOptionSets.map { $0.value }
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
                    "",
                    "#endif /* VulkanOptionSets_h */",
                    "",
                ]

                resultString = result.joined(separator: "\n")

            case .swiftExtensions:
                var result: [String] = []
                
                result += [
                    Templates.vulkanSwiftExtensionsLicense,
                    "",
                    "import Foundation",
                    "import TinyFoundation",
                    "import CVulkan",
                    "",
                ]

                result += ["public enum VulkanInstanceExtension: String {"]

                result += parsedInstanceExtensions.map {
                    $0.1.caseName(tags: registry.tags.elements)
                }

                result += ["}", ""]

                result += ["public enum VulkanDeviceExtension: String {"]

                result += parsedDeviceExtensions.map {
                    $0.1.caseName(tags: registry.tags.elements)
                }

                result += ["}", ""]

                resultString = result.joined(separator: "\n")
        }

        let outputFileURL = URL(fileURLWithPath: outputFilePath, isDirectory: false)

        try resultString
            .write(to: outputFileURL, atomically: true, encoding: .utf8)
    }
}

extension String {
    var camelcased: String {
        return camelcased(capitalizeFirst: false)
    }

    var strippingVKPrevix: String {
        if self.hasPrefix("VK_") {
            return String(self.dropFirst(3))
        } else {
            return self
        }
    }

    func camelcased(capitalizeFirst: Bool = false) -> String {
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

    func tagSuffix(tags: [TagDefinition], withoutUnderscore: Bool = false, caseSensitive: Bool = true) -> String? {
        for tag in tags {
            let name = caseSensitive ? tag.name : tag.name.lowercased()
            let checkedValue = caseSensitive ? self : self.lowercased()
            
            let suffix: String
            if withoutUnderscore {
                suffix = name
            } else {
                suffix = "_" + name
            }
            if checkedValue.hasSuffix(suffix) {
                return suffix
            }
        }

        return nil
    }

    mutating func stripTagSuffix(tags: [TagDefinition], withoutUnderscore: Bool = false) {
        self = strippingTagSuffix(tags: tags, withoutUnderscore: withoutUnderscore)
    }

    func strippingTagSuffix(tags: [TagDefinition], withoutUnderscore: Bool = false, caseSensitive: Bool = true) -> String {
        for tag in tags {
            let name = caseSensitive ? tag.name : tag.name.lowercased()
            let checkedValue = caseSensitive ? self : self.lowercased()
            
            let suffix: String
            if withoutUnderscore {
                suffix = name
            } else {
                suffix = "_" + name
            }
            if checkedValue.hasSuffix(suffix) {
                // FIXME: replace self with checkedValue
                return String(self.dropLast(suffix.count))
            }
        }

        return self
    }

    mutating func stripTagPrefix(tags: [TagDefinition], withoutUnderscore: Bool = false) {
        self = strippingTagPrefix(tags: tags, withoutUnderscore: withoutUnderscore)
    }

    func strippingTagPrefix(tags: [TagDefinition], withoutUnderscore: Bool = false, caseSensitive: Bool = true) -> String {
        for tag in tags {
            let name = caseSensitive ? tag.name : tag.name.lowercased()
            let checkedValue = caseSensitive ? self : self.lowercased()
            
            let prefix: String
            if withoutUnderscore {
                prefix = name
            } else {
                prefix = name + "_"
            }
            
            if checkedValue.hasPrefix(prefix) {
                return String(self.dropFirst(prefix.count))
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

    var spelledOutNumberCamelcasedString: String {
        let number = Int(self)!
        if number < 100 {
            return spellOutNumberFormatter.string(from: NSNumber(value: number))!
                .replacingOccurrences(of: "-", with: "_")
                .camelcased
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
            result = result.replacingOccurrences(of: "Snorm", with: "SNorm")
            result = result.replacingOccurrences(of: "Uint", with: "UInt")
            result = result.replacingOccurrences(of: "Sint", with: "SInt")
            result = result.replacingOccurrences(of: "Uscaled", with: "UScaled")
            result = result.replacingOccurrences(of: "Sscaled", with: "SScaled")
            result = result.replacingOccurrences(of: "Ufloat", with: "UFloat")
            result = result.replacingOccurrences(of: "Sfloat", with: "SFloat")
            result = result.replacingOccurrences(of: "Sfloat", with: "SFloat")

            result = result.replacingOccurrences(of: "R([0-9])", with: "r$1", options: .regularExpression)
            result = result.replacingOccurrences(of: "G([0-9])", with: "g$1", options: .regularExpression)
            result = result.replacingOccurrences(of: "B([0-9])", with: "b$1", options: .regularExpression)
            result = result.replacingOccurrences(of: "A([0-9])", with: "a$1", options: .regularExpression)

            result = result.replacingOccurrences(of: "rgb", with: "RGB", options: .caseInsensitive)
            result = result.replacingOccurrences(of: "rgba", with: "RGBA", options: .caseInsensitive)
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
        let enumTagToStrip = name.tagSuffix(tags: tags, withoutUnderscore: true, caseSensitive: false)
    
        var result: [String] = []

        result += swiftDefines.map {
            "#if \($0)"
        }

        result.append("public extension \(name) {")

        result += cases.compactMap {
            let strings = $0.convenienceGenerated(enumerationName: name, isOptionSet: isOptionSet, tags: tags, enumTagToStrip: enumTagToStrip)

            if strings.isEmpty {
                return nil
            }

            return strings.map {
                "    " + $0
            }
            .joined(separator: "\n")
        }

        result.append("}")

        result += swiftDefines.map { _ in
            "#endif"
        }

        return result.joined(separator: "\n")
    }

    var cDeclaration: String {
        var result: [String] = []

        result += cDefines.map {
            "#ifdef \($0)"
        }

        if isOptionSet {
            result += ["AK_EXISTING_OPTIONS(\(name));"]
        } else {
            result += ["AK_EXISTING_ENUM(\(name));"]
        }

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

protocol ParsedExtension {
    var name: String { get }
    var version: String { get }
    var cDefines: [String] { get }
    var swiftDefines: [String] { get }
}

extension ParsedExtension {
    func caseName(tags: [TagDefinition]) -> String {
        var result = name
            .strippingVKPrevix
            .strippingTagPrefix(tags: tags)
            .camelcased

        let digitsPrefix = result.prefix { $0.isNumber }

        if digitsPrefix.isEmpty == false {
            result = String(digitsPrefix).spelledOutNumberCamelcasedString + result.dropFirst(digitsPrefix.count)
        }

        result.lowercaseFirst()

        return "case \(result) = \"\(name)\""
    }
}

struct ParsedInstanceExtension: ParsedExtension {
    let name: String
    let version: String
    var cDefines: [String] = []
    var swiftDefines: [String] = []
    
    init(extensionDefinition: ExtensionDefinition) {
        assert(extensionDefinition.extensionType == .instance)
        name = extensionDefinition.name
        version = extensionDefinition.number
    }
}

struct ParsedDeviceExtension: ParsedExtension {
    let name: String
    let version: String
    var cDefines: [String] = []
    var swiftDefines: [String] = []
    
    init(extensionDefinition: ExtensionDefinition) {
        assert(extensionDefinition.extensionType == .device)
        name = extensionDefinition.name
        version = extensionDefinition.number
    }
}
