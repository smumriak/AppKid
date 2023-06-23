//
//  TypeDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

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
