//
//  VulkanRenderTarget.swift
//  AppKid
//
//  Created by Serhii Mumriak on 28.08.2020.
//

import Foundation
import Volcano
import TinyFoundation
import CVulkan

internal final class VulkanRenderTarget {
    var image: Image?
    var imageView: ImageView?
}