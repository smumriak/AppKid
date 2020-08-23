//
//  DataLoader.swift
//  Volcano
//
//  Created by Serhii Mumriak on 18.05.2020.
//

internal protocol DataLoader {}

extension UnsafeMutablePointer where Pointee: DataLoader {
    typealias OwnData_f<Result> = (Self?, UnsafeMutablePointer<Result>?) -> ()
    typealias FailableOwnData_f<Result> = (Self?, UnsafeMutablePointer<Result>?) -> (VkResult)
    typealias ChildData_f<Child, Result> = (Self?, UnsafeMutablePointer<Child>?, UnsafeMutablePointer<Result>?) -> ()
    typealias FailableChildData_f<Child, Result> = (Self?, UnsafeMutablePointer<Child>?, UnsafeMutablePointer<Result>?) -> (VkResult)

    typealias OwnDataArray_f<Result> = (Self?, UnsafeMutablePointer<CUnsignedInt>?, UnsafeMutablePointer<Result>?) -> ()
    typealias FailableOwnDataArray_f<Result> = (Self?, UnsafeMutablePointer<CUnsignedInt>?, UnsafeMutablePointer<Result>?) -> (VkResult)
    typealias ChildDataArray_f<Child, Result> = (Self?, UnsafeMutablePointer<Child>?, UnsafeMutablePointer<CUnsignedInt>?, UnsafeMutablePointer<Result>?) -> ()
    typealias FailableChildDataArray_f<Child, Result> = (Self?, UnsafeMutablePointer<Child>?, UnsafeMutablePointer<CUnsignedInt>?, UnsafeMutablePointer<Result>?) -> (VkResult)

    func loadData<Result>(using loader: OwnData_f<Result>) throws -> Result {
        let result = SmartPointer<Result>.allocate()

        try vulkanInvoke {
            loader(self, result.pointer)
        }
        return result.pointee
    }

    func loadData<Result>(using loader: FailableOwnData_f<Result>) throws -> Result {
        let result = SmartPointer<Result>.allocate()

        try vulkanInvoke {
            loader(self, result.pointer)
        }
        return result.pointee
    }

    func loadData<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: ChildData_f<Child, Result>) throws -> Result {
        let result = SmartPointer<Result>.allocate()

        try vulkanInvoke {
            loader(self, childPointer, result.pointer)
        }
        return result.pointee
    }

    func loadData<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: FailableChildData_f<Child, Result>) throws -> Result {
        let result = SmartPointer<Result>.allocate()

        try vulkanInvoke {
            loader(self, childPointer, result.pointer)
        }
        return result.pointee
    }

    func loadDataArray<Result>(using loader: OwnDataArray_f<Result>) throws -> [Result] {
        var resultsCount: CUnsignedInt = 0;
        try vulkanInvoke {
            loader(self, &resultsCount, nil)
        }

        let resultsBuffer = SmartPointer<Result>.allocate(capacity: Int(resultsCount))

        try vulkanInvoke {
            loader(self, &resultsCount, resultsBuffer.pointer)
        }

        return UnsafeBufferPointer(start: resultsBuffer.pointer, count: Int(resultsCount)).map { $0 }
    }

    func loadDataArray<Result>(using loader: FailableOwnDataArray_f<Result>) throws -> [Result] {
        var resultsCount: CUnsignedInt = 0;
        try vulkanInvoke {
            loader(self, &resultsCount, nil)
        }

        let resultsBuffer = SmartPointer<Result>.allocate(capacity: Int(resultsCount))

        try vulkanInvoke {
            loader(self, &resultsCount, resultsBuffer.pointer)
        }

        return UnsafeBufferPointer(start: resultsBuffer.pointer, count: Int(resultsCount)).map { $0 }
    }

    func loadDataArray<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: ChildDataArray_f<Child, Result>) throws -> [Result] {
        var resultsCount: CUnsignedInt = 0;
        try vulkanInvoke {
            loader(self, childPointer, &resultsCount, nil)
        }

        let resultsBuffer = SmartPointer<Result>.allocate(capacity: Int(resultsCount))

        try vulkanInvoke {
            loader(self, childPointer, &resultsCount, resultsBuffer.pointer)
        }

        return UnsafeBufferPointer(start: resultsBuffer.pointer, count: Int(resultsCount)).map { $0 }
    }

    func loadDataArray<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: FailableChildDataArray_f<Child, Result>) throws -> [Result] {
        var resultsCount: CUnsignedInt = 0;
        try vulkanInvoke {
            loader(self, childPointer, &resultsCount, nil)
        }

        let resultsBuffer = SmartPointer<Result>.allocate(capacity: Int(resultsCount))

        try vulkanInvoke {
            loader(self, childPointer, &resultsCount, resultsBuffer.pointer)
        }

        return UnsafeBufferPointer(start: resultsBuffer.pointer, count: Int(resultsCount)).map { $0 }
    }
}

internal extension SmartPointerProtocol where Pointee: DataLoader {
    func loadData<Result>(using loader: Pointer_t.OwnData_f<Result>) throws -> Result {
        return try pointer.loadData(using: loader)
    }

    func loadData<Result>(using loader: Pointer_t.FailableOwnData_f<Result>) throws -> Result {
        return try pointer.loadData(using: loader)
    }

    func loadData<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: Pointer_t.ChildData_f<Child, Result>) throws -> Result {
        return try pointer.loadData(for: childPointer, using: loader)
    }

    func loadData<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: Pointer_t.FailableChildData_f<Child, Result>) throws -> Result {
        return try pointer.loadData(for: childPointer, using: loader)
    }

    func loadDataArray<Result>(using loader: Pointer_t.OwnDataArray_f<Result>) throws -> [Result] {
        return try pointer.loadDataArray(using: loader)
    }

    func loadDataArray<Result>(using loader: Pointer_t.FailableOwnDataArray_f<Result>) throws -> [Result] {
        return try pointer.loadDataArray(using: loader)
    }

    func loadDataArray<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: Pointer_t.ChildDataArray_f<Child, Result>) throws -> [Result] {
        return try pointer.loadDataArray(for: childPointer, using: loader)
    }

    func loadDataArray<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: Pointer_t.FailableChildDataArray_f<Child, Result>) throws -> [Result] {
        return try pointer.loadDataArray(for: childPointer, using: loader)
    }
}

internal extension VulkanHandle where Handle.Pointee: DataLoader {
    func loadData<Result>(using loader: Handle.Pointer_t.OwnData_f<Result>) throws -> Result {
        return try handle.loadData(using: loader)
    }

    func loadData<Result>(using loader: Handle.Pointer_t.FailableOwnData_f<Result>) throws -> Result {
        return try handle.loadData(using: loader)
    }

    func loadData<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: Handle.Pointer_t.ChildData_f<Child, Result>) throws -> Result {
        return try handle.loadData(for: childPointer, using: loader)
    }

    func loadData<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: Handle.Pointer_t.FailableChildData_f<Child, Result>) throws -> Result {
        return try handle.loadData(for: childPointer, using: loader)
    }

    func loadDataArray<Result>(using loader: Handle.Pointer_t.OwnDataArray_f<Result>) throws -> [Result] {
        return try handle.loadDataArray(using: loader)
    }

    func loadDataArray<Result>(using loader: Handle.Pointer_t.FailableOwnDataArray_f<Result>) throws -> [Result] {
        return try handle.loadDataArray(using: loader)
    }

    func loadDataArray<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: Handle.Pointer_t.ChildDataArray_f<Child, Result>) throws -> [Result] {
        return try handle.loadDataArray(for: childPointer, using: loader)
    }

    func loadDataArray<Child, Result>(for childPointer: UnsafeMutablePointer<Child>, using loader: Handle.Pointer_t.FailableChildDataArray_f<Child, Result>) throws -> [Result] {
        return try handle.loadDataArray(for: childPointer, using: loader)
    }
}
