//
//  FoundationGeometry.swift
//  Volcano
//
//  Created by Serhii Mumriak on 20.01.2021.
//

import Foundation
import CVulkan

public extension CGPoint {
    var vkOffset2D: VkOffset2D { VkOffset2D(x: CInt(ceil(x)), y: CInt(ceil(y))) }
}

public extension CGSize {
    var vkExtent2D: VkExtent2D { VkExtent2D(width: CUnsignedInt(ceil(width)), height: CUnsignedInt(ceil(height))) }
}

public extension CGRect {
    var vkRect2D: VkRect2D {
        let standardized = self.standardized
        return VkRect2D(offset: standardized.origin.vkOffset2D, extent: standardized.size.vkExtent2D)
    }
}
