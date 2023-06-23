//
//  RequirementDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

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

    enum API: String, Codable, Equatable {
        case vulkan
        case disabled
        case vulkansc
    }

    let depends: String?
    let api: Set<API>

    let enumerants: [Enumerant]?
    let typeEntries: [TypeEntry]?

    enum CodingKeys: String, CodingKey {
        case enumerants = "enum"
        case typeEntries = "type"
        case depends
        case api
    }

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.enumerants: return .element
            case CodingKeys.typeEntries: return .element
            case CodingKeys.api: return .attribute
            case CodingKeys.depends: return .attribute
            default: return .elementOrAttribute
        }
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        enumerants = try values.decodeIfPresent(.enumerants)
        typeEntries = try values.decodeIfPresent(.typeEntries)
        depends = try values.decodeIfPresent(.depends)

        let api = try values.decodeIfPresent(String.self, forKey: .api)?
            .split(separator: ",")
            .compactMap { API(rawValue: String($0)) }

        if let api {
            self.api = Set(api)
        } else {
            self.api = Set([.vulkan, .vulkansc])
        }
    }
}
