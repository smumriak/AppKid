//
//  RequirementDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

import TinyFoundation
import XMLCoder

public struct RequirementDefinition: Codable, Equatable {
    public struct Enumerant: Codable, Equatable {
        public let name: String
        public let extends: String?
        public let protectingDefine: String?

        public enum CodingKeys: String, CodingKey {
            case name
            case extends
            case protectingDefine = "protect"
        }
    }

    public struct TypeEntry: Codable, Equatable {
        public let name: String
    }

    public enum API: String, Codable, Equatable {
        case vulkan
        case disabled
        case vulkansc
    }

    public let depends: String?
    public let api: Set<API>

    public let enumerants: [Enumerant]?
    public let typeEntries: [TypeEntry]?

    public enum CodingKeys: String, CodingKey {
        case enumerants = "enum"
        case typeEntries = "type"
        case depends
        case api
    }

    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.enumerants: return .element
            case CodingKeys.typeEntries: return .element
            case CodingKeys.api: return .attribute
            case CodingKeys.depends: return .attribute
            default: return .elementOrAttribute
        }
    }

    public init(from decoder: Decoder) throws {
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
