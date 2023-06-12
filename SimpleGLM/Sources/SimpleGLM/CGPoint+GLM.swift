//
//  CGPoint+GLM.swift
//  SimpleGLM
//
//  Created by Serhii Mumriak on 05.09.2020.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import CoreGraphics
#else
    import Foundation
#endif

public extension CGPoint {
    @_transparent
    var vec2: vec2s { vec2s(x, y) }
}
