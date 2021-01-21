//
//  VertexAttributeDescriptor.swift
//  Volcano
//
//  Created by Serhii Mumriak on 17.01.2021.
//

import CVulkan

public class VertexAttributeDescriptor {
    var format: VkFormat = .undefined
    var bufferIndex: Int = 0
    var offset: Int = 0
}
