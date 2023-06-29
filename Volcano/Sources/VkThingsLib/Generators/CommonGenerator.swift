//
//  CommonGenerator.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

import Foundation

public protocol Generator {
    func resultString(with parser: __shared Parser) throws -> String
}

public extension Generator {
    func write(to fileURL: URL, parser: __shared Parser) throws {
        try resultString(with: parser).write(to: fileURL, atomically: true, encoding: .utf8)
    }
}
