//
//  VsSubpassContents.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.08.2020.
//

import CVulkan

public typealias VkSubpassContents = CVulkan.VkSubpassContents

public extension VkSubpassContents {
    static let inline: Self = .VK_SUBPASS_CONTENTS_INLINE
    static let secondaryCommandBuffers: Self = .VK_SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS
}
