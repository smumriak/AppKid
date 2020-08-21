//
//  CFRunLoop+Constants.swift
//  AppKid
//
//  Created by Serhii Mumriak on 31.01.2020.
//

import CoreFoundation
import Foundation

#if os(Linux)
let CFRunLoopDefaultModeConstant: CFRunLoopMode = kCFRunLoopDefaultMode
let CFRunLoopCommonModesConstant: CFRunLoopMode = kCFRunLoopCommonModes
#else
let CFRunLoopDefaultModeConstant: CFRunLoopMode = CFRunLoopMode.defaultMode
let CFRunLoopCommonModesConstant: CFRunLoopMode = CFRunLoopMode.commonModes
#endif

internal extension RunLoop.Mode {
    var cfRunLoopMode: CFRunLoopMode {
        if self == .default {
            return CFRunLoopDefaultModeConstant
        } else if self == .common {
            return CFRunLoopCommonModesConstant
        } else {
            let mode = CFStringCreateWithCString(nil, rawValue.cString(using: .utf8), kCFStringEncodingASCII)!
            #if os(Linux)
            return mode
            #else
            return CFRunLoopMode(mode)
            #endif
        }
    }
}
