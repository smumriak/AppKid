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

        result += swiftProtectiveIfs

        result += [indentation + "public typealias \(name) = CVulkan.\(name)"]

        result += swiftProtectiveEndifs

        return result.joined(separator: .newline)
    }

    var indentation: String {
        (0..<swiftDefines.count).reduce("") { accumulator, index in
            accumulator + kIndentationUnit
        }
    }

    var swiftProtectiveIfs: [String] {
        swiftDefines.enumerated().map {
            let indentation = (0..<$0.offset).reduce("") { accumulator, index in
                accumulator + kIndentationUnit
            }
            return indentation + "#if \($0.element)"
        }
    }

    var swiftProtectiveEndifs: [String] {
        swiftDefines.enumerated().reversed().map {
            let indentation = (0..<$0.offset).reduce("") { accumulator, index in
                accumulator + kIndentationUnit
            }
            return indentation + "#endif"
        }
    }

    var cProtectiveIfs: [String] {
        cDefines.enumerated().map {
            let indentation = (0..<$0.offset).reduce("") { accumulator, index in
                accumulator + kIndentationUnit
            }
            return indentation + "#ifdef \($0.element)"
        }
    }

    var cProtectiveEndifs: [String] {
        cDefines.enumerated().reversed().map {
            let indentation = (0..<$0.offset).reduce("") { accumulator, index in
                accumulator + kIndentationUnit
            }
            return indentation + "#endif"
        }
    }
}
