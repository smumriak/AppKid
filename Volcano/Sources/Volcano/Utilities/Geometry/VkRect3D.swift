//
//  VkRect3D.swift
//  Volcano
//
//  Created by Serhii Mumriak on 22.06.2021.
//

import CVulkan

public struct VkRect3D {
    public let offset: VkOffset3D
    public let extent: VkExtent3D
}

public extension VkRect3D {
    static let zero: VkRect3D = VkRect3D(offset: .zero, extent: .zero)

    @_transparent
    var width: CUnsignedInt { extent.width }

    @_transparent
    var height: CUnsignedInt { extent.height }

    @_transparent
    var depth: CUnsignedInt { extent.depth }
}
