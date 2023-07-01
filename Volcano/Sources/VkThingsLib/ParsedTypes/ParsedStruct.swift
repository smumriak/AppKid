//
//  ParsedStruct.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public struct ParsedStruct: VulkanType {
    public let name: String
    public var cDefines: [String] = []
    public var swiftDefines: [String] = []
    public let typeName: String
    public let isInput: Bool

    public init?(typeDefinition: TypeDefinition) {
        assert(typeDefinition.category == .structure)
        
        guard let structureName = typeDefinition.name else {
            return nil
        }

        let typeMember = typeDefinition.members.first {
            $0.name == "sType"
        }

        guard let typeMember = typeMember else {
            return nil
        }

        guard let structureTypeName = typeMember.values else {
            return nil
        }

        let nextMember = typeDefinition.members.first {
            $0.name == "pNext"
        }

        guard let nextMember = nextMember else {
            return nil
        }

        if let textElements = nextMember.textElements {
            isInput = textElements.contains {
                $0.hasPrefix("const")
            }
        } else {
            isInput = false
        }

        name = structureName
        typeName = structureTypeName
    }

    public var vulkanStructureExtensionString: String {
        let template: String

        if isInput {
            template = Templates.inputStructureExtension
        } else {
            template = Templates.outputStructureExtension
        }

        var result: [String] = []

        result += swiftProtectiveIfs

        result += [
            template.components(separatedBy: .newlines)
                .map { indentation + $0 }
                .joined(separator: .newline)
                .replacingOccurrences(of: "<NAME>", with: name)
                .replacingOccurrences(of: "<TYPE>", with: "." + typeName),
        ]

        result += swiftProtectiveEndifs

        return result.joined(separator: .newline)
    }
}
