//
//  Decoding.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 03.04.2023
//

import Foundation

public extension JSONDecoder {
    func decode<T>(_ data: Data) throws -> T where T: Decodable {
        try decode(T.self, from: data)
    }
}

public extension KeyedDecodingContainerProtocol {
    func decode<T>(_ key: Self.Key) throws -> T where T: Decodable {
        try decode(T.self, forKey: key)
    }

    func decodeIfPresent<T>(_ key: Self.Key) throws -> T? where T: Decodable {
        try decodeIfPresent(T.self, forKey: key)
    }
}

public extension KeyedDecodingContainer {
    func decode<T>(_ key: KeyedDecodingContainer<K>.Key, configuration: T.DecodingConfiguration) throws -> T where T: DecodableWithConfiguration {
        try decode(T.self, forKey: key, configuration: configuration)
    }

    func decodeIfPresent<T, C>(_ key: KeyedDecodingContainer<K>.Key, configuration: C.Type) throws -> T? where T: DecodableWithConfiguration, C: DecodingConfigurationProviding, T.DecodingConfiguration == C.DecodingConfiguration {
        try decodeIfPresent(T.self, forKey: key, configuration: configuration)
    }
}
