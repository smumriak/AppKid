//
//  DestructablePointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

public protocol DestructableCType {
    var destroyFunc: (_ pointer: UnsafeMutablePointer<Self>?) -> () { get }
}

public extension UnsafeMutablePointer where Pointee: DestructableCType {
    func destroy() {
        pointee.destroyFunc(self)
    }
}

public class DestructablePointer<Pointee>: SmartPointer where Pointee: DestructableCType {
    public typealias Pointer_t = UnsafeMutablePointer<Pointee>
    public var pointer: Pointer_t

    deinit {
        pointer.destroy()
    }

    required public init(with pointer: Pointer_t) {
        self.pointer = pointer
    }
}
