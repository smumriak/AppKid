//
//  PlatformDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

import TinyFoundation
import XMLCoder

public struct PlatformsContainer: Codable, Equatable {
    public let elements: [PlatformDefinition]
    public var byName: [String: PlatformDefinition] {
        Dictionary(uniqueKeysWithValues: elements.map { ($0.name, $0) })
    }

    public enum CodingKeys: String, CodingKey {
        case elements = "platform"
    }
}

public struct PlatformDefinition: Codable, Equatable, DynamicNodeDecoding {
    public let name: String
    public let protectingDefine: String?

    public enum CodingKeys: String, CodingKey {
        case name
        case protectingDefine = "protect"
    }

    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.name: return .attribute
            case CodingKeys.protectingDefine: return .attribute
            default: return .elementOrAttribute
        }
    }
}
