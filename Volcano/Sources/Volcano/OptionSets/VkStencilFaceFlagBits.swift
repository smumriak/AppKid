//
//  VkStencilFaceFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkStencilFaceFlagBits = CVulkan.VkStencilFaceFlagBits

public extension VkStencilFaceFlagBits {
    static let faceFront = VK_STENCIL_FACE_FRONT_BIT
    static let faceBack = VK_STENCIL_FACE_BACK_BIT
    static let faceFrontAndBack = VK_STENCIL_FACE_FRONT_AND_BACK
    static let frontAndBack = VK_STENCIL_FRONT_AND_BACK
}
