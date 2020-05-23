//
//  SmartPointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

public protocol SmartPointerProtocol {
    associatedtype Pointee
    typealias Pointer_t = UnsafeMutablePointer<Pointee>
    
    var pointer: Pointer_t { get set }
}

public extension SmartPointerProtocol {
    var pointee: Pointee {
        get { return pointer.pointee }
        set { pointer.pointee = newValue }
    }
}

public class SmartPointer<Pointee>: SmartPointerProtocol {
    public typealias Pointer_t = UnsafeMutablePointer<Pointee>
    public typealias Deleter_f = (Pointer_t) -> ()

    public enum Deleter {
        case none
        case system
        case custom(Deleter_f)

        func invoke(with pointer: Pointer_t) {
            switch self {
            case .none:
                break
            case .system:
                pointer.deallocate()
            case .custom(let deleter):
                deleter(pointer)
            }
        }
    }

    public var pointer: Pointer_t
    internal let deleter: Deleter

    deinit {
        deleter.invoke(with: pointer)
    }

    public init(capacity: Int = 1) {
        self.pointer = Pointer_t.allocate(capacity: capacity)
        self.deleter = .system
    }

    public init(with pointer: Pointer_t, deleter: Deleter = .none) {
        self.pointer = pointer
        self.deleter = deleter
    }

    public convenience init(with pointer: Pointer_t, deleterFunction: @escaping Deleter_f) {
        self.init(with: pointer, deleter: .custom(deleterFunction))
    }
}
