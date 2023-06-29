//
//  EnumerationDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

import TinyFoundation
import XMLCoder

public struct EnumerationDefinition: Codable, Equatable, DynamicNodeDecoding {
    public struct Case: Codable, Equatable {
        public let name: String
        public let value: String?
        public let bitPosition: String?

        public enum CodingKeys: String, CodingKey {
            case name
            case value
            case bitPosition = "bitpos"
        }
    }

    public enum Subtype: String, Codable, Equatable {
        case unknown
        case enumeration = "enum"
        case bitmask
    }

    public let cases: [Case]
    public let name: String
    private let _subtype: Subtype?
    public var subtype: Subtype { _subtype ?? .unknown }

    public enum CodingKeys: String, CodingKey {
        case cases = "enum"
        case name
        case _subtype = "type"
    }

    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.cases: return .element
            case CodingKeys.name: return .attribute
            case CodingKeys._subtype: return .attribute
            default: return .elementOrAttribute
        }
    }
}
