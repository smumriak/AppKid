//
//  QueueCreation.swift
//  Volcano
//
//  Created by Serhii Mumriak on 09.01.2021.
//

import Foundation
import TinyFoundation
import CVulkan

public struct QueueFamilyDescriptor {
    public let index: Int
    public let properties: VkQueueFamilyProperties

    public init(index: Int, properties: VkQueueFamilyProperties) {
        self.index = index
        self.properties = properties
    }

    public func satisfies(_ request: QueueRequest) -> Bool {
        return properties.type.contains(request.type) && Int(properties.queueCount) >= request.priorities.count
    }
}

extension QueueFamilyDescriptor: Comparable, Equatable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.properties.type < rhs.properties.type
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.index == rhs.index
            && lhs.properties == rhs.properties
    }
}

public struct QueueRequest {
    public let type: VkQueueFlagBits
    public let priorities: [Float]

    public init(type: VkQueueFlagBits, priorities: [Float] = [0.0]) {
        self.type = type
        self.priorities = priorities
    }

    public static let `default` = QueueRequest(type: .graphics, priorities: [0.0])
}

internal struct ProcessedQueueRequest {
    internal let index: Int
    internal var type: VkQueueFlagBits
    internal var flags: VkDeviceQueueCreateFlagBits
    internal var priorities: [Float]
}

public extension VkQueueFamilyProperties {
    var type: VkQueueFlagBits { VkQueueFlagBits(rawValue: queueFlags) }

    var isGraphics: Bool { type.contains(.graphics) }
    var isCompute: Bool { type.contains(.compute) }
    var isTransfer: Bool { type.contains(.transfer) }
    var isSparseBinding: Bool { type.contains(.sparseBinding) }
    var isProtected: Bool { type.contains(.protected) }
}

extension VkQueueFlagBits: Comparable, Equatable {
    internal static let flagsOrder: [VkQueueFlagBits] = [
        .graphics,
        .compute,
        .transfer,
        .sparseBinding,
        .protected,
        [.compute, .transfer],
        [.compute, .sparseBinding],
        [.compute, .protected],
        [.transfer, .sparseBinding],
        [.transfer, .protected],
        [.sparseBinding, .protected],
        [.compute, .transfer, .sparseBinding],
        [.compute, .transfer, .protected],
        [.transfer, .sparseBinding, .protected],
        [.compute, .transfer, .sparseBinding, .protected],
        [.graphics, .compute],
        [.graphics, .transfer],
        [.graphics, .sparseBinding],
        [.graphics, .protected],
        [.graphics, .compute, .transfer],
        [.graphics, .compute, .sparseBinding],
        [.graphics, .compute, .protected],
        [.graphics, .compute, .transfer],
        [.graphics, .transfer, .sparseBinding],
        [.graphics, .transfer, .protected],
        [.graphics, .sparseBinding, .protected],
        [.graphics, .compute, .transfer, .sparseBinding],
        [.graphics, .compute, .transfer, .protected],
        [.graphics, .compute, .sparseBinding, .protected],
        [.graphics, .compute, .transfer, .sparseBinding, .protected],
    ]

    public static func < (lhs: Self, rhs: Self) -> Bool {
        if let lhsIndex = flagsOrder.firstIndex(of: lhs),
           let rhsIndex = flagsOrder.firstIndex(of: rhs) {
            return lhsIndex < rhsIndex
        } else {
            return false
        }
    }
}

extension VkExtent3D: Comparable, Equatable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.width < rhs.width
            && lhs.height < rhs.height
            && lhs.depth < rhs.depth
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.width == rhs.width
            && lhs.height == rhs.height
            && lhs.depth == rhs.depth
    }
}

extension VkQueueFamilyProperties: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.queueFlags == rhs.queueFlags
            && lhs.queueCount == rhs.queueCount
            && lhs.timestampValidBits == rhs.timestampValidBits
            && lhs.minImageTransferGranularity == rhs.minImageTransferGranularity
    }
}

internal func processQueueRequests(from queueRequests: [QueueRequest], familiesDescriptors: [QueueFamilyDescriptor]) throws -> [ProcessedQueueRequest] {
    let result: [Int: ProcessedQueueRequest] = try queueRequests.reduce(into: [:]) { accumulator, queueRequest in
        guard let familyDescriptor = familiesDescriptors.first(where: { $0.satisfies(queueRequest) }) else {
            throw VulkanError.noQueueFamilySatisfyingType(queueRequest.type)
        }
        let familyIndex = familyDescriptor.index

        if var processedRequest = accumulator[familyIndex] {
            processedRequest.priorities += queueRequest.priorities

            let excedingQueueCount = processedRequest.priorities.count - Int(familyDescriptor.properties.queueCount)

            if excedingQueueCount > 0 {
                processedRequest.priorities.removeLast(excedingQueueCount)
            }

            accumulator[familyIndex] = processedRequest
        } else {
            let flags: VkDeviceQueueCreateFlagBits = queueRequest.type.contains(.protected) ? .protected : []
            let processedRequest = ProcessedQueueRequest(index: familyIndex, type: familyDescriptor.properties.type, flags: flags, priorities: queueRequest.priorities)

            accumulator[familyIndex] = processedRequest
        }
    }

    return Array(result.values).sorted { $0.type < $1.type }
}

internal extension Array where Element == ProcessedQueueRequest {
    func withUnsafeDeviceQueueCreateInfoBufferPointer<R>(_ body: (UnsafeBufferPointer<VkDeviceQueueCreateInfo>) throws -> (R)) throws -> R {
        var buffer = Array<VkDeviceQueueCreateInfo>()
        buffer.reserveCapacity(count)

        return try (self[0..<count]).populateDeviceQueueCreateInfo(buffer: &buffer, body: body)
    }
}

internal extension ArraySlice where Element == ProcessedQueueRequest {
    func populateDeviceQueueCreateInfo<R>(buffer: inout [VkDeviceQueueCreateInfo], body: (UnsafeBufferPointer<VkDeviceQueueCreateInfo>) throws -> (R)) throws -> R {
        let indices = self.indices

        if indices.lowerBound == indices.upperBound {
            return try buffer.withUnsafeBufferPointer {
                return try body($0)
            }
        } else {
            let head = self[indices.lowerBound]

            return try head.priorities.withUnsafeBufferPointer {
                var info = VkDeviceQueueCreateInfo.new()
                info.flags = head.flags.rawValue
                info.queueFamilyIndex = CUnsignedInt(head.index)
                info.queueCount = CUnsignedInt($0.count)
                info.pQueuePriorities = $0.baseAddress!

                buffer.append(info)

                return try (self[indices.dropFirst()]).populateDeviceQueueCreateInfo(buffer: &buffer, body: body)
            }
        }
    }
}
