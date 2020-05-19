//
//  SimplePointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

public final class SimplePointer<Pointee>: SmartPointer {
    public typealias Pointee = Pointee
    
    public var pointer: Pointer_t

    public init(with pointer: Pointer_t) {
        self.pointer = pointer
    }
}
