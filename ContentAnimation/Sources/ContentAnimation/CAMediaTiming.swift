//
//  CAMediaTiming.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 13.05.2020.
//

import Foundation
import CoreFoundation

public protocol CAMediaTiming {
    var beginTime: CFTimeInterval { get set }
    var duration: CFTimeInterval { get set }
    var speed: Float { get set }
    var timeOffset: CFTimeInterval { get set }
    var repeatCount: Float { get set }
    var repeatDuration: CFTimeInterval { get set }
    var autoreverses: Bool { get set }
    var fillMode: CAMediaTimingFillMode { get set }
}

public extension CAMediaTiming {
    var beginTime: CFTimeInterval {
        get { return 0.0 }
        set {}
    }

    var duration: CFTimeInterval {
        get { return 0.0 }
        set {}
    }

    var speed: Float {
        get { return 0.0 }
        set {}
    }

    var timeOffset: CFTimeInterval {
        get { return 0.0 }
        set {}
    }

    var repeatCount: Float {
        get { return 0.0 }
        set {}
    }

    var repeatDuration: CFTimeInterval {
        get { return 0.0 }
        set {}
    }

    var autoreverses: Bool {
        get { return false }
        set {}
    }

    var fillMode: CAMediaTimingFillMode {
        get { return .removed }
        set {}
    }
}

public struct CAMediaTimingFillMode: Hashable, Equatable, RawRepresentable {
    public typealias RawValue = String
    public let rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public static let forwards: CAMediaTimingFillMode = CAMediaTimingFillMode(rawValue: "kCAFillModeForwards")
    public static let backwards: CAMediaTimingFillMode = CAMediaTimingFillMode(rawValue: "kCAFillModeBackwards")
    public static let both: CAMediaTimingFillMode = CAMediaTimingFillMode(rawValue: "kCAFillModeBoth")
    public static let removed: CAMediaTimingFillMode = CAMediaTimingFillMode(rawValue: "kCAFillModeRemoved")
}
