//
//  InstanceEntityInfo.swift
//  Volcano
//
//  Created by Serhii Mumriak on 22.07.2020.
//

public protocol InstanceEntityInfo: EntityInfo {
    typealias Parent = VkInstance.Pointee
}

#if os(Linux)
extension VkXlibSurfaceCreateInfoKHR: InstanceEntityInfo {
    public typealias Result = VkSurfaceKHR.Pointee
    public static let createFunction: CreateFunction = vkCreateXlibSurfaceKHR
    public static let deleteFunction: DeleteFunction = vkDestroySurfaceKHR
}
#elseif os(macOS)
extension VkMacOSSurfaceCreateInfoMVK: InstanceEntityInfo {
    public typealias Result = VkSurfaceKHR.Pointee
    public static let createFunction: CreateFunction = vkCreateMacOSSurfaceMVK
    public static let deleteFunction: DeleteFunction = vkDestroySurfaceKHR
}
#endif
