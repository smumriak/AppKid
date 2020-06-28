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
        var shaderModuleCreationInfo = VkShaderModuleCreateInfo()
        shaderModuleCreationInfo.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
        shaderModuleCreationInfo.codeSize = data.count

        let handlePointer: SmartPointer<VkShaderModule_T> = try data.withUnsafeBytes {
            shaderModuleCreationInfo.pCode = $0.baseAddress!.assumingMemoryBound(to: CUnsignedInt.self)

            let handle = try device.createEntity(info: &shaderModuleCreationInfo, using: vkCreateShaderModule)

            return SmartPointer(with: handle) { [unowned device] in
                vkDestroyShaderModule(device.handle, $0, nil)
            }
        }

        try super.init(device: device, handlePointer: handlePointer)
    }
}
