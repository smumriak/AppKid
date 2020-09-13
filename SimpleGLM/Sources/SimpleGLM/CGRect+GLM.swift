//
//  CGRect+GLM.swift
//  SimpleGLM
//
//  Created by Serhii Mumriak on 05.09.2020.
//

import Foundation
import cglm

public extension CGRect {
    @inlinable @inline(__always)
    func glmVetices(clockwise: Bool = true) -> [vec2s] {
        if clockwise {
            return [vec2s(minX, minY), vec2s(maxX, minY), vec2s(maxX, maxY), vec2s(minX, maxY)]
        } else {
            return [vec2s(minX, minY), vec2s(minX, maxY), vec2s(maxX, maxY), vec2s(maxX, minY)]
        }
    }
}
