//
//  DataLoader.swift
//  Volcano
//
//  Created by Serhii Mumriak on 18.05.2020.
//

import TinyFoundation
import CVulkan

internal protocol DataLoader {}

extension UnsafeMutablePointer where Pointee: DataLoader {
    typealias OwnData_f<Result> = (Self?, UnsafeMutablePointer<Result>?) -> ()
    typealias OwnDataWithInfo_f<Result, Info> = (Self?, UnsafePointer<Info>?, UnsafeMutablePointer<Result>?) -> ()
    typealias FailableOwnData_f<Result> = (Self?, UnsafeMutablePointer<Result>?) -> (VkResult)
    typealias FailableOwnDataWithInfo_f<Result, Info> = (Self?, UnsafePointer<Info>?, UnsafeMutablePointer<Result>?) -> (VkResult)
    typealias ChildData_f<Child, Result> = (Self?, UnsafeMutablePointer<Child>?, UnsafeMutablePointer<Result>?) -> ()
    typealias FailableChildData_f<Child, Result> = (Self?, UnsafeMutablePointer<Child>?, UnsafeMutablePointer<Result>?) -> (VkResult)

    typealias OwnDataArray_f<Result> = (Self?, UnsafeMutablePointer<CUnsignedInt>?, UnsafeMutablePointer<Result>?) -> ()
    typealias FailableOwnDataArray_f<Result> = (Self?, UnsafeMutablePointer<CUnsignedInt>?, UnsafeMutablePointer<Result>?) -> (VkResult)
    typealias ChildDataArray_f<Child, Result> = (Self?, UnsafeMutablePointer<Child>?, UnsafeMutablePointer<CUnsignedInt>?, UnsafeMutablePointer<Result>?) -> ()
    typealias FailableChildDataArray_f<Child, Result> = (Self?, UnsafeMutablePointer<Child>?, UnsafeMutablePointer<CUnsignedInt>?, UnsafeMutablePointer<Result>?) -> (VkResult)

    func loadData<Result: VulkanOutStructure>(using loader: OwnData_f<Result>) throws -> Result {
        var result = Result.new()

        try vulkanInvoke {
            loader(self, &result)
        }

        return result
    }

    func loadData<Result: PublicInitializable>(using loader: OwnData_f<Result>) throws -> Result {
        var result = Result()

        try vulkanInvoke {
            loader(self, &result)
        }

        return result
    }

    func loadData<Result: VulkanOutStructure, Info: VulkanInStructure>(with info: UnsafePointer<Info>, using loader: OwnDataWithInfo_f<Result, Info>) throws -> Result {
        var result = Result.new()

        try vulkanInvoke {
            loader(self, info, &result)
        }

        return result
    }

    func loadData<Result: PublicInitializable, Info: VulkanInStructure>(with info: UnsafePointer<Info>, using loader: OwnDataWithInfo_f<Result, Info>) throws -> Result {
        var result = Result()

        try vulkanInvoke {
            loader(self, info, &result)
        }

        return result
    }

    func loadData<Result: VulkanOutStructure>(using loader: FailableOwnData_f<Result>) throws -> Result {
        var result = Result.new()

        try vulkanInvoke {
            loader(self, &result)
        }

        return result
    }

    func loadData<Result: PublicInitializable>(using loader: FailableOwnData_f<Result>) throws -> Result {
        var result = Result()

        try vulkanInvoke {
            loader(self, &result)
        }

        return result
    }

    func loadData<Result: VulkanOutStructure, Info: VulkanInStructure>(with info: UnsafePointer<Info>, using loader: FailableOwnDataWithInfo_f<Result, Info>) throws -> Result {
        var result = Result.new()

        try vulkanInvoke {
            loader(self, info, &result)
        }

        return result
    }

    func loadData<Result: PublicInitializable, Info: VulkanInStructure>(with info: UnsafePointer<Info>, using loader: FailableOwnDataWithInfo_f<Result, Info>) throws -> Result {
        var result = Result()

        try vulkanInvoke {
            loader(self, info, &result)
        }

        return result
    }

    func loadData<Child, Result: VulkanOutStructure>(for childPointer: UnsafeMutablePointer<Child>, using loader: ChildData_f<Child, Result>) throws -> Result {
        var result = Result.new()

        try vulkanInvoke {
            loader(self, childPointer, &result)
        }

        return result
    }

    func loadData<Child, Result: PublicInitializable>(for childPointer: UnsafeMutablePointer<Child>, using loader: ChildData_f<Child, Result>) throws -> Result {
        var result = Result()

        try vulkanInvoke {
            loader(self, childPointer, &result)
        }

        return result
    }

    func loadData<Child, Result: VulkanOutStructure>(for childPointer: UnsafeMutablePointer<Child>, using loader: FailableChildData_f<Child, Result>) throws -> Result {
        var result = Result.new()

        try vulkanInvoke {
            loader(self, childPointer, &result)
        }

        return result
    }

    func loadData<Child, Result: PublicInitializable>(for childPointer: UnsafeMutablePointer<Child>, using loader: FailableChildData_f<Child, Result>) throws -> Result {
        var result = Result()

        try vulkanInvoke {
            loader(self, childPointer, &result)
        }

        return result
    }

    func loadDataArray<Result: PublicInitializable>(using loader: OwnDataArray_f<Result>) throws -> [Result] {
        var resultsCount: CUnsignedInt = 0
        try vulkanInvoke {
            loader(self, &resultsCount, nil)
        }

        var result: [Result] = Array(repeating: .init(), count: Int(resultsCount))

        try vulkanInvoke {
            loader(self, &resultsCount, &result)
        }

        return result
    }

    func loadDataArray<Result: PublicInitializable>(using loader: FailableOwnDataArray_f<Result>) throws -> [Result] {
        var resultsCount: CUnsignedInt = 0
        try vulkanInvoke {
            loader(self, &resultsCount, nil)
        }

        var result: [Result] = Array(repeating: .init(), count: Int(resultsCount))

        try vulkanInvoke {
            loader(self, &resultsCount, &result)
        }

        return result
    }

    func loadDataArray<Child, Result: PublicInitializable>(for childPointer: UnsafeMutablePointer<Child>, using loader: ChildDataArray_f<Child, Result>) throws -> [Result] {
        var resultsCount: CUnsignedInt = 0
        try vulkanInvoke {
            loader(self, childPointer, &resultsCount, nil)
        }

        var result: [Result] = Array(repeating: .init(), count: Int(resultsCount))

        try vulkanInvoke {
            loader(self, childPointer, &resultsCount, &result)
        }

        return result
    }

    func loadDataArray<Child, Result: PublicInitializable>(for childPointer: UnsafeMutablePointer<Child>, using loader: FailableChildDataArray_f<Child, Result>) throws -> [Result] {
        var resultsCount: CUnsignedInt = 0
        try vulkanInvoke {
            loader(self, childPointer, &resultsCount, nil)
        }

        var result: [Result] = Array(repeating: .init(), count: Int(resultsCount))

        try vulkanInvoke {
            loader(self, childPointer, &resultsCount, &result)
        }

        return result
    }
}

internal extension SmartPointerProtocol where Pointee: DataLoader {
    func loadData<Result: VulkanOutStructure>(using loader: Pointer_t.OwnData_f<Result>) throws -> Result {
        return try pointer.loadData(using: loader)
    }

    func loadData<Result: PublicInitializable>(using loader: Pointer_t.OwnData_f<Result>) throws -> Result {
        return try pointer.loadData(using: loader)
    }

    func loadData<Result: VulkanOutStructure, Info: VulkanInStructure>(with info: UnsafePointer<Info>, using loader: Pointer_t.OwnDataWithInfo_f<Result, Info>) throws -> Result {
        return try pointer.loadData(with: info, using: loader)
    }

    func loadData<Result: PublicInitializable, Info: VulkanInStructure>(with info: UnsafePointer<Info>, using loader: Pointer_t.OwnDataWithInfo_f<Result, Info>) throws -> Result {
        return try pointer.loadData(with: info, using: loader)
    }

    func loadData<Result: VulkanOutStructure>(using loader: Pointer_t.FailableOwnData_f<Result>) throws -> Result {
        return try pointer.loadData(using: loader)
    }

    func loadData<Result: PublicInitializable>(using loader: Pointer_t.FailableOwnData_f<Result>) throws -> Result {
        return try pointer.loadData(using: loader)
    }

    func loadData<Result: VulkanOutStructure, Info: VulkanInStructure>(with info: UnsafePointer<Info>, using loader: Pointer_t.FailableOwnDataWithInfo_f<Result, Info>) throws -> Result {
        return try pointer.loadData(with: info, using: loader)
    }

    func loadData<Result: PublicInitializable, Info: VulkanInStructure>(with info: UnsafePointer<Info>, using loader: Pointer_t.FailableOwnDataWithInfo_f<Result, Info>) throws -> Result {
        return try pointer.loadData(with: info, using: loader)
    }

    func loadData<Child, Result: VulkanOutStructure>(for childPointer: UnsafeMutablePointer<Child>, using loader: Pointer_t.ChildData_f<Child, Result>) throws -> Result {
        return try pointer.loadData(for: childPointer, using: loader)
    }

    func loadData<Child, Result: PublicInitializable>(for childPointer: UnsafeMutablePointer<Child>, using loader: Pointer_t.ChildData_f<Child, Result>) throws -> Result {
        return try pointer.loadData(for: childPointer, using: loader)
    }

    func loadData<Child, Result: VulkanOutStructure>(for childPointer: UnsafeMutablePointer<Child>, using loader: Pointer_t.FailableChildData_f<Child, Result>) throws -> Result {
        return try pointer.loadData(for: childPointer, using: loader)
    }

    func loadData<Child, Result: PublicInitializable>(for childPointer: UnsafeMutablePointer<Child>, using loader: Pointer_t.FailableChildData_f<Child, Result>) throws -> Result {
        return try pointer.loadData(for: childPointer, using: loader)
    }

    func loadDataArray<Result: PublicInitializable>(using loader: Pointer_t.OwnDataArray_f<Result>) throws -> [Result] {
        return try pointer.loadDataArray(using: loader)
    }

    func loadDataArray<Result: PublicInitializable>(using loader: Pointer_t.FailableOwnDataArray_f<Result>) throws -> [Result] {
        return try pointer.loadDataArray(using: loader)
    }

    func loadDataArray<Child, Result: PublicInitializable>(for childPointer: UnsafeMutablePointer<Child>, using loader: Pointer_t.ChildDataArray_f<Child, Result>) throws -> [Result] {
        return try pointer.loadDataArray(for: childPointer, using: loader)
    }

    func loadDataArray<Child, Result: PublicInitializable>(for childPointer: UnsafeMutablePointer<Child>, using loader: Pointer_t.FailableChildDataArray_f<Child, Result>) throws -> [Result] {
        return try pointer.loadDataArray(for: childPointer, using: loader)
    }
}

internal extension HandleStorage where Handle.Pointee: DataLoader {
    func loadData<Result: VulkanOutStructure>(using loader: Handle.Pointer_t.OwnData_f<Result>) throws -> Result {
        return try handle.loadData(using: loader)
    }

    func loadData<Result: PublicInitializable>(using loader: Handle.Pointer_t.OwnData_f<Result>) throws -> Result {
        return try handle.loadData(using: loader)
    }

    func loadData<Result: VulkanOutStructure, Info: VulkanInStructure>(with info: UnsafePointer<Info>, using loader: Handle.Pointer_t.OwnDataWithInfo_f<Result, Info>) throws -> Result {
        return try handle.loadData(with: info, using: loader)
    }

    func loadData<Result: PublicInitializable, Info: VulkanInStructure>(with info: UnsafePointer<Info>, using loader: Handle.Pointer_t.OwnDataWithInfo_f<Result, Info>) throws -> Result {
        return try handle.loadData(with: info, using: loader)
    }

    func loadData<Result: VulkanOutStructure>(using loader: Handle.Pointer_t.FailableOwnData_f<Result>) throws -> Result {
        return try handle.loadData(using: loader)
    }

    func loadData<Result: PublicInitializable>(using loader: Handle.Pointer_t.FailableOwnData_f<Result>) throws -> Result {
        return try handle.loadData(using: loader)
    }

    func loadData<Child, Result: VulkanOutStructure>(for childPointer: UnsafeMutablePointer<Child>, using loader: Handle.Pointer_t.ChildData_f<Child, Result>) throws -> Result {
        return try handle.loadData(for: childPointer, using: loader)
    }

    func loadData<Child, Result: PublicInitializable>(for childPointer: UnsafeMutablePointer<Child>, using loader: Handle.Pointer_t.ChildData_f<Child, Result>) throws -> Result {
        return try handle.loadData(for: childPointer, using: loader)
    }

    func loadData<Result: VulkanOutStructure, Info: VulkanInStructure>(with info: UnsafePointer<Info>, using loader: Handle.Pointer_t.FailableOwnDataWithInfo_f<Result, Info>) throws -> Result {
        return try handle.loadData(with: info, using: loader)
    }

    func loadData<Result: PublicInitializable, Info: VulkanInStructure>(with info: UnsafePointer<Info>, using loader: Handle.Pointer_t.FailableOwnDataWithInfo_f<Result, Info>) throws -> Result {
        return try handle.loadData(with: info, using: loader)
    }

    func loadData<Child, Result: VulkanOutStructure>(for childPointer: UnsafeMutablePointer<Child>, using loader: Handle.Pointer_t.FailableChildData_f<Child, Result>) throws -> Result {
        return try handle.loadData(for: childPointer, using: loader)
    }

    func loadData<Child, Result: PublicInitializable>(for childPointer: UnsafeMutablePointer<Child>, using loader: Handle.Pointer_t.FailableChildData_f<Child, Result>) throws -> Result {
        return try handle.loadData(for: childPointer, using: loader)
    }

    func loadDataArray<Result: PublicInitializable>(using loader: Handle.Pointer_t.OwnDataArray_f<Result>) throws -> [Result] {
        return try handle.loadDataArray(using: loader)
    }

    func loadDataArray<Result: PublicInitializable>(using loader: Handle.Pointer_t.FailableOwnDataArray_f<Result>) throws -> [Result] {
        return try handle.loadDataArray(using: loader)
    }

    func loadDataArray<Child, Result: PublicInitializable>(for childPointer: UnsafeMutablePointer<Child>, using loader: Handle.Pointer_t.ChildDataArray_f<Child, Result>) throws -> [Result] {
        return try handle.loadDataArray(for: childPointer, using: loader)
    }

    func loadDataArray<Child, Result: PublicInitializable>(for childPointer: UnsafeMutablePointer<Child>, using loader: Handle.Pointer_t.FailableChildDataArray_f<Child, Result>) throws -> [Result] {
        return try handle.loadDataArray(for: childPointer, using: loader)
    }
}
