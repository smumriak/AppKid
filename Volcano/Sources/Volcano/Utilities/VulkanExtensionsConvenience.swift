//
//  VulkanExtensionsConvenience.swift
//  Volcano
//
//  Created by Serhii Mumriak on 09.05.2022.
//

import Foundation
import TinyFoundation
import CVulkan

internal protocol VulkanExtension {
    init?(rawValue: String)
    var rawValue: String { get }
}

extension InstanceExtension: VulkanExtension {}
extension DeviceExtension: VulkanExtension {}

internal extension VkExtensionProperties {
    func nameVersion<T: VulkanExtension>() -> (name: T, version: UInt)? {
        guard let name = T(rawValue: String(cStringTuple: extensionName)) else {
            return nil
        }
        return (name: name, version: UInt(specVersion))
    }
}

extension Array where Element: VulkanExtension {
    var cStrings: [SharedPointer<Int8>] {
        return map { $0.rawValue }.cStrings
    }
}

extension Set where Element: VulkanExtension {
    var cStrings: [SharedPointer<Int8>] {
        return Array(self).cStrings
    }
}
