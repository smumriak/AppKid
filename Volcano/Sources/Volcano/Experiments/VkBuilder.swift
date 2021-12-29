//
//  VkBuilder.swift
//  Volcano
//
//  Created by Serhii Mumriak on 21.12.2021.
//

import TinyFoundation
import CVulkan

infix operator <-
prefix operator <-

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(path: WritableKeyPath<Struct, Value>, value: Value) -> Val<Struct, Value> {
    Val(path, value)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value: BinaryInteger>(path: WritableKeyPath<Struct, CInt>, value: Value) -> Val<Struct, CInt> {
    Val(path, CInt(value))
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value: BinaryInteger>(path: WritableKeyPath<Struct, CUnsignedInt>, value: Value) -> Val<Struct, CUnsignedInt> {
    Val(path, CUnsignedInt(value))
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value: BinaryInteger>(path: WritableKeyPath<Struct, Int64>, value: Value) -> Val<Struct, Int64> {
    Val(path, Int64(value))
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value: BinaryInteger>(path: WritableKeyPath<Struct, UInt64>, value: Value) -> Val<Struct, UInt64> {
    Val(path, UInt64(value))
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value: BinaryFloatingPoint>(path: WritableKeyPath<Struct, Float>, value: Value) -> Val<Struct, Float> {
    Val(path, Float(value))
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value: BinaryFloatingPoint>(path: WritableKeyPath<Struct, Double>, value: Value) -> Val<Struct, Double> {
    Val(path, Double(value))
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<Value>?>), value: Array<Value>) -> Arr<Struct, Value> {
    Arr(paths.0, paths.1, value)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: Array<Value>) -> NoCountArr<Struct, Value> {
    NoCountArr(path, value)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value, Count: BinaryInteger>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<Value>?>), count: Count) -> NilArr<Struct, Value, Count> {
    NilArr(paths.0, paths.1, count)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value: RawRepresentable>(path: WritableKeyPath<Struct, Value.RawValue>, value: Value) -> Flags<Struct, Value> where Value.RawValue == VkFlags {
    Flags(path, value)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value: RawRepresentable>(path: WritableKeyPath<Struct, Value.RawValue>, value: Value) -> Flags64<Struct, Value> where Value.RawValue == VkFlags64 {
    Flags64(path, value)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, SubStruct: VulkanStructure>(path: WritableKeyPath<Struct, UnsafePointer<SubStruct>?>, builder: VkBuilder<SubStruct>) -> Sub<Struct, SubStruct> {
    Sub(path, builder)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, SubStruct: VulkanStructure>(path: WritableKeyPath<Struct, UnsafePointer<SubStruct>?>, @VkBuilder<SubStruct> _ content: () -> (VkBuilder<SubStruct>)) -> Sub<Struct, SubStruct> {
    Sub(path, content())
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: UnsafePointer<Value>) -> Ptr<Struct, Value> {
    Ptr(path, value)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: UnsafeMutablePointer<Value>) -> Ptr<Struct, Value> {
    Ptr(path, value)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(path: WritableKeyPath<Struct, UnsafeMutablePointer<Value>?>, value: UnsafeMutablePointer<Value>) -> MPtr<Struct, Value> {
    MPtr(path, value)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: SmartPointer<Value>) -> SmartPtr<Struct, Value> {
    SmartPtr(path, value)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: HandleStorage<SmartPointer<Value>>) -> SmartPtr<Struct, Value> {
    SmartPtr(path, value.handlePointer)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(path: WritableKeyPath<Struct, UnsafeMutablePointer<Value>?>, value: SmartPointer<Value>) -> SmartMPtr<Struct, Value> {
    SmartMPtr(path, value)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(path: WritableKeyPath<Struct, UnsafeMutablePointer<Value>?>, value: HandleStorage<SmartPointer<Value>>) -> SmartMPtr<Struct, Value> {
    SmartMPtr(path, value.handlePointer)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<UnsafePointer<CChar>?>?>), value: [String]) -> SmartPtrArray<Struct, CChar> {
    SmartPtrArray(paths.0, paths.1, value.cStrings)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<UnsafePointer<CChar>?>?>), value: [SmartPointer<CChar>]) -> SmartPtrArray<Struct, CChar> {
    SmartPtrArray(paths.0, paths.1, value)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<UnsafePointer<Value>?>?>), value: [SmartPointer<Value>]) -> SmartPtrArray<Struct, Value> {
    SmartPtrArray(paths.0, paths.1, value)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<UnsafeMutablePointer<Value>?>?>), value: [SmartPointer<Value>]) -> SmartMPtrArray<Struct, Value> {
    SmartMPtrArray(paths.0, paths.1, value)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<UnsafeMutablePointer<Value>?>?>), value: [HandleStorage<SmartPointer<Value>>]) -> SmartMPtrArray<Struct, Value> {
    SmartMPtrArray(paths.0, paths.1, value.smartPointers())
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(path: WritableKeyPath<Struct, UnsafePointer<Value>?>, value: Value) -> PtrTo<Struct, Value> {
    PtrTo(path, value)
}

@inlinable @inline(__always)
public prefix func <- <Struct: VulkanChainableStructure, NextStruct: VulkanChainableStructure>(builder: VkBuilder<NextStruct>) -> Next<Struct, NextStruct> {
    Next(builder)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value: StringProtocol>(path: WritableKeyPath<Struct, UnsafePointer<CChar>?>, value: Value) -> Str<Struct> {
    Str(path, String(value))
}

public class Path<Struct: VulkanStructure> {
    @inlinable @inline(__always)
    public func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        let indices = tail.indices
        if indices.lowerBound == indices.upperBound {
            return try withUnsafePointer(to: &result) {
                return try body($0)
            }
        } else {
            let nextHead = tail[indices.lowerBound]
            let nextTail = tail[indices.dropFirst()]

            return try nextHead.withApplied(to: &result, tail: nextTail, body)
        }
    }
}

public class Val<Struct: VulkanStructure, Value>: Path<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, Value>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: Value

    public init(_ valueKeyPath: ValueKeyPath, _ value: Value) {
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = value
        return try super.withApplied(to: &result, tail: tail, body)
    }
}

public class Arr<Struct: VulkanStructure, Value>: Path<Struct> {
    public typealias CountKeyPath = Swift.WritableKeyPath<Struct, CUnsignedInt>
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let countKeyPath: CountKeyPath

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: Array<Value>
        
    public init(_ countKeyPath: CountKeyPath, _ valueKeyPath: ValueKeyPath, _ value: Array<Value>) {
        self.countKeyPath = countKeyPath
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        return try value.withUnsafeBufferPointer { value in
            result[keyPath: countKeyPath] = CUnsignedInt(value.count)
            result[keyPath: valueKeyPath] = value.baseAddress!
            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}

public class NoCountArr<Struct: VulkanStructure, Value>: Path<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: Array<Value>
        
    public init(_ valueKeyPath: ValueKeyPath, _ value: Array<Value>) {
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        return try value.withUnsafeBufferPointer { value in
            result[keyPath: valueKeyPath] = value.baseAddress!
            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}

public class NilArr<Struct: VulkanStructure, Value, Count: BinaryInteger>: Path<Struct> {
    public typealias CountKeyPath = Swift.WritableKeyPath<Struct, CUnsignedInt>
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let countKeyPath: CountKeyPath

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let count: Count

    public init(_ countKeyPath: CountKeyPath, _ valueKeyPath: ValueKeyPath, _ count: Count = 0) {
        self.countKeyPath = countKeyPath
        self.valueKeyPath = valueKeyPath
        self.count = count
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        result[keyPath: countKeyPath] = CUnsignedInt(count)
        result[keyPath: valueKeyPath] = nil
        return try super.withApplied(to: &result, tail: tail, body)
    }
}

public class Flags<Struct: VulkanStructure, Value: RawRepresentable>: Path<Struct> where Value.RawValue == VkFlags {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, Value.RawValue>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: Value

    public init(_ valueKeyPath: ValueKeyPath, _ value: Value) {
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = value.rawValue
        return try super.withApplied(to: &result, tail: tail, body)
    }
}

public class Flags64<Struct: VulkanStructure, Value: RawRepresentable>: Path<Struct> where Value.RawValue == VkFlags64 {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, Value.RawValue>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: Value

    public init(_ valueKeyPath: ValueKeyPath, _ value: Value) {
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = value.rawValue
        return try super.withApplied(to: &result, tail: tail, body)
    }
}

public class Sub<Struct: VulkanStructure, SubStruct: VulkanStructure>: Path<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<SubStruct>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let builder: VkBuilder<SubStruct>

    public init(_ valueKeyPath: ValueKeyPath, _ builder: VkBuilder<SubStruct>) {
        self.valueKeyPath = valueKeyPath
        self.builder = builder
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        return try builder.withUnsafeResultPointer {
            result[keyPath: valueKeyPath] = $0
            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}

public class Ptr<Struct: VulkanStructure, Value>: Path<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let pointer: UnsafePointer<Value>?

    public init(_ valueKeyPath: ValueKeyPath, _ pointer: UnsafePointer<Value>?) {
        self.valueKeyPath = valueKeyPath
        self.pointer = pointer
    }

    public init(_ valueKeyPath: ValueKeyPath, _ pointer: UnsafeMutablePointer<Value>?) {
        self.valueKeyPath = valueKeyPath
        self.pointer = pointer.map { UnsafePointer($0) }
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = pointer
        return try super.withApplied(to: &result, tail: tail, body)
    }
}

public class MPtr<Struct: VulkanStructure, Value>: Path<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafeMutablePointer<Value>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let pointer: UnsafeMutablePointer<Value>?

    public init(_ valueKeyPath: ValueKeyPath, _ pointer: UnsafeMutablePointer<Value>?) {
        self.valueKeyPath = valueKeyPath
        self.pointer = pointer
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = pointer
        return try super.withApplied(to: &result, tail: tail, body)
    }
}

public class SmartPtr<Struct: VulkanStructure, Value>: Path<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let pointer: SmartPointer<Value>?

    public init(_ valueKeyPath: ValueKeyPath, _ pointer: SmartPointer<Value>?) {
        self.valueKeyPath = valueKeyPath
        self.pointer = pointer
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = pointer.map { UnsafePointer($0.pointer) }
        return try super.withApplied(to: &result, tail: tail, body)
    }
}

public class SmartMPtr<Struct: VulkanStructure, Value>: Path<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafeMutablePointer<Value>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let pointer: SmartPointer<Value>?

    public init(_ valueKeyPath: ValueKeyPath, _ pointer: SmartPointer<Value>?) {
        self.valueKeyPath = valueKeyPath
        self.pointer = pointer
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        result[keyPath: valueKeyPath] = pointer?.pointer
        return try super.withApplied(to: &result, tail: tail, body)
    }
}

public class SmartPtrArray<Struct: VulkanStructure, Value>: Path<Struct> {
    public typealias CountKeyPath = Swift.WritableKeyPath<Struct, CUnsignedInt>
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<UnsafePointer<Value>?>?>

    @usableFromInline
    internal let countKeyPath: CountKeyPath

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: Array<SmartPointer<Value>>
        
    public init(_ countKeyPath: CountKeyPath, _ valueKeyPath: ValueKeyPath, _ value: Array<SmartPointer<Value>>) {
        self.countKeyPath = countKeyPath
        self.valueKeyPath = valueKeyPath
        self.value = value
    }
    
    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        return try value.optionalPointers().withUnsafeBufferPointer { value in
            result[keyPath: countKeyPath] = CUnsignedInt(value.count)
            result[keyPath: valueKeyPath] = value.baseAddress!
            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}

public class SmartMPtrArray<Struct: VulkanStructure, Value>: Path<Struct> {
    public typealias CountKeyPath = Swift.WritableKeyPath<Struct, CUnsignedInt>
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<UnsafeMutablePointer<Value>?>?>

    @usableFromInline
    internal let countKeyPath: CountKeyPath

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: Array<SmartPointer<Value>>
        
    public init(_ countKeyPath: CountKeyPath, _ valueKeyPath: ValueKeyPath, _ value: Array<SmartPointer<Value>>) {
        self.countKeyPath = countKeyPath
        self.valueKeyPath = valueKeyPath
        self.value = value
    }
    
    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        return try value.optionalMutablePointers().withUnsafeBufferPointer { value in
            result[keyPath: countKeyPath] = CUnsignedInt(value.count)
            result[keyPath: valueKeyPath] = value.baseAddress!
            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}

public class PtrTo<Struct: VulkanStructure, Value>: Path<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<Value>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: Value

    public init(_ valueKeyPath: ValueKeyPath, _ value: Value) {
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        return try withUnsafePointer(to: value) {
            result[keyPath: valueKeyPath] = $0
            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}

public class Next<Struct: VulkanChainableStructure, Next: VulkanChainableStructure>: Path<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafeRawPointer?>

    @usableFromInline
    internal let builder: VkBuilder<Next>

    public init(_ builder: VkBuilder<Next>) {
        self.builder = builder
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        assert(result[keyPath: \.pNext] == nil)
        return try builder.withUnsafeResultPointer {
            result[keyPath: \.pNext] = UnsafeRawPointer($0)
            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}

public class Str<Struct: VulkanStructure>: Path<Struct> {
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<CChar>?>

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let value: String

    public init(_ valueKeyPath: ValueKeyPath, _ value: String) {
        self.valueKeyPath = valueKeyPath
        self.value = value
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        return try value.withCString {
            result[keyPath: valueKeyPath] = $0
            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}

@resultBuilder
public struct VkBuilder<Struct: VulkanStructure> {
    public typealias Expression = Path<Struct>
    public typealias Component = [Path<Struct>]

    static func buildExpression(_ expression: Expression) -> Component {
        return [expression]
    }

    static func buildExpression(_ expression: Expression?) -> Component {
        if let expression = expression {
            return [expression]
        } else {
            return []
        }
    }

    static func buildBlock(_ paths: Component...) -> Component {
        return paths.flatMap { $0 }
    }

    static func buildBlock(_ paths: [Expression?]) -> Component {
        return paths.compactMap { $0 }
    }

    static func buildOptional(_ component: Component?) -> Component {
        return component ?? []
    }

    static func buildEither(first component: Component) -> Component {
        return component
    }

    static func buildEither(second component: Component) -> Component {
        return component
    }

    static func buildArray(_ paths: [Component]) -> Component {
        return paths.flatMap { $0 }
    }

    static func buildFinalResult(_ paths: Component) -> Component {
        return paths
    }

    static func buildFinalResult(_ paths: Component) -> VkBuilder<Struct> {
        return VkBuilder(paths)
    }

    static func buildFinalResult(@VkBuilder<Struct> _ content: () -> (Component)) -> Component {
        return content()
    }

    static func buildFinalResult(@VkBuilder<Struct> _ content: () -> (VkBuilder<Struct>)) -> VkBuilder<Struct> {
        return content()
    }

    @usableFromInline
    internal var paths: Component

    public init(@VkBuilder<Struct> _ content: () -> (Component)) {
        self.init(content())
    }

    @usableFromInline
    internal init(_ paths: Component) {
        self.paths = paths
    }

    @inlinable @inline(__always)
    public func withUnsafeResultPointer<R>(_ body: (UnsafePointer<Struct>) throws -> (R)) rethrows -> R {
        var result = Struct.new()

        if paths.isEmpty {
            return try withUnsafePointer(to: &result, body)
        }

        let indices = paths.indices

        let head = paths[indices.lowerBound]
        let tail = paths[indices.dropFirst()]

        return try head.withApplied(to: &result, tail: tail, body)
    }
}

public extension VkBuilder where Struct: EntityInfo {
    @inlinable @inline(__always)
    func createEntity<Parent>(using parent: HandleStorage<SmartPointer<Parent>>) throws -> SmartPointer<Struct.Result> where Struct.Parent == Parent {
        try withUnsafeResultPointer {
            try parent.create(with: $0)
        }
    }
}
