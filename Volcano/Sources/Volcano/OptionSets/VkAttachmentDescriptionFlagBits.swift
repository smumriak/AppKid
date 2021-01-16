//
//  VkAttachmentDescriptionFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkAttachmentDescriptionFlagBits = CVulkan.VkAttachmentDescriptionFlagBits

public extension VkAttachmentDescriptionFlagBits {
    static let mayAlias = VK_ATTACHMENT_DESCRIPTION_MAY_ALIAS_BIT
}
