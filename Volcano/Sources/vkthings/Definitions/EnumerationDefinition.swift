//
//  EnumerationDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

struct EnumerationDefinition: Codable, Equatable, DynamicNodeDecoding {
    struct Case: Codable, Equatable {
        let name: String
        let value: String?
        let bitPosition: String?

        enum CodingKeys: String, CodingKey {
            case name
            case value
            case bitPosition = "bitpos"
        }
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
