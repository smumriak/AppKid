//
//  DescriptorsSetCache.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 08.07.2021
//

import Foundation
import Collections
import CoreFoundation
import Volcano
import CVulkan
import TinyFoundation

protocol KeySomething: Hashable {}

internal class DescriptorsSetCache {
    let lock = RecursiveLock()
    let device: Device
    let layout: DescriptorSetLayout
    let sizes: [VkDescriptorPoolSize]
    let maxSets: UInt
    
    fileprivate var usedDescriptors: [AnyHashable: DescriptorSet] = [:]
    fileprivate var freeDescriptors: Set<DescriptorSet> = []

    fileprivate var _currentPool: DescriptorPool? = nil
    fileprivate var currentPool: DescriptorPool {
        get throws {
            return try lock.synchronized {
                if _currentPool == nil {
                    _currentPool = try DescriptorPool(device: device, sizes: sizes, maxSets: maxSets)
                }

                return _currentPool!
            }
        }
    }

    init(device: Device, layout: DescriptorSetLayout, sizes: [(type: VkDescriptorType, count: UInt)], maxSets: UInt = 1000) throws {
        self.device = device
        self.layout = layout
        self.sizes = sizes.map { VkDescriptorPoolSize(type: $0.type, descriptorCount: CUnsignedInt($0.count)) }
        self.maxSets = maxSets
    }

    func clear() {
        lock.synchronized {
            usedDescriptors.removeAll()
            freeDescriptors.removeAll()
            _currentPool = nil
        }
    }

    func releaseDescriptorSet(for key: AnyHashable) {
        lock.synchronized {
            if let descriptorSet = usedDescriptors[key] {
                usedDescriptors.removeValue(forKey: key)
                freeDescriptors.insert(descriptorSet)
            }
        }
    }

    func existingDescriptorSet(for key: AnyHashable) -> DescriptorSet? {
        return lock.synchronized { usedDescriptors[key] }
    }

    func createDescriptorSet(for key: AnyHashable) throws -> DescriptorSet {
        return try lock.synchronized {
            if let result = usedDescriptors[key] {
                return result
            } else if let result = freeDescriptors.randomElement() {
                freeDescriptors.remove(result)
            
                usedDescriptors[key] = result
                return result
            } else {
                let result: DescriptorSet = try {
                    do {
                        return try currentPool.allocate(with: layout)
                    } catch {
                        if case let VulkanError.badResult(vulkanResult) = error {
                            switch vulkanResult {
                                case .errorFragmentedPool, .errorOutOfPoolMemory:
                                    _currentPool = nil

                                    return try currentPool.allocate(with: layout)

                                default:
                                    throw error
                            }
                        } else {
                            throw error
                        }
                    }
                }()

                usedDescriptors[key] = result
                return result
            }
        }
    }
}
