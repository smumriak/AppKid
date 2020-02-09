//
//  CGContext+AppKid.swift
//  AppKid
//
//  Created by Serhii Mumriak on 8/2/20.
//

import Foundation
import CairoGraphics

public extension CairoGraphics.CGContext {
    internal static var contextsStack = [CairoGraphics.CGContext]()
    internal(set) static var current: CairoGraphics.CGContext? = nil
    
    static func begin(size: CGSize) -> CairoGraphics.CGContext {
        if let context = CairoGraphics.CGContext(width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: Int(size.width) * 32, space: CairoGraphics.CGColorSpace(), bitMapInfo: CairoGraphics.CGContext.CGBitmapInfo(rawValue: 0)) {
            push(context)
            return context
        } else {
            fatalError("Error creating context with known arguments")
        }
    }
    
    static func push(_ context: CairoGraphics.CGContext) {
        if let current = current {
            contextsStack.append(current)
        }
        
        current = context
    }
    
    static func pop() {
        current = contextsStack.popLast()
    }
}
