//
//  VulkanType.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public protocol VulkanType {
    var name: String { get }
    var cDefines: [String] { get }
    var swiftDefines: [String] { get }
}

public extension VulkanType {
    var exportString: String {
        var result: [String] = []

        result += swiftDefines.map {
            "#if \($0)"
        }

        result += ["public typealias \(name) = CVulkan.\(name)"]

        result += swiftDefines.map { _ in
            "#endif"
        }

        return result.joined(separator: "\n")
    }
}
