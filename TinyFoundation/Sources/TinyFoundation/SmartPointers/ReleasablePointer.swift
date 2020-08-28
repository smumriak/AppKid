//
//  ReleasablePointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

public protocol ReleasableCType {
    static var releaseFunc: (_ pointer: SmartPointer<Self>.Pointer_t?) -> () { get }
}

public extension UnsafeMutablePointer where Pointee: ReleasableCType {
    func release() {
        defer { globalRetainCount.decrement() }
        
        Pointee.releaseFunc(self)
    }
}

public class ReleasablePointer<Pointee>: SmartPointer<Pointee> where Pointee: ReleasableCType {
    public init(with pointer: Pointer_t) {
        super.init(with: pointer, deleter: .custom { $0.release() })
    }
}
