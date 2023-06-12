//
//  TypeConvenience.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

public extension Bool {
    @_transparent
    var vkBool: VkBool32 { self ? VkBool32(VK_TRUE) : VkBool32(VK_FALSE) }
}

public extension VkBool32 {
    @_transparent
    var bool: Bool { self == VkBool32(VK_FALSE) ? false : true }
}

public extension VkOffset2D {
    static let zero = VkOffset2D(x: 0, y: 0)
}

public extension VkOffset3D {
    static let zero = VkOffset3D(x: 0, y: 0, z: 0)
}

public extension VkExtent2D {
    static let zero = VkExtent2D(width: 0, height: 0)
}

public extension VkExtent3D {
    static let zero = VkExtent3D(width: 0, height: 0, depth: 0)
}

public extension VkRect2D {
    static let zero = VkRect2D(offset: .zero, extent: .zero)
}
