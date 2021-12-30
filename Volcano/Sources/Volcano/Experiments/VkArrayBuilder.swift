//
//  VkArrayBuilder.swift
//  Volcano
//
//  Created by Serhii Mumriak on 28.12.2021.
//

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, SubStruct: VulkanStructure>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<SubStruct>?>), builder: VkArrayBuilder<SubStruct>) -> SubArr<Struct, SubStruct> {
    SubArr(paths.0, paths.1, builder)
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, SubStruct: VulkanStructure>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<SubStruct>?>), @VkArrayBuilder<SubStruct> content: () -> (VkArrayBuilder<SubStruct>)) -> SubArr<Struct, SubStruct> {
    SubArr(paths.0, paths.1, content())
}

@inlinable @inline(__always)
public func <- <Struct: VulkanStructure, Value>(paths: (WritableKeyPath<Struct, CUnsignedInt>, WritableKeyPath<Struct, UnsafePointer<Value>?>), value: [VkBuilder<Value>?]) -> SubArr<Struct, Value> {
    SubArr(paths.0, paths.1, VkArrayBuilder(value.compactMap { $0 }))
}

public class SubArr<Struct: VulkanStructure, SubStruct: VulkanStructure>: Path<Struct> {
    public typealias CountKeyPath = Swift.WritableKeyPath<Struct, CUnsignedInt>
    public typealias ValueKeyPath = Swift.WritableKeyPath<Struct, UnsafePointer<SubStruct>?>

    @usableFromInline
    internal let countKeyPath: CountKeyPath

    @usableFromInline
    internal let valueKeyPath: ValueKeyPath

    @usableFromInline
    internal let builder: VkArrayBuilder<SubStruct>

    public init(_ countKeyPath: CountKeyPath, _ valueKeyPath: ValueKeyPath, _ builder: VkArrayBuilder<SubStruct>) {
        self.countKeyPath = countKeyPath
        self.valueKeyPath = valueKeyPath
        self.builder = builder
    }

    @inlinable @inline(__always)
    public override func withApplied<R>(to result: inout Struct, tail: ArraySlice<Path<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
        return try builder.withUnsafeResultPointer {
            result[keyPath: countKeyPath] = CUnsignedInt($0.count)
            result[keyPath: valueKeyPath] = $0.baseAddress!

            return try super.withApplied(to: &result, tail: tail, body)
        }
    }
}

internal extension VkBuilder {
    @inlinable @inline(__always)
    func withApplied<R>(to result: inout [Struct], tail: ArraySlice<VkBuilder<Struct>>, _ body: (UnsafeBufferPointer<Struct>) throws -> (R)) rethrows -> R {
        return try withUnsafeResultPointer {
            result.append($0.pointee)

            let indices = tail.indices
            if indices.lowerBound == indices.upperBound {
                return try result.withUnsafeBufferPointer(body)
            } else {
                let nextHead = tail[indices.lowerBound]
                let nextTail = tail[indices.dropFirst()]

                return try nextHead.withApplied(to: &result, tail: nextTail, body)
            }
        }
    }
}

@resultBuilder
public struct VkArrayBuilder<Struct: VulkanStructure> {
    public typealias Expression = VkBuilder<Struct>
    public typealias Component = [VkBuilder<Struct>]

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

    static func buildBlock(_ elements: [Expression?]) -> Component {
        return elements.compactMap { $0 }
    }

    static func buildBlock(_ elements: Component...) -> Component {
        return elements.flatMap { $0 }
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

    static func buildArray(_ elements: [Component]) -> Component {
        return elements.flatMap { $0 }
    }

    static func buildFinalResult(_ elements: Component) -> Component {
        return elements
    }

    static func buildFinalResult(_ elements: Component) -> VkArrayBuilder<Struct> {
        return VkArrayBuilder(elements)
    }

    static func buildFinalResult(@VkArrayBuilder<Struct> _ content: () -> (Component)) -> VkArrayBuilder<Struct> {
        return VkArrayBuilder(content())
    }

    static func buildFinalResult(@VkArrayBuilder<Struct> _ content: () -> (VkArrayBuilder<Struct>)) -> VkArrayBuilder<Struct> {
        return content()
    }

    @usableFromInline
    internal var elements: Component

    @usableFromInline
    internal init(@VkArrayBuilder<Struct> _ content: () -> (Component)) {
        self.elements = content()
    }

    @usableFromInline
    internal init(_ elements: Component) {
        self.elements = elements
    }

    @inlinable @inline(__always)
    public func withUnsafeResultPointer<R>(_ body: (UnsafeBufferPointer<Struct>) throws -> (R)) rethrows -> R {
        var result: [Struct] = []
        result.reserveCapacity(elements.count)

        if elements.isEmpty {
            return try result.withUnsafeBufferPointer(body)
        }

        let indices = elements.indices

        let head = elements[indices.lowerBound]
        let tail = elements[indices.dropFirst()]

        return try head.withApplied(to: &result, tail: tail, body)
    }
}
