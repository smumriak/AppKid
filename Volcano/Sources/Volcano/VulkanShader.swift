//
//  VulkanShader.swift
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

public final class VulkanShader: VulkanDeviceEntity<CustomDestructablePointer<VkShaderModule_T>> {
    public init(data: Data, device: VulkanDevice) throws {
        if data.isEmpty {
            throw VulkanShaderError.noData
        }
        var shaderModuleCreationInfo = VkShaderModuleCreateInfo()
        shaderModuleCreationInfo.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
        shaderModuleCreationInfo.codeSize = data.count

        data.withUnsafeBytes {
            let pointer = $0.baseAddress!.assumingMemoryBound(to: CUnsignedInt.self)
            shaderModuleCreationInfo.pCode = pointer
        }

        let handle = try device.handle.createEntity(info: &shaderModuleCreationInfo, using: vkCreateShaderModule)
        let handlePointer = CustomDestructablePointer(with: handle) { [unowned device] in
            vkDestroyShaderModule(device.handle, $0, nil)
        }

        try super.init(device: device, handlePointer: handlePointer)
    }
}
