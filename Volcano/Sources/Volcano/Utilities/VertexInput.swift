//
//  VertexInput.swift
//  Volcano
//
//  Created by Serhii Mumriak on 20.01.2021.
//

import Foundation
import TinyFoundation
import CVulkan
import SimpleGLM

public protocol VertexInput: PublicInitializable {
    static func inputBindingDescription(binding: CUnsignedInt) -> VkVertexInputBindingDescription
}

public extension VertexInput {
    typealias AttributesAccumulator = (attributes: [VkVertexInputAttributeDescription], offset: CUnsignedInt)

    static func attributesDescriptions(binding: CUnsignedInt = 0) -> [VkVertexInputAttributeDescription] {
        let mirror = Mirror(reflecting: Self())

        let result: AttributesAccumulator = mirror.children.reduce(AttributesAccumulator([], 0)) { accumulator, child -> AttributesAccumulator in
            guard let vertexInputAttribute = child.value as? VertexInputAttribute else {
                fatalError("Gathering vertex input attributes only supported if all stored properties are conforming to VertexInputAttribute protocol")
            }

            let vertexInputAttributeType = type(of: vertexInputAttribute)

            var location: CUnsignedInt = 0
            if let last = accumulator.attributes.last {
                location = last.location + 1
            }

            let attributes = accumulator.attributes + vertexInputAttributeType.descriptions(binding: binding, offset: accumulator.offset, location: location)
            let offset = accumulator.offset + CUnsignedInt(vertexInputAttributeType.stride)
            return (attributes, offset)
        }

        return result.attributes
    }
}

public extension VertexInput {
    static func attributesDescriptions<T: VertexInputAttribute>(for keyPath: KeyPath<Self, T>, binding: CUnsignedInt, location: CUnsignedInt) -> [VkVertexInputAttributeDescription] {
        return T.descriptions(binding: binding, offset: CUnsignedInt(MemoryLayout<Self>.offset(of: keyPath)!), location: location)
    }

    static func addAttributes<T: VertexInputAttribute>(for keyPath: KeyPath<Self, T>, binding: CUnsignedInt, result: inout [VkVertexInputAttributeDescription]) {
        var location: CUnsignedInt = 0
        if let last = result.last {
            location = last.location + 1
        }

        result += attributesDescriptions(for: keyPath, binding: binding, location: location)
    }
}

public protocol VertexInputAttribute {
    static var format: VkFormat { get }
    static var locationStride: CUnsignedInt { get }
    static func descriptions(binding: CUnsignedInt, offset: CUnsignedInt, location: CUnsignedInt) -> [VkVertexInputAttributeDescription]
}

public extension VertexInputAttribute {
    static var stride: Int {
        return MemoryLayout<Self>.stride
    }
}

public extension KeyPath where Value: VertexInputAttribute {
    static var locationStride: CUnsignedInt {
        return Value.locationStride
    }
}

public protocol SingleRowVertexInputAttribute: VertexInputAttribute {}

public extension SingleRowVertexInputAttribute {
    static func descriptions(binding: CUnsignedInt, offset: CUnsignedInt, location: CUnsignedInt) -> [VkVertexInputAttributeDescription] {
        return [VkVertexInputAttributeDescription(location: location, binding: binding, format: format, offset: offset)]
    }

    static var locationStride: CUnsignedInt {
        return 1
    }
}

public protocol MultiRowVertexInputAttribute: VertexInputAttribute {
    static var rowCount: CUnsignedInt { get }
    static var stride: CUnsignedInt { get }
}

public extension MultiRowVertexInputAttribute {
    static func descriptions(binding: CUnsignedInt, offset: CUnsignedInt, location: CUnsignedInt) -> [VkVertexInputAttributeDescription] {
        return (0..<rowCount).map { i in
            var attributeDescription = VkVertexInputAttributeDescription()
            attributeDescription.binding = binding
            attributeDescription.location = location + i
            attributeDescription.format = format
            attributeDescription.offset = offset + stride * i
            return attributeDescription
        }
    }

    static var locationStride: CUnsignedInt {
        return rowCount
    }
}

extension mat2s: MultiRowVertexInputAttribute {
    public static let rowCount: CUnsignedInt = 2
    public static let stride: CUnsignedInt = CUnsignedInt(MemoryLayout<vec2s>.stride)
    public static let format: VkFormat = .r32g32SFloat
}

extension mat3s: MultiRowVertexInputAttribute {
    public static let rowCount: CUnsignedInt = 3
    public static let stride: CUnsignedInt = CUnsignedInt(MemoryLayout<vec3s>.stride)
    public static let format: VkFormat = .r32g32b32SFloat
}

extension mat4s: MultiRowVertexInputAttribute {
    public static let rowCount: CUnsignedInt = 4
    public static let stride: CUnsignedInt = CUnsignedInt(MemoryLayout<vec4s>.stride)
    public static let format: VkFormat = .r32g32b32a32SFloat
}

extension vec2s: SingleRowVertexInputAttribute {
    public static let format: VkFormat = .r32g32SFloat
}

extension vec3s: SingleRowVertexInputAttribute {
    public static let format: VkFormat = .r32g32b32SFloat
}

extension vec4s: SingleRowVertexInputAttribute {
    public static let format: VkFormat = .r32g32b32a32SFloat
}

extension Float: SingleRowVertexInputAttribute {
    public static let format: VkFormat = .r32SFloat
}

extension Int32: SingleRowVertexInputAttribute {
    public static let format: VkFormat = .r32SInt
}

extension UInt32: SingleRowVertexInputAttribute {
    public static let format: VkFormat = .r32UInt
}

// smumriak:TODO:I'm not sure if definitions for 64 bit numbers are correct. Will have to recheck this
extension Double: MultiRowVertexInputAttribute {
    public static let rowCount: CUnsignedInt = 2
    public static let stride: CUnsignedInt = 32
    public static let format: VkFormat = .r32g32SFloat
}

extension Int64: MultiRowVertexInputAttribute {
    public static let rowCount: CUnsignedInt = 2
    public static let stride: CUnsignedInt = 32
    public static let format: VkFormat = .r32g32SInt
}

extension UInt64: MultiRowVertexInputAttribute {
    public static let rowCount: CUnsignedInt = 2
    public static let stride: CUnsignedInt = 32
    public static let format: VkFormat = .r32g32UInt
}
