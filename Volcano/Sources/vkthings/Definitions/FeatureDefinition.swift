//
//  FeatureDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

struct FeatureDefinition: Codable, Equatable, DynamicNodeDecoding {
    enum API: String, Codable, Equatable {
        case vulkan
        case disabled
        case vulkansc
    }

    let api: Set<API>
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

    init(from decoder: Decoder) throws {
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
