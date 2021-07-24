//
//  VkExternalFenceFeatureFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.07.2021.
//

import CVulkan

public typealias VkExternalFenceFeatureFlagBits = CVulkan.VkExternalFenceFeatureFlagBits

public extension VkExternalFenceFeatureFlagBits {
    static let exportable: Self = .VK_EXTERNAL_FENCE_FEATURE_EXPORTABLE_BIT
    static let importable: Self = .VK_EXTERNAL_FENCE_FEATURE_IMPORTABLE_BIT
}
