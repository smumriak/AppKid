//
//  EntityFactory.swift
//  Volcano
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

internal protocol EntityFactory {}

internal extension UnsafeMutablePointer where Pointee: EntityFactory {
    typealias CreatorFunction<Parent, Info, Callbacks, Result> = (UnsafeMutablePointer<Parent>?, UnsafePointer<Info>?, UnsafePointer<Callbacks>?, UnsafeMutablePointer<UnsafeMutablePointer<Result>?>?) -> (VkResult)

    func createEntity<Info, Callbacks, Result>(info: UnsafePointer<Info>, callbacks: UnsafePointer<Callbacks>? = nil, using creator: CreatorFunction<Self.Pointee, Info, Callbacks, Result>) throws -> UnsafeMutablePointer<Result> {
        var result: UnsafeMutablePointer<Result>?
        try vulkanInvoke (
            creator(self, info, callbacks, &result)
        )
        return result!
    }
}
