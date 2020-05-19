//
//  VulkanPhysicalDevice+DataLoading.swift
//  Volcano
//
//  Created by Serhii Mumriak on 18.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

internal extension UnsafeMutablePointer where Pointee == VkPhysicalDevice_T {
    typealias OwnDataLoader<Result> = (Self?, UnsafeMutablePointer<Result>?) -> ()
    typealias ChildDataLoader<Child, Result> = (Self?, UnsafeMutablePointer<Child>?, UnsafeMutablePointer<Result>?) -> (VkResult)
    typealias OwnDataArrayLoader<Result> = (Self?, UnsafeMutablePointer<CUnsignedInt>?, UnsafeMutablePointer<Result>?) -> ()
    typealias ChildDataArrayLoader<Child, Result> = (Self?, UnsafeMutablePointer<Child>?, UnsafeMutablePointer<CUnsignedInt>?, UnsafeMutablePointer<Result>?) -> (VkResult)

    func loadData<Result>(using loader: OwnDataLoader<Result>) throws -> Result {
        var result = UnsafeMutablePointer<Result>.allocate(capacity: 1)
        defer { result.deallocate() }

        try vulkanInvoke {
            loader(self, result)
        }
        return result.pointee
    }

    func loadData<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: ChildDataLoader<Child, Result>) throws -> Result {
        var result = UnsafeMutablePointer<Result>.allocate(capacity: 1)
        defer { result.deallocate() }

        try vulkanInvoke {
            loader(self, childPointer, result)
        }
        return result.pointee
    }

    func loadDataArray<Result>(using loader: OwnDataArrayLoader<Result>) throws -> [Result] {
        var resultsCount: CUnsignedInt = 0;
        try vulkanInvoke {
            loader(self, &resultsCount, nil)
        }

        var resultsBuffer = UnsafeMutablePointer<Result>.allocate(capacity: Int(resultsCount))
        defer { resultsBuffer.deallocate() }

        try vulkanInvoke {
            loader(self, &resultsCount, resultsBuffer)
        }

        return UnsafeBufferPointer(start: resultsBuffer, count: Int(resultsCount)).map { $0 }
    }

    func loadDataArray<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: ChildDataArrayLoader<Child, Result>) throws -> [Result] {
        var resultsCount: CUnsignedInt = 0;
        try vulkanInvoke {
            loader(self, childPointer, &resultsCount, nil)
        }

        var resultsBuffer = UnsafeMutablePointer<Result>.allocate(capacity: Int(resultsCount))
        defer { resultsBuffer.deallocate() }

        try vulkanInvoke {
            loader(self, childPointer, &resultsCount, resultsBuffer)
        }

        return UnsafeBufferPointer(start: resultsBuffer, count: Int(resultsCount)).map { $0 }
    }
}

internal extension SmartPointer where Pointee == VkPhysicalDevice_T {
    func loadData<Result>(using loader: VkPhysicalDevice.OwnDataLoader<Result>) throws -> Result {
        return try pointer.loadData(using: loader)
    }

    func loadData<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: VkPhysicalDevice.ChildDataLoader<Child, Result>) throws -> Result {
        return try pointer.loadData(for: childPointer, using: loader)
    }

    func loadDataArray<Result>(using loader: VkPhysicalDevice.OwnDataArrayLoader<Result>) throws -> [Result] {
        return try pointer.loadDataArray(using: loader)
    }

    func loadDataArray<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: VkPhysicalDevice.ChildDataArrayLoader<Child, Result>) throws -> [Result] {
        return try pointer.loadDataArray(for: childPointer, using: loader)
    }
}

internal extension VulkanPhysicalDevice {
    func loadData<Result>(using loader: VkPhysicalDevice.OwnDataLoader<Result>) throws -> Result {
        return try handle.loadData(using: loader)
    }

    func loadData<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: VkPhysicalDevice.ChildDataLoader<Child, Result>) throws -> Result {
        return try handle.loadData(for: childPointer, using: loader)
    }

    func loadDataArray<Result>(using loader: VkPhysicalDevice.OwnDataArrayLoader<Result>) throws -> [Result] {
        return try handle.loadDataArray(using: loader)
    }

    func loadDataArray<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: VkPhysicalDevice.ChildDataArrayLoader<Child, Result>) throws -> [Result] {
        return try handle.loadDataArray(for: childPointer, using: loader)
    }
}
