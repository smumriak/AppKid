//
//  CGSize+GLM.swift
//  SimpleGLM
//
//  Created by Serhii Mumriak on 05.09.2020.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import CoreGraphics
#else
    import Foundation
#endif

public extension CGSize {
    @_transparent
    var vec2: vec2s { vec2s(width, height) }
}
