//
//  VmaMemoryUsage.swift
//  SwiftVMA
//
//  Created by Serhii Mumriak on 03.10.2021.
//

import TinyFoundation
import CVulkan
import Volcano
import VulkanMemoryAllocatorAdapted

public typealias VmaMemoryUsage = VulkanMemoryAllocatorAdapted.VmaMemoryUsage

public extension VmaMemoryUsage {
    static let unknown: Self = .VMA_MEMORY_USAGE_UNKNOWN
    static let gpuOnly: Self = .VMA_MEMORY_USAGE_GPU_ONLY
    static let cpuOnly: Self = .VMA_MEMORY_USAGE_CPU_ONLY
    static let cpuToGpu: Self = .VMA_MEMORY_USAGE_CPU_TO_GPU
    static let gpuToCpu: Self = .VMA_MEMORY_USAGE_GPU_TO_CPU
    static let cpuCopy: Self = .VMA_MEMORY_USAGE_CPU_COPY
    static let gpuLazilyAllocated: Self = .VMA_MEMORY_USAGE_GPU_LAZILY_ALLOCATED
}
