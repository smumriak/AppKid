//
//  VkAttachmentLoadOp.swift
//  Volcano
//
//  Created by Serhii Mumriak on 15.08.2020.
//

import CVulkan

public typealias VkAttachmentLoadOp = CVulkan.VkAttachmentLoadOp

public extension VkAttachmentLoadOp {
    static let load: Self = .VK_ATTACHMENT_LOAD_OP_LOAD
    static let clear: Self = .VK_ATTACHMENT_LOAD_OP_CLEAR
    static let dontCare: Self = .VK_ATTACHMENT_LOAD_OP_DONT_CARE
}
