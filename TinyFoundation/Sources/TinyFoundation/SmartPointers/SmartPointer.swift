//
//  SmartPointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

internal struct RetainCount {
    @Synchronized private var value: Int64 = 0

    mutating func increment() {
        value += 1
    }

    mutating func decrement() {
        value -= 1
    }

    var currentValue: Int64 {
        value
    }
}

internal var globalRetainCount = RetainCount()

public protocol SmartPointer1: Hashable {
    associatedtype Pointee
    typealias Pointer = UnsafeMutablePointer<Pointee>

    var pointer: Pointer { get }
}

public protocol SmartPointerProtocol: Hashable {
    associatedtype Pointee
    typealias Pointer_t = UnsafeMutablePointer<Pointee>
    
    var pointer: Pointer_t { get }
}

public extension SmartPointerProtocol {
    @_transparent
    var pointee: Pointee {
        get { pointer.pointee }
        set { pointer.pointee = newValue }
    }

    @_transparent
    var optionalPointer: Pointer_t? { pointer }
}

public extension SmartPointerProtocol {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.pointer == rhs.pointer
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(pointer)
    }
}

public class SmartPointer<Pointee>: SmartPointerProtocol {
    public typealias Pointee = Pointee

    public enum Deleter {
        case none
        case system
        case custom((Pointer_t) -> ())
        
        func callAsFunction(_ pointer: Pointer_t) {
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

    public let pointer: Pointer_t
    internal let deleter: Deleter

    deinit {
        defer { globalRetainCount.decrement() }
        
        deleter(pointer)
    }

    public class func allocate(capacity: Int = 1) -> SmartPointer<Pointee> {
        return SmartPointer<Pointee>(with: Pointer_t.allocate(capacity: capacity), deleter: .system)
    }

    public init(with pointer: Pointer_t, deleter: Deleter = .none) {
        defer { globalRetainCount.increment() }
        
        self.pointer = pointer
        self.deleter = deleter
    }

    public convenience init(with pointer: Pointer_t, deleter: @escaping (Pointer_t) -> ()) {
        self.init(with: pointer, deleter: .custom(deleter))
    }

    public func assumingMemoryBound<T>(to type: T.Type) -> UnsafeMutablePointer<T> {
        return UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: type)
    }
}

public extension Array where Element: SmartPointerProtocol {
    @_transparent
    func mutablePointers() -> [Element.Pointer_t] {
        return map { $0.pointer }
    }

    @_transparent
    func optionalMutablePointers() -> [Element.Pointer_t?] {
        return map { $0.pointer }
    }

    @_transparent
    func pointers() -> [UnsafePointer<Element.Pointee>] {
        return map { UnsafePointer($0.pointer) }
    }

    @_transparent
    func optionalPointers() -> [UnsafePointer<Element.Pointee>?] {
        return map { UnsafePointer($0.pointer) }
    }
}
