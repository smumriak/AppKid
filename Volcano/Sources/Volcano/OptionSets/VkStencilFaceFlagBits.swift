//
//  VkStencilFaceFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkStencilFaceFlagBits = CVulkan.VkStencilFaceFlagBits

public extension VkStencilFaceFlagBits {
    static let faceFront: Self = .VK_STENCIL_FACE_FRONT_BIT
    static let faceBack: Self = .VK_STENCIL_FACE_BACK_BIT
    static let faceFrontAndBack: Self = .VK_STENCIL_FACE_FRONT_AND_BACK
    static let frontAndBack: Self = .VK_STENCIL_FRONT_AND_BACK
}
