//
//  CairoPointerStorage.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 13/2/20.
//

import Foundation
import CCairo

public final class CairoPointer<Pointee> where Pointee: CairoReferableType {
    public typealias CairoPointer_t = UnsafeMutablePointer<Pointee>
    public var pointer: CairoPointer_t {
        willSet {
            pointer.release()
        }
        didSet {
            pointer.retain()
        }
    }
    
    deinit {
        pointer.release()
    }

    public init(with pointer: CairoPointer_t) {
        self.pointer = pointer.retain()
    }
    
    public init(other: CairoPointer<Pointee>) {
        self.pointer = other.pointer.retain()
    }
}
