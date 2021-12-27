//
//  CATransaction.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 12.05.2020.
//

import Foundation

// fileprivate class UnownedStorage {
//     fileprivate unowned let value: AnyObject
//     fileprivate init(value: AnyObject) {
//         self.value = value
//     }
// }

fileprivate class CATransactionStorage {
    fileprivate var presentationLayers: [ObjectIdentifier: CALayer] = [:]
    // fileprivate var modelLayers: [ObjectIdentifier: UnownedStorage] = [:]
    fileprivate var modelLayers: [ObjectIdentifier: CALayer] = [:]

    fileprivate func clear() {
        presentationLayers = [:]
        modelLayers = [:]
    }

    // fileprivate func presentationLayer(for layer: CALayer) -> CALayer? {
    //     return presentationLayers[ObjectIdentifier(layer)]
    // }

    // fileprivate func modelLayer(for layer: CALayer) -> CALayer? {
    //     if let result = modelLayers[ObjectIdentifier(layer)] {
    //         return (result.value as! CALayer )
    //     } else {
    //         return nil
    //     }
    // }

    fileprivate func presentationLayer(for layer: CALayer) -> CALayer? {
        return presentationLayers[ObjectIdentifier(layer)]
    }

    fileprivate func modelLayer(for layer: CALayer) -> CALayer? {
        return modelLayers[ObjectIdentifier(layer)]
    }
}

open class CATransaction: CAValuesContainer {
    public class func begin() {
        _ = CATransaction(implicit: false)
    }

    public class func commit() {
        fatalError()
    }

    public class func flush() {
        fatalError()
    }

    private static let rootTransactionThreadKey = UUID()
    private static let currentTransactionThreadKey = UUID()
    private static let transactionStorageThreadKey = UUID()

    @_spi(AppKid) public class var root: CATransaction? {
        get {
            Thread.current.threadDictionary[CATransaction.rootTransactionThreadKey] as! CATransaction?
        }
        set {
            Thread.current.threadDictionary[CATransaction.rootTransactionThreadKey] = newValue
        }
    }

    private static var _current: CATransaction? {
        get {
            Thread.current.threadDictionary[CATransaction.currentTransactionThreadKey] as! CATransaction?
        }
        set {
            Thread.current.threadDictionary[CATransaction.currentTransactionThreadKey] = newValue

            if newValue != nil {
                if root == nil {
                    root = newValue
                }

                if storage == nil {
                    storage = CATransactionStorage()
                }
            }
        }
    }

    @_spi(AppKid) public class var current: CATransaction? {
        get {
            if _current == nil {
                _current = CATransaction(implicit: true)
            }
            return _current!
        }
        set {
            _current = newValue
        }
    }

    private static var storage: CATransactionStorage? {
        get {
            Thread.current.threadDictionary[CATransaction.transactionStorageThreadKey] as! CATransactionStorage?
        }
        set {
            Thread.current.threadDictionary[CATransaction.transactionStorageThreadKey] = newValue
        }
    }

    internal static func presentationLayer(for layer: CALayer) -> CALayer? {
        return storage?.modelLayer(for: layer)
    }

    internal static func modelLayer(for layer: CALayer) -> CALayer? {
        return storage?.modelLayer(for: layer)
    }

    deinit {
        CATransaction.current = parent
    }

    @_spi(AppKid) public let implicit: Bool
    @_spi(AppKid) public let identifier = UUID()

    @_spi(AppKid) public init(implicit: Bool) {
        self.implicit = implicit
        self.parent = CATransaction._current

        super.init()

        CATransaction._current = self
    }

    @_spi(AppKid) public var parent: CATransaction? = nil
}
