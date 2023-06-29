//
//  TypeDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

import TinyFoundation
import XMLCoder

public struct TypesContainer: Codable, Equatable, DynamicNodeDecoding {
    public let elements: [TypeDefinition]
    public let comment: String?

    public enum CodingKeys: String, CodingKey {
        case elements = "type"
        case comment
    }

    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.elements: return .element
            case CodingKeys.comment: return .attribute
            default: return .elementOrAttribute
        }
    }
}

public struct TypeDefinition: Codable, Equatable, DynamicNodeDecoding {
    public enum Category: String, Codable, Equatable {
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

    public struct Member: Codable, Equatable, DynamicNodeDecoding {
        public let textElements: [String]?
        public let name: String
        public let type: String
        public let values: String?

        public enum CodingKeys: String, CodingKey {
            case textElements = ""
            case name
            case type
            case values
        }

        public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
            switch key {
                case CodingKeys.textElements: return .element
                case CodingKeys.name: return .element
                case CodingKeys.type: return .element
                case CodingKeys.values: return .attribute
                default: return .elementOrAttribute
            }
        }
    }

    public let name: String?
    public let category: Category?
    public let parent: String?
    public let bandwidth: String?
    public private(set) var members: [Member] = []

    public enum CodingKeys: String, CodingKey {
        case name
        case category
        case members = "member"
        case parent
        case bandwidth
    }

    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
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
