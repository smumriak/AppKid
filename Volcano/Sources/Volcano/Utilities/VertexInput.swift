//
//  VertexInput.swift
//  Volcano
//
//  Created by Serhii Mumriak on 20.01.2020.
//

import Foundation
import CVulkan
import SimpleGLM

public protocol VertexInput {
    static func inputBindingDescription(binding: CUnsignedInt) -> VkVertexInputBindingDescription
    static func attributesDescriptions(binding: CUnsignedInt) -> [VkVertexInputAttributeDescription]

    static func attributesDescriptions<T: VertexInputAttribute>(for keyPath: KeyPath<Self, T>, binding: CUnsignedInt, location: CUnsignedInt) -> [VkVertexInputAttributeDescription]
}

public extension VertexInput {
    static func attributesDescriptions<T>(for keyPath: KeyPath<Self, T>, binding: CUnsignedInt, location: CUnsignedInt) -> [VkVertexInputAttributeDescription] where T: VertexInputAttribute {
        return T.descriptions(binding: binding, offset: CUnsignedInt(MemoryLayout<Self>.offset(of: keyPath)!), location: location)
    }
}

public protocol VertexInputAttribute {
    static var format: VkFormat { get }
    static func descriptions(binding: CUnsignedInt, offset: CUnsignedInt, location: CUnsignedInt) -> [VkVertexInputAttributeDescription]
}

public protocol SingleRowVertexInputAttribute: VertexInputAttribute {}

public extension SingleRowVertexInputAttribute {
    static func descriptions(binding: CUnsignedInt, offset: CUnsignedInt, location: CUnsignedInt) -> [VkVertexInputAttributeDescription] {
        return [VkVertexInputAttributeDescription(location: location, binding: binding, format: format, offset: offset)]
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
            attributeDescription.format = .r32g32SFloat
            attributeDescription.offset = offset + stride * i
            return attributeDescription
        }
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

//palkovnik:TODO:I'm not sure if definitions for 64 bit numbers are correct. Will have to recheck this
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