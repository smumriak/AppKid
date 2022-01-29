//
//  VkImageViewType.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.12.2020.
//

import CVulkan

public extension VkImageViewType {
    var imageType: VkImageType {
        switch self {
            case .oneDimension: return .oneDimension
            case .oneDimensionArray: return .oneDimension
            case .twoDimensions: return .twoDimensions
            case .twoDimensionsArray: return .twoDimensions
            case .threeDimensions: return .threeDimensions
            case .cube: return .twoDimensions
            case .cubeArray: return .twoDimensions
            default: fatalError()
        }
    }
}
