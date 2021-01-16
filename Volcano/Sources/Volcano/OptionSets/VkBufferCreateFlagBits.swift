//
//  VkBufferCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkBufferCreateFlagBits = CVulkan.VkBufferCreateFlagBits

public extension VkBufferCreateFlagBits {
    static let sparseBinding = VK_BUFFER_CREATE_SPARSE_BINDING_BIT
    static let sparseResidency = VK_BUFFER_CREATE_SPARSE_RESIDENCY_BIT
    static let sparseAliased = VK_BUFFER_CREATE_SPARSE_ALIASED_BIT
    static let protected = VK_BUFFER_CREATE_PROTECTED_BIT
    static let deviceAddressCaptureReplay = VK_BUFFER_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT
    static let deviceAddressCaptureReplayExt = VK_BUFFER_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT_EXT
    static let deviceAddressCaptureReplayKhr = VK_BUFFER_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT_KHR
}
