//
//  CGSize+GLM.swift
//  SimpleGLM
//
//  Created by Serhii Mumriak on 05.09.2020.
//

import Foundation
import cglm

public extension CGSize {
    @inlinable @inline(__always)
    var glmVector: vec2s { vec2s(width, height) }
}
