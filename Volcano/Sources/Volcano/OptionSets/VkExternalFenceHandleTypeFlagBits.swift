//
//  VkExternalFenceHandleTypeFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.07.2021.
//

import CVulkan

public typealias VkExternalFenceHandleTypeFlagBits = CVulkan.VkExternalFenceHandleTypeFlagBits

public extension VkExternalFenceHandleTypeFlagBits {
    static let opaqueFileDescriptor: Self = .VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_FD_BIT
    static let opaqueWin32Handle: Self = .VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_WIN32_BIT
    static let opaqueWin32KmtHandle: Self = .VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT
    static let syncFileDescriptor: Self = .VK_EXTERNAL_FENCE_HANDLE_TYPE_SYNC_FD_BIT
}
