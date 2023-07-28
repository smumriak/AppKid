//
//  AppKidMetadata.swift
//  dockertoolchain
//
//  Created by Serhii Mumriak on 01.07.2023
//

import Cuisine
import SemanticVersion

struct AppKidMetadata: Codable {
    var version: Int = 0
    var appKidVersion: SemanticVersion = SemanticVersion(0, 0, 0)
    var swiftVersions: [SemanticVersion] = []

    enum CodingKeys: String, CodingKey {
        case version = "metadata version"
        case appKidVersion = "appkid version"
        case swiftVersions = "swift versions"
    }

    init() {}
}

struct AppKidMetadataKey: PantryKey {
    static let defaultValue: AppKidMetadata = .init()
}

extension Pantry {
    var appKidMetadata: AppKidMetadata {
        get {
            self[AppKidMetadataKey.self]
        }
        set {
            self[AppKidMetadataKey.self] = newValue
        }
    }
}
