//
//  ExtensionDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

import TinyFoundation
import XMLCoder

public struct ExtensionsContainer: Codable, Equatable {
    public let elements: [ExtensionDefinition]

    public enum CodingKeys: String, CodingKey {
        case elements = "extension"
    }
}

public struct ExtensionDefinition: Codable, Equatable, DynamicNodeDecoding {
    public enum ExtensionType: String, Codable, Equatable {
        case instance
        case device
    }

    public enum Supported: String, Codable, Equatable {
        case vulkan
        case disabled
        case vulkansc
    }

    public let name: String
    public let number: String
    public let extensionType: ExtensionType?
    public let supported: Set<Supported>
    public let requirements: [RequirementDefinition]?
    public let platformName: String?
    public let deprecatedBy: String?

    public enum CodingKeys: String, CodingKey {
        case name
        case number
        case extensionType = "type"
        case supported
        case requirements = "require"
        case platformName = "platform"
        case deprecatedBy = "deprecatedby"
    }

    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.name: return .attribute
            case CodingKeys.number: return .attribute
            case CodingKeys.extensionType: return .attribute
            case CodingKeys.supported: return .attribute
            case CodingKeys.requirements: return .element
            case CodingKeys.platformName: return .attribute
            case CodingKeys.deprecatedBy: return .attribute
            default: return .elementOrAttribute
        }
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(.name)
        number = try values.decode(.number)
        extensionType = try values.decodeIfPresent(.extensionType)
        requirements = try values.decodeIfPresent(.requirements)
        platformName = try values.decodeIfPresent(.platformName)
        deprecatedBy = try values.decodeIfPresent(.deprecatedBy)

        let supported = try values.decode(String.self, forKey: .supported)
            .split(separator: ",")
            .compactMap { Supported(rawValue: String($0)) }

        self.supported = Set(supported)
    }
}
