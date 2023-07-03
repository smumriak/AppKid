//
//  Version.swift
//  Volcano
//
//  Created by Serhii Mumriak on 03.07.2023
//

public enum MetadataVersion: Int, Codable {
    case v1 = 1
}

public struct MetadataHeaderVersionCheck: Decodable {
    public var version: MetadataVersion

    public enum CodingKeys: String, CodingKey {
        case version = "Metadata version"
    }
}
