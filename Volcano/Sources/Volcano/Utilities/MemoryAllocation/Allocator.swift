//
//  Allocator.swift
//  Volcano
//
//  Created by Serhii Mumriak on 06.07.2020.
//

public protocol VulkanMemoryAllocator {
    var device: Device { get }

    init(device: Device)
}

public class DefaultAllocator: VulkanMemoryAllocator {
    public internal(set) unowned var device: Device

    public required init(device: Device) {
        self.device = device
    }
}
