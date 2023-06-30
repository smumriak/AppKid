//
//  RegistryDefinition.swift
//  Volcano
//
//  Created by Serhii Mumriak on 28.06.2023
//

import TinyFoundation
import XMLCoder

public struct RegistryDefinition: Codable, Equatable {
    public let platforms: PlatformsContainer
    public let types: TypesContainer
    public let tags: TagsContainer
    public let enumerations: [EnumerationDefinition]
    public let features: [FeatureDefinition]
    public let extensions: ExtensionsContainer
    
    public enum CodingKeys: String, CodingKey {
        case platforms
        case types
        case tags
        case enumerations = "enums"
        case features = "feature"
        case extensions
    }
}
