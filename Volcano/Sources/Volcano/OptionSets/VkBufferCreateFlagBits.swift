//
//  VkBufferCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

extension VkBufferCreateFlagBits {
    public static let sparseBinding = VK_BUFFER_CREATE_SPARSE_BINDING_BIT
    public static let sparseResidency = VK_BUFFER_CREATE_SPARSE_RESIDENCY_BIT
    public static let sparseAliased = VK_BUFFER_CREATE_SPARSE_ALIASED_BIT
    public static let protected = VK_BUFFER_CREATE_PROTECTED_BIT
    public static let deviceAddressCaptureReplay = VK_BUFFER_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT
    public static let deviceAddressCaptureReplayExt = VK_BUFFER_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT_EXT
    public static let deviceAddressCaptureReplayKhr = VK_BUFFER_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT_KHR
}
