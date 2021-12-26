//
//  CAAnimation.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 25.11.2020.
//

import Foundation
import CoreFoundation
import CairoGraphics
import TinyFoundation

public protocol CAAnimationDelegate: AnyObject {
}

open class CAAnimation: CAValuesContainer, CAMediaTiming, CAAction {
    // MARK: - Key Value Coding

    open override class func defaultValue(forKey key: String) -> Any? {
        switch key {
            case "isRemovedOnCompletion": return Value(false)
            case "timingFunction": return nil
            default: return super.defaultValue(forKey: key)
        }
    }

    @CAProperty(name: "isRemovedOnCompletion")
    open var isRemovedOnCompletion: Bool

    internal var fallbackAnimationKey: some StringProtocol {
        return "\(type(of: self)):\(ObjectIdentifier(self))"
    }

    // @CAProperty(name: "timingFunction")
    // var timingFunction: CAMediaTimingFunction?

    public func run(forKey event: String, object: Any, arguments dict: [AnyHashable: Any]?) {
        if let layer = object as? CALayer {
            layer.add(self, forKey: event)
        }
    }
}

open class CAPropertyAnimation: CAAnimation {
    open override class func defaultValue(forKey key: String) -> Any? {
        switch key {
            case "keyPath": return nil
            case "isCumulative": return Value(false)
            case "isAdditive": return Value(false)
            case "valueFunction": return nil
            default: return super.defaultValue(forKey: key)
        }
    }

    public convenience init(keyPath: String?) {
        self.init()
        
        self.keyPath = keyPath
    }

    @CAProperty(name: "keyPath")
    open var keyPath: String?

    @CAProperty(name: "isCumulative")
    var isCumulative: Bool

    @CAProperty(name: "isAdditive")
    var isAdditive: Bool

    // @CAProperty(name: "valueFunction")
    // var valueFunction: CAValueFunction?
}
