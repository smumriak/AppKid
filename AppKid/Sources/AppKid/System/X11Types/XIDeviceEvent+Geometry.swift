//
//  XIDeviceEvent+Geometry.swift
//  AppKid
//
//  Created by Serhii Mumriak on 28.04.2020.
//

import Foundation
import CXlib

internal extension XIDeviceEvent {
    var locationInWindow: CGPoint {
        return CGPoint(x: event_x, y: event_y)
    }
}
