//
//  ExtensionDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

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
        case vulkansc
    }

    let name: String
    let number: String
    let extensionType: ExtensionType?
    let supported: Set<Supported>
    let requirements: [RequirementDefinition]?
    let platformName: String?
    let deprecatedBy: String?

    enum CodingKeys: String, CodingKey {
        case name
        case number
        case extensionType = "type"
        case supported
        case requirements = "require"
        case platformName = "platform"
        case deprecatedBy = "deprecatedby"
    }

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
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

    init(from decoder: Decoder) throws {
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
