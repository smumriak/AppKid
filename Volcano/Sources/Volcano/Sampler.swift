//
//  Sampler.swift
//  Volcano
//
//  Created by Serhii Mumriak on 04.07.2021.
//

import TinyFoundation
import CVulkan

public final class Sampler: DeviceEntity<VkSampler_T> {
    public struct AddressModes {
        public var u: VkSamplerAddressMode
        public var v: VkSamplerAddressMode
        public var w: VkSamplerAddressMode

        public static let `repeat` = AddressModes(u: .repeat, v: .repeat, w: .repeat)

        public init(u: VkSamplerAddressMode, v: VkSamplerAddressMode, w: VkSamplerAddressMode) {
            self.u = u
            self.v = v
            self.w = w
        }
    }

    public struct Filters {
        public var magnification: VkFilter
        public var minification: VkFilter

        public init(magnification: VkFilter, minification: VkFilter) {
            self.magnification = magnification
            self.minification = minification
        }

        public static let nearest = Filters(magnification: .nearest, minification: .nearest)
        public static let linear = Filters(magnification: .linear, minification: .linear)
        public static let cubic = Filters(magnification: .cubicImg, minification: .cubicImg)
    }

    public struct LevelOfDetails {
        public var bias: Float
        public var min: Float
        public var max: Float

        public init(bias: Float, min: Float, max: Float) {
            self.bias = bias
            self.min = min
            self.max = max
        }

        public static let none = LevelOfDetails(bias: 0, min: 0, max: 0)
    }

    public init(device: Device, addressModes: AddressModes = .repeat, flags: VkSamplerCreateFlagBits = [], filters: Filters = .linear, mipMapMode: VkSamplerMipmapMode = .linear, levelOfDetails: LevelOfDetails = .none, borderColor: VkBorderColor = .intOpaqueBlack, maxAnisotropy: Float? = nil, compareOperation: VkCompareOp? = nil, unnormalizedCoordinates: Bool = false) throws {
        var info = VkSamplerCreateInfo.new()
        info.flags = flags.rawValue
        
        info.magFilter = filters.magnification
        info.minFilter = filters.minification

        info.mipmapMode = mipMapMode

        info.addressModeU = addressModes.u
        info.addressModeV = addressModes.v
        info.addressModeW = addressModes.w

        info.mipLodBias = levelOfDetails.bias
        info.minLod = levelOfDetails.min
        info.maxLod = levelOfDetails.max

        info.borderColor = borderColor

        if let maxAnisotropy = maxAnisotropy {
            info.anisotropyEnable = true.vkBool
            info.maxAnisotropy = maxAnisotropy
        }

        if let compareOperation = compareOperation {
            info.compareEnable = true.vkBool
            info.compareOp = compareOperation
        }

        info.unnormalizedCoordinates = unnormalizedCoordinates.vkBool

        let handle = try device.create(with: &info)

        try super.init(device: device, handle: handle)
    }
}
