//
//  Utilities.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public func vulkanInvoke(_ invocation: () -> (VkResult)) throws {
    let result: VkResult = invocation()
    if result != VK_SUCCESS {
        throw VulkanError.badResult(result)
    }
}

public func vulkanInvoke(_ invocation: @autoclosure () -> (VkResult)) throws {
    try vulkanInvoke {
        invocation()
    }
}

public func vulkanInvoke(_ invocation: () -> ()) throws {
    invocation()
}

public func vulkanInvoke(_ invocation: @autoclosure () -> ()) throws {
    invocation()
}

public typealias CreatorFunction<Parent, Info, Callbacks, Result> = (UnsafeMutablePointer<Parent>?, UnsafePointer<Info>?, UnsafePointer<Callbacks>?, UnsafeMutablePointer<UnsafeMutablePointer<Result>?>?) -> (VkResult)


internal protocol VulkanEntityFactory {}

internal extension UnsafeMutablePointer where Pointee: VulkanEntityFactory {
    func createEntity<Info, Callbacks, Result>(info: UnsafePointer<Info>, callbacks: UnsafePointer<Callbacks>? = nil, using creator: CreatorFunction<Self.Pointee, Info, Callbacks, Result>) throws -> UnsafeMutablePointer<Result> {
        var result: UnsafeMutablePointer<Result>?
        try vulkanInvoke (
            creator(self, info, callbacks, &result)
        )
        return result!
    }
}
