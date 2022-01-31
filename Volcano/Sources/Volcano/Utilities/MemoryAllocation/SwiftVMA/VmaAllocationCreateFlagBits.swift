//
//  VmaAllocationCreateFlagBits.swift
//  Volcano
//
//  Created by Serhii Mumriak on 03.10.2021.
//

import TinyFoundation
import VulkanMemoryAllocatorAdapted

public typealias VmaAllocationCreateFlagBits = VulkanMemoryAllocatorAdapted.VmaAllocationCreateFlagBits

public extension VmaAllocationCreateFlagBits {
    static let dedicatedMemory: Self = .VMA_ALLOCATION_CREATE_DEDICATED_MEMORY_BIT
    static let neverAllocate: Self = .VMA_ALLOCATION_CREATE_NEVER_ALLOCATE_BIT
    static let mapped: Self = .VMA_ALLOCATION_CREATE_MAPPED_BIT
    static let userDataCopyString: Self = .VMA_ALLOCATION_CREATE_USER_DATA_COPY_STRING_BIT
    static let upperAddress: Self = .VMA_ALLOCATION_CREATE_UPPER_ADDRESS_BIT
    static let dontBind: Self = .VMA_ALLOCATION_CREATE_DONT_BIND_BIT
    static let withinBudget: Self = .VMA_ALLOCATION_CREATE_WITHIN_BUDGET_BIT
    static let canAlias: Self = VMA_ALLOCATION_CREATE_CAN_ALIAS_BIT
    static let strategyMinMemory: Self = .VMA_ALLOCATION_CREATE_STRATEGY_MIN_MEMORY_BIT
    static let strategyMinTime: Self = .VMA_ALLOCATION_CREATE_STRATEGY_MIN_TIME_BIT
    static let strategyMask: Self = .VMA_ALLOCATION_CREATE_STRATEGY_MASK
}
