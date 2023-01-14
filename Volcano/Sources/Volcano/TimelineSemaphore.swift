//
//  TimelineSemaphore.swift
//  Volcano
//
//  Created by Serhii Mumriak on 22.07.2021.
//

import Foundation
import TinyFoundation
import CVulkan

public final class TimelineSemaphore: AbstractSemaphore {
    public init(device: Device, initialValue: UInt64 = 0) throws {
        var typeInfo = VkSemaphoreTypeCreateInfo.new()
        typeInfo.semaphoreType = .timeline
        typeInfo.initialValue = initialValue

        let handle: SharedPointer<VkSemaphore_T> = try withUnsafePointer(to: &typeInfo) { typeInfo in
            var info = VkSemaphoreCreateInfo(sType: .semaphoreCreateInfo, pNext: typeInfo, flags: 0)

            return try device.create(with: &info)
        }

        _value = initialValue

        try super.init(device: device, handle: handle)
    }

    internal let valueLock = RecursiveLock()
    internal var _value: UInt64
    public var value: UInt64 {
        get throws {
            return try valueLock.synchronized {
                try vulkanInvoke {
                    device.vkGetSemaphoreCounterValueKHR(device.pointer, pointer, &_value)
                }

                return _value
            }
        }
    }

    public func wait(value: UInt64? = nil, timeout: UInt64 = .max) throws {
        let value: UInt64 = {
            if let value = value {
                return value
            } else {
                return valueLock.synchronized { _value + 1 }
            }
        }()

        try LavaBuilder<VkSemaphoreWaitInfo> {
            \.flags <- VkSemaphoreWaitFlagBits()
            (\.semaphoreCount, \.pSemaphores) <- [self]
            \.pValues <- [value]
        }.withUnsafeResultPointer { info in
            try vulkanInvoke {
                device.vkWaitSemaphoresKHR(device.pointer, info, timeout)
            }
        }
    }

    public func signal(increment: UInt64 = 1) throws {
        try valueLock.synchronized {
            var info = VkSemaphoreSignalInfo.new()
            info.semaphore = pointer
            info.value = _value + increment

            try vulkanInvoke {
                device.vkSignalSemaphoreKHR(device.pointer, &info)
            }

            _value = info.value
        }
    }
}

extension Device {
    func wait(for semaphores: [TimelineSemaphore], values: [UInt64], waitForAll: Bool = true, timeout: UInt64 = .max) throws {
        assert(semaphores.count == values.count)

        try LavaBuilder<VkSemaphoreWaitInfo> {
            \.flags <- waitForAll ? [] : VkSemaphoreWaitFlagBits.any
            (\.semaphoreCount, \.pSemaphores) <- semaphores
            \.pValues <- values
        }.withUnsafeResultPointer { info in
            try vulkanInvoke {
                vkWaitSemaphoresKHR(pointer, info, timeout)
            }
        }
    }
}
