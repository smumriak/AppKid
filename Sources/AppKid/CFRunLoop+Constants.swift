//
//  CFRunLoop+Constants.swift
//  AppKid
//
//  Created by Serhii Mumriak on 31.01.2020.
//

import CoreFoundation

#if os(Linux)
let CFRunLoopCommonModesConstant = kCFRunLoopCommonModes
#else
let CFRunLoopCommonModesConstant = CFRunLoopMode.commonModes
#endif
