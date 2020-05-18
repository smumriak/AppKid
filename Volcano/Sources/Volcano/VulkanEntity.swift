//
//  VulkanEntity.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation
import TinyFoundation

public class VulkanEntity<Entity>: VulkanHandle<Entity> where Entity: SmartPointer {
    public internal(set) unowned var instance: VulkanInstance

    public init(instance: VulkanInstance, handlePointer: Entity) throws {
        self.instance = instance
        super.init(handlePointer: handlePointer)
    }
}
