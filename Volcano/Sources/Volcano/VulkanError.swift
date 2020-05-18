//
//  VulkanError.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import CVulkan

public enum VulkanError: Error {
    case badResult(VkResult)
    case instanceFunctionNotFound(String)
    case deviceFunctionNotFound(String)
}
