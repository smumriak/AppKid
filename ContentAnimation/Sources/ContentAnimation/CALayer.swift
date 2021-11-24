//
//  CALayer.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 12.05.2020.
//

import Foundation
import CoreFoundation
import CairoGraphics

#if os(macOS)
    import struct CairoGraphics.CGAffineTransform
    import struct CairoGraphics.CGColor
    import class CairoGraphics.CGPath
    import class CairoGraphics.CGContext
#endif

public protocol CALayerDelegate: AnyObject {
    func draw(_ layer: CALayer, in context: CGContext)
    func layerWillDraw(_ layer: CALayer)
    func layoutSublayers(of layer: CALayer)
    func action(for layer: CALayer, forKey event: String) -> CAAction?
}

extension CALayerDelegate {
    func draw(_ layer: CALayer, in context: CGContext) {}
    func layerWillDraw(_ layer: CALayer) {}
    func layoutSublayers(of layer: CALayer) {}
    func action(for layer: CALayer, forKey event: String) -> CAAction? { nil }
}

public protocol CALayerDisplayDelegate: CALayerDelegate {
    func display(_ layer: CALayer)
}

public protocol CAAction {
    func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable: Any]?)
}

extension NSNull: CAAction {
    public func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable: Any]?) {}
}

open class CALayer: CAMediaTiming {
    open weak var delegate: CALayerDelegate? = nil

    open var contentsScale: CGFloat = 1.0
    
    public var renderID: UInt? = 0
    public var needsDisplay = false

    public func setNeedsDisplay() {
        needsDisplay = true
    }

    @_spi(AppKid) public var identifier = UUID()

    @CALayerProperty(name: "bounds")
    open var bounds: CGRect = .zero

    @CALayerProperty(name: "position")
    open var position: CGPoint = .zero

    @CALayerProperty(name: "zPosition")
    open var zPosition: CGFloat = 0.0

    @CALayerProperty(name: "anchorPoint")
    open var anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)

    @CALayerProperty(name: "anchorPointZ")
    open var anchorPointZ: CGFloat = 0.0

    @CALayerProperty(name: "transform")
    open var transform: CATransform3D = .identity

    open var affineTransform: CGAffineTransform {
        get { transform.affineTransform }
        set { transform = newValue.transform3D }
    }

    @CALayerProperty(name: "isHidden")
    open var isHidden: Bool = false

    @CALayerProperty(name: "mask")
    open var mask: CALayer? = nil

    @CALayerProperty(name: "masksToBounds")
    open var masksToBounds: Bool = false

    @CALayerProperty(name: "backgroundColor")
    open var backgroundColor: CGColor? = nil

    @CALayerProperty(name: "cornerRadius")
    open var cornerRadius: CGFloat = 0.0

    @CALayerProperty(name: "maskedCorners")
    open var maskedCorners: CACornerMask = .allCorners

    @CALayerProperty(name: "borderWidth")
    open var borderWidth: CGFloat = 0.0

    @CALayerProperty(name: "borderColor")
    open var borderColor: CGColor? = nil

    @CALayerProperty(name: "opacity")
    open var opacity: Float = 1.0

    @CALayerProperty(name: "shadowColor")
    open var shadowColor: CGColor? = .black

    @CALayerProperty(name: "shadowOpacity")
    open var shadowOpacity: Float = 0.0

    @CALayerProperty(name: "shadowOffset")
    open var shadowOffset: CGSize = CGSize(width: 0.0, height: -3.0)

    @CALayerProperty(name: "shadowRadius")
    open var shadowRadius: CGFloat = 3

    @CALayerProperty(name: "shadowPath")
    open var shadowPath: CGPath? = nil

    open var contents: Any?

    open var superlayer: CALayer? = nil
    open var sublayers: [CALayer]? = nil

    public var beginTime: CFTimeInterval = 0.0
    public var duration: CFTimeInterval = 0.0
    public var speed: Float = 0.0
    public var timeOffset: CFTimeInterval = 0.0
    public var repeatCount: Float = 0.0
    public var repeatDuration: CFTimeInterval = 0.0
    public var autoreverses: Bool = false
    public var fillMode: CAMediaTimingFillMode = .removed

    internal var properties: [String: CALayerPropertyProtocol] = [:]

    public func addSublayer(_ layer: CALayer) {
        insertSublayer(layer, at: UInt32(sublayers?.count ?? 0))
    }

    public func insertSublayer(_ layer: CALayer, at index: UInt32) {
        if sublayers == nil {
            sublayers = []
        }

        layer.removeFromSuperlayer()

        sublayers?.insert(layer, at: Int(index))
        layer.superlayer = self
    }

    // palkovnik:TODO:Finish this later
    public func insertSublayer(layer: CALayer, below sibling: CALayer?) throws {
        guard let sibling = sibling else {
            addSublayer(layer)
            return
        }

        guard let _ = sublayers?.firstIndex(of: sibling) else {
            // palkovnik:TODO:Throw an exception here
            return
        }
    }

    public func insertSublayer(layer: CALayer, above sibling: CALayer?) throws {
        guard let sibling = sibling else {
            addSublayer(layer)
            return
        }

        guard let _ = sublayers?.firstIndex(of: sibling) else {
            // palkovnik:TODO:Throw an exception here
            return
        }
    }

    public func removeFromSuperlayer() {
        guard let superlayer = superlayer else { return }

        if let index = superlayer.sublayers?.firstIndex(of: self) {
            superlayer.sublayers?.remove(at: index)
        }

        self.superlayer = nil
        if superlayer.sublayers?.isEmpty == true {
            superlayer.sublayers = nil
        }
    }

    public init() {
        rebuildPropertiesList()
    }

    public convenience init(layer: Any) {
        self.init()

        if let layer = layer as? CALayer {
            layer.properties.forEach {
                properties[$0] = $1
            }
        }
    }

    open func draw(in context: CGContext) {
        guard let delegate = self.delegate else {
            return
        }

        delegate.draw(self, in: context)
    }
    
    open func display() {
        if let delegate = delegate as? CALayerDisplayDelegate {
            delegate.display(self)
        } else if (contents == nil || contents is CABackingStore) && (bounds.width > 0 && bounds.height > 0) {
            do {
                let backingStore: CABackingStore = try {
                    if let backingStore = contents as? CABackingStore, backingStore.fits(size: bounds.size, scale: contentsScale) {
                        return backingStore
                    } else {
                        return try CABackingStoreContext.global.createBackingStore(size: bounds.size, scale: contentsScale)
                    }
                }()
                
                delegate?.layerWillDraw(self)
                backingStore.update { context in
                    draw(in: context)
                }

                contents = backingStore
            } catch {
                fatalError("Failed to create backing store with error: \(error)")
            }
        }

        needsDisplay = false
    }
}

@_spi(AppKid) extension CALayer: Identifiable {}

public extension CALayer {
    internal func rebuildPropertiesList() {
        properties = Mirror(reflecting: self).children
            .compactMap { $0.value as? CALayerPropertyProtocol }
            .reduce(into: [:]) { $0[$1.name] = $1 }
    }

    func getValue<Type>(for key: String) -> Type {
        if let property = properties[key] as? CALayerProperty<Type> {
            return property.wrappedValue
        } else {
            fatalError("No property for \"\(key)\" key")
        }
    }

    func setValue<Type>(_ value: Type, for key: String) {
        if let property = properties[key] as? CALayerProperty<Type> {
            property.wrappedValue = value
        } else {
            fatalError("No property for \"\(key)\" key")
        }
    }
}

public struct CACornerMask: OptionSet {
    public typealias RawValue = UInt
    public var rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public static var layerMinXMinYCorner: CACornerMask = CACornerMask(rawValue: 1 << 0)

    public static var layerMaxXMinYCorner: CACornerMask = CACornerMask(rawValue: 1 << 1)

    public static var layerMinXMaxYCorner: CACornerMask = CACornerMask(rawValue: 1 << 2)

    public static var layerMaxXMaxYCorner: CACornerMask = CACornerMask(rawValue: 1 << 3)

    public static var allCorners: CACornerMask = [layerMinXMinYCorner, layerMaxXMinYCorner, layerMinXMaxYCorner, layerMaxXMaxYCorner]
}

extension CALayer: Equatable {
    public static func == (lhs: CALayer, rhs: CALayer) -> Bool {
        // palkovnik:TODO:this is wrong, but will do for now. Change to checking the variables OR the dictionary of variables
        return lhs === rhs
    }
}
