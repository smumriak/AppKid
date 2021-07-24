//
//  VkBufferCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public typealias VkBufferCreateFlagBits = CVulkan.VkBufferCreateFlagBits

public extension VkBufferCreateFlagBits {
    static let sparseBinding: Self = .VK_BUFFER_CREATE_SPARSE_BINDING_BIT
    static let sparseResidency: Self = .VK_BUFFER_CREATE_SPARSE_RESIDENCY_BIT
    static let sparseAliased: Self = .VK_BUFFER_CREATE_SPARSE_ALIASED_BIT
    static let protected: Self = .VK_BUFFER_CREATE_PROTECTED_BIT
    static let deviceAddressCaptureReplay: Self = .VK_BUFFER_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT
    static let deviceAddressCaptureReplayExt: Self = .VK_BUFFER_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT_EXT
    static let deviceAddressCaptureReplayKhr: Self = .VK_BUFFER_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT_KHR
}
