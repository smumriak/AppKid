//
//  SharedPointer.swift
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

@dynamicMemberLookup
public protocol SmartPointer<Pointee>: Hashable {
    associatedtype Pointee
    typealias Pointer = UnsafeMutablePointer<Pointee>

    var pointer: Pointer { get }
}

public extension SmartPointer {
    @_transparent
    var pointee: Pointee {
        get { pointer.pointee }
        set { pointer.pointee = newValue }
    }

    @_transparent
    var optionalPointer: Pointer? { pointer }

    subscript<T>(dynamicMember keyPath: WritableKeyPath<Pointee, T>) -> T {
        get {
            pointee[keyPath: keyPath]
        }
        set {
            pointee[keyPath: keyPath] = newValue
        }
    }
}

public extension SmartPointer {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.pointer == rhs.pointer
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(pointer)
    }
}

public final class SharedPointer<Pointee>: SmartPointer {
    public typealias Pointee = Pointee

    public enum Deleter {
        case none
        case system
        case custom((Pointer) -> ())
        
        func callAsFunction(_ pointer: Pointer) {
            defer { globalRetainCount.decrement() }

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

    public let pointer: Pointer
    internal let deleter: Deleter

    deinit {
        deleter(pointer)
    }

    public class func allocate(capacity: Int = 1) -> SharedPointer<Pointee> {
        return SharedPointer<Pointee>(with: Pointer.allocate(capacity: capacity), deleter: .system)
    }

    public init(with pointer: Pointer, deleter: Deleter) {
        defer { globalRetainCount.increment() }
        
        self.pointer = pointer
        self.deleter = deleter
    }

    public convenience init(with pointer: Pointer, deleter: @escaping (Pointer) -> ()) {
        self.init(with: pointer, deleter: .custom(deleter))
    }

    public convenience init(nonOwning pointer: Pointer) {
        self.init(with: pointer, deleter: .none)
    }

    public func assumingMemoryBound<T>(to type: T.Type) -> UnsafeMutablePointer<T> {
        return UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: type)
    }
}

public extension Array where Element: SmartPointer {
    @_transparent
    func mutablePointers() -> [Element.Pointer] {
        return map { $0.pointer }
    }

    @_transparent
    func optionalMutablePointers() -> [Element.Pointer?] {
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
