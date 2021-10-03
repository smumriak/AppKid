//
//  VmaAllocationCreateFlagBits.swift
//  SwiftVMA
//
//  Created by Serhii Mumriak on 03.10.2021.
//

import TinyFoundation
import CVulkan
import Volcano
import VulkanMemoryAllocatorAdapted

public typealias VmaAllocationCreateFlagBits = VulkanMemoryAllocatorAdapted.VmaAllocationCreateFlagBits

public extension VmaAllocationCreateFlagBits {
    static let dedicatedMemory: Self = .VMA_ALLOCATION_CREATE_DEDICATED_MEMORY_BIT
    static let neverAllocate: Self = .VMA_ALLOCATION_CREATE_NEVER_ALLOCATE_BIT
    static let mapped: Self = .VMA_ALLOCATION_CREATE_MAPPED_BIT
    static let canBecomeLost: Self = .VMA_ALLOCATION_CREATE_CAN_BECOME_LOST_BIT
    static let canMakeOtherLost: Self = .VMA_ALLOCATION_CREATE_CAN_MAKE_OTHER_LOST_BIT
    static let userDataCopyString: Self = .VMA_ALLOCATION_CREATE_USER_DATA_COPY_STRING_BIT
    static let upperAddress: Self = .VMA_ALLOCATION_CREATE_UPPER_ADDRESS_BIT
    static let dontBind: Self = .VMA_ALLOCATION_CREATE_DONT_BIND_BIT
    static let withinBudget: Self = .VMA_ALLOCATION_CREATE_WITHIN_BUDGET_BIT
    static let strategyBestFit: Self = .VMA_ALLOCATION_CREATE_STRATEGY_BEST_FIT_BIT
    static let strategyWorstFit: Self = .VMA_ALLOCATION_CREATE_STRATEGY_WORST_FIT_BIT
    static let strategyFirstFit: Self = .VMA_ALLOCATION_CREATE_STRATEGY_FIRST_FIT_BIT
    static let strategyMinMemory: Self = .VMA_ALLOCATION_CREATE_STRATEGY_MIN_MEMORY_BIT
    static let strategyMinTime: Self = .VMA_ALLOCATION_CREATE_STRATEGY_MIN_TIME_BIT
    static let strategyMinFragmentation: Self = .VMA_ALLOCATION_CREATE_STRATEGY_MIN_FRAGMENTATION_BIT
    static let strategyMask: Self = .VMA_ALLOCATION_CREATE_STRATEGY_MASK
}
