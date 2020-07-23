//
//  Shader.swift
//  Volcano
//
//  Created by Serhii Mumriak on 20.05.2020.
//

import Foundation
import TinyFoundation
import CVulkan

public enum VulkanShaderError: Error {
    case noData
}

public final class Shader: VulkanDeviceEntity<SmartPointer<VkShaderModule_T>> {
    public init(data: Data, device: Device) throws {
        if data.isEmpty {
            throw VulkanShaderError.noData
        }
        var info = VkShaderModuleCreateInfo()
        info.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
        info.codeSize = data.count

        let handlePointer: SmartPointer<VkShaderModule_T> = try data.withUnsafeBytes {
            info.pCode = $0.baseAddress!.assumingMemoryBound(to: CUnsignedInt.self)

            return try device.create(with: &info)
        }

        try super.init(device: device, handlePointer: handlePointer)
    }
}
