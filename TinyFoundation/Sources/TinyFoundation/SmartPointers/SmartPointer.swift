//
//  SmartPointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

internal struct RetainCount {
    private let lock = NSRecursiveLock()
    private var value: Int64 = 0

    mutating func increment() {
        lock.lock()
        defer { lock.unlock() }

        value += 1
    }

    mutating func decrement() {
        lock.lock()
        defer { lock.unlock() }

        value -= 1
    }

    var currentValue: Int64 {
        lock.lock()
        defer { lock.unlock() }

        return value
    }
}

internal var globalRetainCount = RetainCount()

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
        defer { globalRetainCount.decrement() }
        
        deleter.invoke(with: pointer)
    }

    public static func allocate(capacity: Int = 1) -> SmartPointer<Pointee> {
        return SmartPointer<Pointee>(with: Pointer_t.allocate(capacity: capacity), deleter: .system)
    }

    public init(with pointer: Pointer_t, deleter: Deleter = .none) {
        defer { globalRetainCount.increment() }
        
        self.pointer = pointer
        self.deleter = deleter
    }

    public convenience init(with pointer: Pointer_t, deleterFunction: @escaping Deleter_f) {
        self.init(with: pointer, deleter: .custom(deleterFunction))
    }

    public func assumingMemoryBound<T>(to type: T.Type) -> UnsafeMutablePointer<T> {
        return UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: type)
    }
}
