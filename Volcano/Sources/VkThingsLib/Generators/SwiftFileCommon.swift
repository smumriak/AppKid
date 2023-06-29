//
//  SwiftFileCommon.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

public protocol SwiftFileGenerator: Generator {}

public extension SwiftFileGenerator {
    var tinyFoundation: String {
        """
        import TinyFoundation
        
        """
    }
}
