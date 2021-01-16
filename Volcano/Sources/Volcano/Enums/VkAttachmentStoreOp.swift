//
//  VkAttachmentStoreOp.swift
//  Volcano
//
//  Created by Serhii Mumriak on 15.08.2020.
//

import CVulkan

public typealias VkAttachmentStoreOp = CVulkan.VkAttachmentStoreOp

public extension VkAttachmentStoreOp {
    static let store = VK_ATTACHMENT_STORE_OP_STORE
    static let dontCare = VK_ATTACHMENT_STORE_OP_DONT_CARE
    static let noneQCom = VK_ATTACHMENT_STORE_OP_NONE_QCOM
}
