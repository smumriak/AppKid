//
//  SwiftFileGenerator.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public protocol SwiftFileGenerator: Generator {}

public extension SwiftFileGenerator {
    var tinyFoundation: String {
        "import TinyFoundation"
    }

    var foundation: String {
        "import Foundation"
    }

    func top(from parser: Parser) throws -> String {
        """
        #if VULKAN_VERSION_\(parser.version.description.replacingOccurrences(of: ".", with: "_"))
        """
    }

    func bottom(from parser: Parser) throws -> String {
        """
        #endif // VULKAN_VERSION_\(parser.version.description.replacingOccurrences(of: ".", with: "_"))
        """
    }
}
