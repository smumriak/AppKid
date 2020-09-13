//
//  CGPoint+GLM.swift
//  SimpleGLM
//
//  Created by Serhii Mumriak on 05.09.2020.
//

import Foundation
import cglm

public extension CGPoint {
    @inlinable @inline(__always)
    var glmVector: vec2s { vec2s(x, y) }
}
