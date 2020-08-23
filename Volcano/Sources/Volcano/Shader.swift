//
//  Shader.swift
//  Volcano
//
//  Created by Serhii Mumriak on 20.05.2020.
//

import Foundation

public enum VulkanShaderError: Error {
    case noData
    case noSuchFile
}

public final class Shader: VulkanDeviceEntity<SmartPointer<VkShaderModule_T>> {
    public convenience init(named name: String, in bundle: Bundle? = nil, device: Device) throws {
        let bundle = bundle ?? Bundle.main

        let nameCasted = name as NSString
        let fileName = nameCasted.deletingPathExtension
        var fileExtension = nameCasted.pathExtension
        if fileExtension.isEmpty {
            fileExtension = "spv"
        }

        guard let url = bundle.url(forResource: fileName, withExtension: fileExtension) else {
            throw VulkanShaderError.noSuchFile
        }

        let data = try Data(contentsOf: url, options: [])

        try self.init(data: data, device: device)
    }

    public init(data: Data, device: Device) throws {
        if data.isEmpty {
            throw VulkanShaderError.noData
        }
        var info = VkShaderModuleCreateInfo()
        info.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
        info.codeSize = data.count

        let handlePointer: SmartPointer<VkShaderModule_T> = try data.withUnsafeBytes {
            info.pCode = $0.baseAddress!.assumingMemoryBound(to: CUnsignedInt.self)

            return try device.create(with: info)
        }

        try super.init(device: device, handlePointer: handlePointer)
    }
}
