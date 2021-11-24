//
//  XInput2Button.swift
//  SwiftXlib
//
//  Created by Serhii Mumriak on 22.04.2020.
//

import Foundation
import CXlib

public enum XInput2Button: RawRepresentable {
    public typealias RawValue = CInt

    case none
    case left
    case right
    case middle
    case scrollUp
    case scrollDown
    case other(buttonNumber: CInt)

    public var rawValue: RawValue {
        switch self {
            case .none: return 0
            case .left: return 1
            case .right: return 2
            case .middle: return 3
            case .scrollUp: return 4
            case .scrollDown: return 5
            case .other(let buttonNumber): return buttonNumber
        }
    }

    public init(rawValue: RawValue) {
        switch rawValue {
            case 0: self = .none
            case 1: self = .left
            case 2: self = .middle
            case 3: self = .right
            case 4: self = .scrollUp
            case 5: self = .scrollDown
            default: self = .other(buttonNumber: rawValue)
        }
    }
}
