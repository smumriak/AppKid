//
//  CGContext+AppKid.swift
//  AppKid
//
//  Created by Serhii Mumriak on 08.02.2020.
//

import Foundation
import CairoGraphics

#if os(macOS)
import class CairoGraphics.CGContext
import class CairoGraphics.CGColorSpace
#endif

public extension CGContext {
    internal static var contextsStack = [CGContext]()
    internal(set) static var current: CGContext? = nil
    
    static func begin(size: CGSize) -> CGContext {
        if let context = CGContext(width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: Int(size.width) * 32, space: CGColorSpace(), bitMapInfo: CGContext.CGBitmapInfo(rawValue: 0)) {
            push(context)
            return context
        } else {
            fatalError("Error creating context with known arguments")
        }
    }
    
    static func push(_ context: CGContext) {
        if let current = current {
            contextsStack.append(current)
        }
        
        current = context
    }
    
    static func pop() {
        current = contextsStack.popLast()
    }
}
