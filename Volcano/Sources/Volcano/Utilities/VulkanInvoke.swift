//
//  VulkanInvoke.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import CVulkan

@_transparent
public func vulkanInvoke(_ invocation: () -> (VkResult)) throws {
    let result: VkResult = invocation()
    if result != .success {
        throw VulkanError.badResult(result)
    }
}

@_transparent
public func vulkanInvoke(_ invocation: @autoclosure () -> (VkResult)) throws {
    try vulkanInvoke {
        invocation()
    }
}

@_transparent
public func vulkanInvoke(_ invocation: () -> ()) throws {
    invocation()
}

@_transparent
public func vulkanInvoke(_ invocation: @autoclosure () -> ()) throws {
    invocation()
}
