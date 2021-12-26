//
//  CGRect+GLM.swift
//  SimpleGLM
//
//  Created by Serhii Mumriak on 05.09.2020.
//

import Foundation
import cglm

public extension CGRect {
    @_transparent
    var vec4: vec4s { vec4s(origin.x, origin.y, size.width, size.height) }
}
