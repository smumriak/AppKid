//
//  ParsedDeviceExtension.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public struct ParsedDeviceExtension: ParsedExtension {
    public let name: String
    public let version: String
    public var cDefines: [String] = []
    public var swiftDefines: [String] = []
    
    public init(extensionDefinition: ExtensionDefinition) {
        assert(extensionDefinition.extensionType == .device)
        name = extensionDefinition.name
        version = extensionDefinition.number
    }
}
