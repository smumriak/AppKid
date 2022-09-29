//
//  Shader.swift
//  Volcano
//
//  Created by Serhii Mumriak on 20.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public final class Shader: DeviceEntity<VkShaderModule_T> {
    public static let defaultShaderEntryPointName = "main"

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

    public init(data: Data, entryPoint: String = Shader.defaultShaderEntryPointName, device: Device) throws {
        if data.isEmpty {
            throw Error.noData
        }
        var info = VkShaderModuleCreateInfo.new()
        info.codeSize = data.count

        let handle: SharedPointer<VkShaderModule_T> = try data.withUnsafeBytes {
            info.pCode = $0.baseAddress!.assumingMemoryBound(to: CUnsignedInt.self)

            return try device.create(with: &info)
        }

        self.entryPoint = entryPoint

        try super.init(device: device, handle: handle)
    }
}

public extension Shader {
    fileprivate static let defaultShaderEntryPointNamePointer = strdup(defaultShaderEntryPointName)

    func createStageInfo(for stage: VkShaderStageFlagBits, flags: VkPipelineShaderStageCreateFlagBits = []) -> VkPipelineShaderStageCreateInfo {
        var result = VkPipelineShaderStageCreateInfo.new()
        
        result.pNext = nil
        result.flags = flags.rawValue
        result.stage = stage
        result.module = pointer
        result.pName = UnsafePointer(Shader.defaultShaderEntryPointNamePointer)
        result.pSpecializationInfo = nil

        return result
    }

    @LVBuilder<VkPipelineShaderStageCreateInfo>
    func builder(for stage: VkShaderStageFlagBits, flags: VkPipelineShaderStageCreateFlagBits = []) -> LVBuilder<VkPipelineShaderStageCreateInfo> {
        \.flags <- flags
        \.stage <- stage
        \.module <- self
        \.pName <- entryPoint
        \.pSpecializationInfo <- nil
    }
}
