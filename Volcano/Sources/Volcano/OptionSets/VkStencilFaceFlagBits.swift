//
//  VkStencilFaceFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

extension VkStencilFaceFlagBits {
    public static let faceFront = VK_STENCIL_FACE_FRONT_BIT
    public static let faceBack = VK_STENCIL_FACE_BACK_BIT
    public static let faceFrontAndBack = VK_STENCIL_FACE_FRONT_AND_BACK
    public static let frontAndBack = VK_STENCIL_FRONT_AND_BACK
}
