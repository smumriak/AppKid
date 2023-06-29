//
//  FeatureDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

import TinyFoundation
import XMLCoder

public struct FeatureDefinition: Codable, Equatable, DynamicNodeDecoding {
    public enum API: String, Codable, Equatable {
        case vulkan
        case disabled
        case vulkansc
    }

    public let api: Set<API>
    public let name: String
    public let number: String

    public let requirements: [RequirementDefinition]

    public enum CodingKeys: String, CodingKey {
        case api
        case name
        case number
        case requirements = "require"
    }

    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.api: return .attribute
            case CodingKeys.name: return .attribute
            case CodingKeys.number: return .attribute
            case CodingKeys.requirements: return .element
            default: return .elementOrAttribute
        }
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(.name)
        number = try values.decode(.number)
        requirements = try values.decode(.requirements)

        let api = try values.decode(String.self, forKey: .api)
            .split(separator: ",")
            .compactMap { API(rawValue: String($0)) }

        self.api = Set(api)
    }
}
