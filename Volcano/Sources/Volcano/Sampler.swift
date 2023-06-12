//
//  Sampler.swift
//  Volcano
//
//  Created by Serhii Mumriak on 04.07.2021.
//

import TinyFoundation

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
        try super.init(device: device) {
            \.flags <- flags

            \.magFilter <- filters.magnification
            \.minFilter <- filters.minification

            \.mipmapMode <- mipMapMode

            \.addressModeU <- addressModes.u
            \.addressModeV <- addressModes.v
            \.addressModeW <- addressModes.w

            \.mipLodBias <- levelOfDetails.bias
            \.minLod <- levelOfDetails.min
            \.maxLod <- levelOfDetails.max

            \.borderColor <- borderColor

            if let maxAnisotropy {
                \.anisotropyEnable <- true
                \.maxAnisotropy <- maxAnisotropy
            }

            if let compareOperation {
                \.compareEnable <- true
                \.compareOp <- compareOperation
            }

            \.unnormalizedCoordinates <- unnormalizedCoordinates.vkBool
        }
    }
}
