//
//  DestructableCType.swift
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

public class DestructablePointer<Pointee> where Pointee: DestructableCType {
    public typealias DestructablePointer_t = UnsafeMutablePointer<Pointee>
    public var pointer: DestructablePointer_t

    deinit {
        pointer.destroy()
    }

    public init(with pointer: DestructablePointer_t) {
        self.pointer = pointer
    }
}
