//
//  Thread+Main.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 12.01.2023
//

#if !os(macOS)
    import Foundation

    public extension Thread {
        @_transparent
        static var main: Thread {
            return .mainThread
        }
    }
#endif
