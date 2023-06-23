//
//  TagDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 13.06.2023
//

struct TagsContainer: Codable, Equatable {
    let elements: [TagDefinition]

    enum CodingKeys: String, CodingKey {
        case elements = "tag"
    }
}

struct TagDefinition: Codable, Equatable {
    let name: String

    enum CodingKeys: String, CodingKey {
        case name
    }
}
