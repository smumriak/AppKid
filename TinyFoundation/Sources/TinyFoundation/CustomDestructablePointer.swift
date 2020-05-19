//
//  CustomDestructablePointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 19.05.2020.
//

import Foundation

public class CustomDestructablePointer<Pointee>: SmartPointer {
    public typealias Pointee = Pointee
    public typealias Destructor = (Pointer_t) -> ()

    public var pointer: Pointer_t {
        willSet {
            destructor(pointer)
        }
    }

    fileprivate let destructor: Destructor

    deinit {
        destructor(pointer)
    }

    public init(with pointer: Pointer_t, destructor: @escaping Destructor) {
        self.pointer = pointer
        self.destructor = destructor
    }
}
