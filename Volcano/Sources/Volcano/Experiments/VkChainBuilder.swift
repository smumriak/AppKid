// //
// //  VkChainBuilder.swift
// //  Volcano
// //
// //  Created by Serhii Mumriak on 29.12.2021.
// //

// import TinyFoundation
// import CVulkan

// @inlinable @inline(__always)
// public prefix func <- <Struct: VulkanStructure>(builder: VkChainBuilder) -> Chain<Struct> {
//     Chain(builder)
// }

// @inlinable @inline(__always)
// public prefix func <- <Struct: VulkanStructure>(chain: Chain<Struct>) -> Chain<Struct> {
//     chain
// }

// @inlinable @inline(__always)
// public prefix func <- <Struct: VulkanStructure>(@VkChainBuilder content: () -> (VkChainBuilder)) -> Chain<Struct> {
//     Chain(content)
// }

// public class Chain<Struct: VulkanChainableStructure>: LVPath {
//     @usableFromInline
//     internal let builder: VkChainBuilder

//     public init(_ builder: VkChainBuilder) {
//         self.builder = builder
//     }

//     public init(@VkChainBuilder _ content: () -> (VkChainBuilder)) {
//         self.builder = content()
//     }

//     @inlinable @inline(__always)
//     public func withApplied<R>(to result: inout Struct, tail: ArraySlice<any LVPath<Struct>>, _ body: (UnsafeMutablePointer<Struct>) throws -> (R)) rethrows -> R {
//         assert(result[keyPath: \.pNext] == nil)
//         return try builder.withUnsafeChainPointer {
//             result[keyPath: \.pNext] = $0
//             return try body(&result)
//         }
//     }
// }

// @resultBuilder
// public class VkChainBuilder {
//     public typealias Expression = AnyNext
//     public typealias Component = [AnyNext]

//     static func buildExpression<Struct: VulkanChainableStructure>(_ expression: LavaContainer<Struct>) -> Component {
//         return [AnyNext(expression)]
//     }

//     static func buildExpression(_ expression: Expression) -> Component {
//         return [expression]
//     }

//     static func buildExpression(_ expression: Expression?) -> Component {
//         if let expression = expression {
//             return [expression]
//         } else {
//             return []
//         }
//     }

//     static func buildBlock(_ elements: [Expression?]) -> Component {
//         return elements.compactMap { $0 }
//     }

//     static func buildBlock(_ elements: Component...) -> Component {
//         return elements.flatMap { $0 }
//     }

//     static func buildOptional(_ component: Component?) -> Component {
//         return component ?? []
//     }

//     static func buildEither(first component: Component) -> Component {
//         return component
//     }

//     static func buildEither(second component: Component) -> Component {
//         return component
//     }

//     static func buildArray(_ elements: [Component]) -> Component {
//         return elements.flatMap { $0 }
//     }

//     static func buildFinalResult(_ elements: Component) -> Component {
//         return elements
//     }

//     static func buildFinalResult(_ elements: Component) -> VkChainBuilder {
//         return VkChainBuilder(elements)
//     }

//     @usableFromInline
//     internal var elements: Component

//     @usableFromInline
//     internal init(@VkChainBuilder _ content: () -> (Component)) {
//         self.elements = content()
//     }

//     @usableFromInline
//     internal init(_ elements: Component) {
//         self.elements = elements
//     }

//     @inlinable @inline(__always)
//     public func withUnsafeChainPointer<R>(_ body: (UnsafeRawPointer?) throws -> (R)) rethrows -> R {
//         if elements.isEmpty {
//             return try body(nil)
//         }

//         let indices = elements.indices

//         let head = elements[indices.lowerBound]
//         let tail = elements[indices.dropFirst()]
        
//         return try head.withApplied(to: nil, tail: tail, body)
//     }
// }

// public class AnyNext {
//     @usableFromInline
//     internal let builder: AnyBuilder

//     public init<Struct: VulkanChainableStructure>(_ builder: LavaContainer<Struct>) {
//         self.builder = builder
//     }

//     @inlinable @inline(__always)
//     public func withApplied<R>(to previous: UnsafeMutablePointer<VkBaseInStructure>?, tail: ArraySlice<AnyNext>, _ body: (UnsafeRawPointer?) throws -> (R)) rethrows -> R {
//         return try builder.withUnsafeMutableRawPointer {
//             let castedNext = $0.assumingMemoryBound(to: VkBaseInStructure.self)

//             previous?.pointee[keyPath: \.pNext] = UnsafePointer(castedNext)

//             let indices = tail.indices
//             if indices.lowerBound == indices.upperBound {
//                 return try body(castedNext)
//             } else {
//                 let nextHead = tail[indices.lowerBound]
//                 let nextTail = tail[indices.dropFirst()]

//                 return try nextHead.withApplied(to: castedNext, tail: nextTail, body)
//             }
//         }
//     }
// }

// public protocol AnyBuilder {
//     func withUnsafeMutableRawPointer<R>(_ body: (UnsafeMutableRawPointer) throws -> (R)) rethrows -> R
// }

// extension LavaBuilder: AnyBuilder {
//     @inlinable @inline(__always)
//     public func withUnsafeMutableRawPointer<R>(_ body: (UnsafeMutableRawPointer) throws -> (R)) rethrows -> R {
//         return try withUnsafeMutableResultPointer {
//             return try body(UnsafeMutableRawPointer($0))
//         }
//     }
// }
