//
//  v1.swift
//  Volcano
//
//  Created by Serhii Mumriak on 03.07.2023
//

import SemanticVersion
import Foundation

public struct MetadataHeader_v1: Codable {
    public enum Error: Swift.Error {
        case dateNotParsable
        case vulkanVersionNotParsable
    }

    public enum CodingKeys: String, CodingKey {
        case version = "Metadata version"
        case dateGenerated = "Date generated"
        case vulkanVersion = "Vulkan Version"
    }

    public var version: MetadataVersion = .v1
    public var dateGenerated: Date = .now
    public var vulkanVersion: SemanticVersion = SemanticVersion(0, 0, 0)

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(version, forKey: .version)

        let dateString = DateFormatter.header.string(from: dateGenerated)
        try container.encode(dateString, forKey: .dateGenerated)

        try container.encode(vulkanVersion, forKey: .vulkanVersion)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.version = try values.decode(.version)

        let dateString: String = try values.decode(.dateGenerated)
        if let date = DateFormatter.header.date(from: dateString) {
            self.dateGenerated = date
        } else {
            throw Error.dateNotParsable
        }

        self.vulkanVersion = try values.decode(.vulkanVersion)
    }

    public init() {}
}
