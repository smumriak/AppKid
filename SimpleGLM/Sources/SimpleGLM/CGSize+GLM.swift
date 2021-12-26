//
//  CGSize+GLM.swift
//  SimpleGLM
//
//  Created by Serhii Mumriak on 05.09.2020.
//

import Foundation
import cglm

public extension CGSize {
    @_transparent
    var vec2: vec2s { vec2s(width, height) }
}
