//
//  SharedPointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import Atomics

#if DEBUG
    internal var globalRetainCount = ManagedAtomic<Int64>(0)
#endif

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
            #if DEBUG
                defer { globalRetainCount.wrappingDecrement(by: 1, ordering: .relaxed) }
            #endif

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

    public enum Deinitializer {
        case none
        case system(count: Int = 1)
        case custom((Pointer) -> ())

        func callAsFunction(_ pointer: Pointer) {
            switch self {
                case .none:
                    break
                case .system(let count):
                    pointer.deinitialize(count: count)
                case .custom(let deleter):
                    deleter(pointer)
            }
        }
    }

    public let pointer: Pointer
    internal let deleter: Deleter
    internal let deinitializer: Deinitializer

    deinit {
        deinitializer(pointer)
        deleter(pointer)
    }

    public class func allocate(capacity: Int = 1, deleter: Deleter = .system, deinitializer: Deinitializer? = nil) -> SharedPointer<Pointee> {
        let deinitializer = deinitializer ?? .system(count: capacity)
        return SharedPointer<Pointee>(with: Pointer.allocate(capacity: capacity), deleter: deleter, deinitializer: deinitializer)
    }

    public init(with pointer: Pointer, deleter: Deleter, deinitializer: Deinitializer = .none) {
        #if DEBUG
            defer { globalRetainCount.wrappingIncrement(by: 1, ordering: .relaxed) }
        #endif
        
        self.pointer = pointer
        self.deleter = deleter
        self.deinitializer = deinitializer
    }

    public convenience init(with pointer: Pointer, deleter: @escaping (Pointer) -> (), deinitializer: Deinitializer = .none) {
        self.init(with: pointer, deleter: .custom(deleter), deinitializer: deinitializer)
    }

    public convenience init(nonOwning pointer: Pointer, deinitializer: Deinitializer = .none) {
        self.init(with: pointer, deleter: .none, deinitializer: deinitializer)
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
