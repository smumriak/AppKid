//
//  VkSparseImageFormatFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 16.08.2020.
//

import CVulkan

public extension VkSparseImageFormatFlagBits {
    static let singleMiptail = VK_SPARSE_IMAGE_FORMAT_SINGLE_MIPTAIL_BIT
    static let alignedMipSize = VK_SPARSE_IMAGE_FORMAT_ALIGNED_MIP_SIZE_BIT
    static let nonstandardBlockSize = VK_SPARSE_IMAGE_FORMAT_NONSTANDARD_BLOCK_SIZE_BIT
}
