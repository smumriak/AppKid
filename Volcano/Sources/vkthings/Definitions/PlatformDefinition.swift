//
//  PlatformDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

struct PlatformsContainer: Codable, Equatable {
    let elements: [PlatformDefinition]
    var byName: [String: PlatformDefinition] {
        Dictionary(uniqueKeysWithValues: elements.map { ($0.name, $0) })
    }

    enum CodingKeys: String, CodingKey {
        case elements = "platform"
    }
}

struct PlatformDefinition: Codable, Equatable, DynamicNodeDecoding {
    let name: String
    let protectingDefine: String?

    enum CodingKeys: String, CodingKey {
        case name
        case protectingDefine = "protect"
    }

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
            case CodingKeys.name: return .attribute
            case CodingKeys.protectingDefine: return .attribute
            default: return .elementOrAttribute
        }
    }
}
