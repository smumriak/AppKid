//
//  Parser.swift
//  Volcano
//
//  Created by Serhii Mumriak on 28.06.2023
//

import XMLCoder
import Foundation
import SemanticVersion

public struct VulkanValidUsage: Codable {
    public struct VersionInfo: Codable {
        public let schemaVersion: Int
        public let apiVersion: SemanticVersion
        public let comment: String

        public enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema version"
            case apiVersion = "api version"
            case comment = "comment"
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            self.schemaVersion = try values.decode(.schemaVersion)
            let apiVersionString: String = try values.decode(.apiVersion)
            if let apiVersion = SemanticVersion(apiVersionString) {
                self.apiVersion = apiVersion
            } else {
                throw Parser.Error.versionNotParsable
            }
            self.comment = try values.decode(.comment)
        }
    }

    public let versionInfo: VersionInfo

    public enum CodingKeys: String, CodingKey {
        case versionInfo = "version info"
    }

    public init(registryFileURL: URL) throws {
        let validUsageFileURL = registryFileURL.deletingLastPathComponent().appendingPathComponent("validusage.json")

        if FileManager.default.fileExists(atPath: validUsageFileURL.absoluteURL.path) == false {
            throw Parser.Error.validUsageNotFound
        }

        let validUsageData = try Data(contentsOf: validUsageFileURL)

        let validUsageDecoder = JSONDecoder()
        validUsageDecoder.dateDecodingStrategy = .iso8601

        self = try validUsageDecoder.decode(VulkanValidUsage.self, from: validUsageData)
    }
}

public struct Parser {
    public enum Error: Swift.Error {
        case validUsageNotFound
        case versionNotParsable

        public var localizedDescription: String {
            switch self {
                case .validUsageNotFound:
                    return "Specified vulkan registry xml is not accompanied by validusage.json file"

                case .versionNotParsable:
                    return "validusage.json specified API version is not parsable"
            }
        }
    }

    public let registry: RegistryDefinition
    public let structures: Dictionary<String, ParsedStruct>
    public let enumerations: Dictionary<String, ParsedEnum>
    public let optionSets: Dictionary<String, ParsedEnum>
    public let enabledExtensions: [ExtensionDefinition]
    public let instanceExtensions: Dictionary<String, ParsedInstanceExtension>
    public let deviceExtensions: Dictionary<String, ParsedDeviceExtension>
    public let version: SemanticVersion

    public init(registryFileURL: URL, version: SemanticVersion? = nil) throws {
        if let version {
            self.version = version
        } else {
            let validUsage = try VulkanValidUsage(registryFileURL: registryFileURL)
            self.version = validUsage.versionInfo.apiVersion
        }

        let registryXMLData = try Data(contentsOf: registryFileURL)

        let registryDecoder = XMLDecoder()
        registryDecoder.shouldProcessNamespaces = false
        registryDecoder.trimValueWhitespaces = false

        let registry = try registryDecoder.decode(RegistryDefinition.self, from: registryXMLData)

        var structures = Dictionary(uniqueKeysWithValues:
            registry.types.elements
                .filter { $0.category == .structure }
                .compactMap { ParsedStruct(typeDefinition: $0) }
                .map { ($0.name, $0) }
        )

        var enumerations = Dictionary(uniqueKeysWithValues:
            registry.enumerations
                .filter { $0.subtype == .enumeration }
                .map { ParsedEnum(enumerationDefinition: $0) }
                .map { ($0.name, $0) }
        )

        var optionSets = Dictionary(uniqueKeysWithValues:
            registry.enumerations
                .filter { $0.subtype == .bitmask }
                .filter {
                    ["VkAccessFlagBits2",
                     "VkFormatFeatureFlagBits2",
                     "VkPipelineStageFlagBits2",
                     "VkMemoryDecompressionMethodFlagBitsNV"]
                        .contains($0.name) == false
                }
                .map { ParsedEnum(enumerationDefinition: $0) }
                .map { ($0.name, $0) }
        )

        let enabledExtensions = registry.extensions.elements
            .filter {
                if let deprecatedBy = $0.deprecatedBy {
                    return deprecatedBy.isEmpty
                } else {
                    return true
                }
            }

        let instanceExtensions = Dictionary(uniqueKeysWithValues:
            enabledExtensions
                .filter { $0.extensionType == .instance }
                .map { ParsedInstanceExtension(extensionDefinition: $0) }
                .map { ($0.name, $0) }
        )

        let deviceExtensions = Dictionary(uniqueKeysWithValues:
            enabledExtensions
                .filter { $0.extensionType == .device }
                .map { ParsedDeviceExtension(extensionDefinition: $0) }
                .map { ($0.name, $0) }
        )

        registry.features.forEach { feature in
            let shouldRemoveType = !feature.api.contains(.vulkan)
            feature.requirements.forEach { requirement in
                let shouldRemoveType = shouldRemoveType || !requirement.api.contains(.vulkan)
                requirement.typeEntries?.forEach {
                    if shouldRemoveType && $0.name != "VkPipelineCacheCreateFlagBits" {
                        structures.removeValue(forKey: $0.name)
                        enumerations.removeValue(forKey: $0.name)
                        optionSets.removeValue(forKey: $0.name)
                    }
                }

                if !feature.api.contains(.vulkan) || !requirement.api.contains(.vulkan) {
                    return
                }

                requirement.enumerants?.forEach {
                    guard let extends = $0.extends else {
                        return
                    }

                    if let protectingDefine = $0.protectingDefine, protectingDefine == "VK_ENABLE_BETA_EXTENSIONS" {
                        return
                    }

                    if var enumeration = enumerations[extends] {
                        var addedCase = ParsedEnum.Case(name: $0.name, value: nil)

                        if let protectingDefine = $0.protectingDefine {
                            addedCase.cDefines.append(protectingDefine)
                        }

                        let alreadyExists = enumeration.cases.contains {
                            $0.name == addedCase.name
                        }

                        if alreadyExists == false {
                            enumeration.cases.append(addedCase)
                        }

                        enumerations[extends] = enumeration
                    }

                    if var optionSet = optionSets[extends] {
                        var addedCase = ParsedEnum.Case(name: $0.name, value: nil)

                        if let protectingDefine = $0.protectingDefine {
                            addedCase.cDefines.append(protectingDefine)
                        }

                        let alreadyExists = optionSet.cases.contains {
                            $0.name == addedCase.name
                        }

                        if alreadyExists == false {
                            optionSet.cases.append(addedCase)
                        }

                        optionSets[extends] = optionSet
                    }
                }
            }
        }

        registry.extensions.elements.forEach { extensionItem in
            var shouldRemoveType = !extensionItem.supported.contains(.vulkan)
            var swiftDefine: String?
            var cDefine: String?
            
            if let platformName = extensionItem.platformName {
                if let volcanoPlatform = VolcanoPlatform(rawValue: platformName) {
                    swiftDefine = volcanoPlatform.rawValue
                } else {
                    shouldRemoveType = true
                }

                if let platform = registry.platforms.byName[platformName] {
                    cDefine = platform.protectingDefine
                }
            }

            extensionItem.requirements?.forEach { requirement in
                let shouldRemoveType = shouldRemoveType || !requirement.api.contains(.vulkan)
                requirement.typeEntries?.forEach {
                    if shouldRemoveType && $0.name != "VkPipelineCacheCreateFlagBits" {
                        structures.removeValue(forKey: $0.name)
                        enumerations.removeValue(forKey: $0.name)
                        optionSets.removeValue(forKey: $0.name)
                    } else {
                        if var structure = structures[$0.name] {
                            swiftDefine.map {
                                structure.swiftDefines.append($0)
                            }

                            cDefine.map {
                                if structure.cDefines.contains($0) == false {
                                    structure.cDefines.append($0)
                                }
                            }

                            structures[$0.name] = structure
                        }

                        if var enumeration = enumerations[$0.name] {
                            swiftDefine.map {
                                enumeration.swiftDefines.append($0)
                            }

                            cDefine.map {
                                if enumeration.cDefines.contains($0) == false {
                                    enumeration.cDefines.append($0)
                                }
                            }

                            enumerations[$0.name] = enumeration
                        }

                        if var optionSet = optionSets[$0.name] {
                            swiftDefine.map {
                                optionSet.swiftDefines.append($0)
                            }

                            cDefine.map {
                                if optionSet.cDefines.contains($0) == false {
                                    optionSet.cDefines.append($0)
                                }
                            }

                            optionSets[$0.name] = optionSet
                        }
                    }
                }

                if !extensionItem.supported.contains(.vulkan) || !requirement.api.contains(.vulkan) {
                    return
                }

                requirement.enumerants?.forEach {
                    guard let extends = $0.extends else {
                        return
                    }

                    if let protectingDefine = $0.protectingDefine, protectingDefine == "VK_ENABLE_BETA_EXTENSIONS" {
                        return
                    }

                    if var enumeration = enumerations[extends] {
                        var addedCase = ParsedEnum.Case(name: $0.name, value: nil)

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

                        enumerations[extends] = enumeration
                    }

                    if var optionSet = optionSets[extends] {
                        var addedCase = ParsedEnum.Case(name: $0.name, value: nil)

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

                        optionSets[extends] = optionSet
                    }
                }
            }
        }

        self.registry = registry
        self.structures = structures
        self.enumerations = enumerations
        self.optionSets = optionSets
        self.enabledExtensions = enabledExtensions
        self.instanceExtensions = instanceExtensions
        self.deviceExtensions = deviceExtensions
    }
}
