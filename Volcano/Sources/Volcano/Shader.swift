//
//  Shader.swift
//  Volcano
//
//  Created by Serhii Mumriak on 20.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public final class Shader: VulkanDeviceEntity<SmartPointer<VkShaderModule_T>> {
    public enum Error: Swift.Error {
        case noData
        case noSuchFile
    }

    public let entryPoint: String

    public convenience init(named name: String, entryPoint: String = "main", in bundle: Bundle? = nil, subdirectory: String? = nil, device: Device) throws {
        let bundle = bundle ?? Bundle.main

        let nameCasted = name as NSString
        let fileName = nameCasted.deletingPathExtension
        var fileExtension = nameCasted.pathExtension
        if fileExtension.isEmpty {
            fileExtension = "spv"
        }

        guard let url = bundle.url(forResource: fileName, withExtension: fileExtension, subdirectory: subdirectory) else {
            throw Error.noSuchFile
        }

        let data = try Data(contentsOf: url, options: [])

        try self.init(data: data, entryPoint: entryPoint, device: device)
    }

    public init(data: Data, entryPoint: String = "main", device: Device) throws {
        if data.isEmpty {
            throw Error.noData
        }
        var info = VkShaderModuleCreateInfo()
        info.sType = .shaderModuleCreateInfo
        info.codeSize = data.count

        let handlePointer: SmartPointer<VkShaderModule_T> = try data.withUnsafeBytes {
            info.pCode = $0.baseAddress!.assumingMemoryBound(to: CUnsignedInt.self)

            return try device.create(with: &info)
        }

        self.entryPoint = entryPoint

        try super.init(device: device, handlePointer: handlePointer)
    }

    internal func withStageInfoUnsafePointer<R>(for stage: VkShaderStageFlagBits, flags: VkPipelineShaderStageCreateFlagBits = [], body: (UnsafePointer<VkPipelineShaderStageCreateInfo>) throws -> (R)) throws -> R {
        return try entryPoint.withCString { entryPoint in
            var info = VkPipelineShaderStageCreateInfo()
        
            info.sType = .pipelineShaderStageCreateInfo
            info.pNext = nil
            info.flags = flags.rawValue
            info.stage = stage
            info.module = handle
            info.pName = entryPoint
            info.pSpecializationInfo = nil

            return try withUnsafePointer(to: &info) { info in
                return try body(info)
            }
        }
    }
}

public extension Shader {
    fileprivate static let defaultShaderEntryPointName = strdup("main")

    func createStageInfo(for stage: VkShaderStageFlagBits, flags: VkPipelineShaderStageCreateFlagBits = []) -> VkPipelineShaderStageCreateInfo {
        var result = VkPipelineShaderStageCreateInfo.new()
        
        result.pNext = nil
        result.flags = flags.rawValue
        result.stage = stage
        result.module = handle
        result.pName = UnsafePointer(Shader.defaultShaderEntryPointName)
        result.pSpecializationInfo = nil

        return result
    }
}
