//
//  TagDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

import TinyFoundation
import XMLCoder

public struct TagsContainer: Codable, Equatable {
    public let elements: [TagDefinition]

    public enum CodingKeys: String, CodingKey {
        case elements = "tag"
    }
}

public struct TagDefinition: Codable, Equatable {
    public let name: String

    public enum CodingKeys: String, CodingKey {
        case name
    }
}
