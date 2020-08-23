//
//  EntityInfo.swift
//  Volcano
//
//  Created by Serhii Mumriak on 23.07.2020.
//

public protocol EntityInfo {
    associatedtype Parent: EntityFactory
    associatedtype Result

    typealias CreateFunction = (UnsafeMutablePointer<Parent>?, UnsafePointer<Self>?, UnsafePointer<VkAllocationCallbacks>?, UnsafeMutablePointer<UnsafeMutablePointer<Result>?>?) -> (VkResult)
    static var createFunction: CreateFunction { get }

    typealias DeleteFunction = (UnsafeMutablePointer<Parent>?, UnsafeMutablePointer<Result>?, UnsafePointer<VkAllocationCallbacks>?) -> ()
    static var deleteFunction: DeleteFunction { get }
}
