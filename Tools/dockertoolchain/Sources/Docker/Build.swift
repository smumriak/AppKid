//
//  Build.swift
//  dockertoolchain
//
//  Created by Serhii Mumriak on 03.07.2023
//

import Cuisine

public extension Docker {
    struct Build: DockerCommand {
        public enum Flag: String, StringListRepresentable {
            case noCache = "no-cache"
            public var stringList: [String] {
                [rawValue].map {
                    if $0.count == 1 {
                        return "-" + $0
                    } else {
                        return "--" + $0
                    }
                }
            }
        }

        public enum Option: StringListRepresentable {
            case file(name: String)
            case buildArgument(String)

            public var rawValue: String {
                stringList.joined(separator: " ")
            }

            public var stringList: [String] {
                switch self {
                    case let .file(name):
                        return [
                            "-f",
                            name,
                        ]

                    case let .buildArgument(value):
                        return [
                            "--build-arg",
                            value,
                        ]
                }
            }
        }

        public enum Argument: StringListRepresentable {
            case directory(name: String)

            public var stringList: [String] {
                switch self {
                    case let .directory(name):
                        return [name]
                }
            }
        }

        public let name = "build"

        public let flags: [Flag]
        public let options: [Option]
        public let arguments: [Argument]
    
        public init(flags: [Flag], options: [Option], arguments: [Argument]) {
            self.flags = flags
            self.options = options
            self.arguments = arguments
        }

        public func arguments(in kitchen: any Kitchen, pantry: Pantry) async throws -> [String] {
            []
        }
    }
}
