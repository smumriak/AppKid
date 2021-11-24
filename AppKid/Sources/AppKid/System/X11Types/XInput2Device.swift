//
//  XInput2Device.swift
//  AppKid
//
//  Created by Serhii Mumriak on 30.04.2020.
//

import Foundation
import CXlib

internal struct XInput2Device {
    var identifier: CInt = 0
    var valuatorsCount: CInt = 0
    var type: DeviceType = .pointer

    enum DeviceType {
        case pointer
        case keyboard
    }
}

extension XInput2Device.DeviceType {
    var mask: XInput2EventTypeMask {
        switch self {
            case .pointer:
                return [.mouse, .motion, .enterLeave, .focus]

            case .keyboard:
                return [.keyboard]
        }
    }
}
