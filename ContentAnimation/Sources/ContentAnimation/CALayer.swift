//
//  CALayer.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 12.05.2020.
//

import Foundation
import CoreFoundation
import CairoGraphics
import TinyFoundation
import OrderedCollections
import SimpleGLM
import Volcano

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
}

public extension CALayerDelegate {
    func draw(_ layer: CALayer, in context: CGContext) {}
    func layerWillDraw(_ layer: CALayer) {}
    func layoutSublayers(of layer: CALayer) {}
}

public protocol CALayerDisplayDelegate: CALayerDelegate {
    func display(_ layer: CALayer)
}

public protocol CALayerActionDelegate: CALayerDelegate {
    func action(for layer: CALayer, forKey event: String) -> CAAction?
}

public extension CALayerActionDelegate {
    func action(for layer: CALayer, forKey event: String) -> CAAction? { nil }
}

internal struct CALayerFlags: OptionSet {
    let rawValue: UInt

    public static let needsLayout: CALayerFlags = .init(rawValue: 1 << 0)
    public static let needsDisplay: CALayerFlags = .init(rawValue: 1 << 1)
    public static let needsNewTexture: CALayerFlags = .init(rawValue: 1 << 2)
}

open class CALayer: CAValuesContainer, CAMediaTiming {
    internal var flags: CALayerFlags = []
    internal var texture: Texture?

    open weak var delegate: CALayerDelegate? = nil

    @CAProperty(name: "contentsScale")
    open var contentsScale: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var needsDisplay: Bool {
        get {
            return flags.contains(.needsDisplay)
        }
        set {
            if newValue {
                flags.insert(.needsDisplay)
            } else {
                flags.remove(.needsDisplay)
            }
        }
    }

    public func setNeedsDisplay() {
        needsDisplay = true
    }

    public var needsLayout: Bool {
        get {
            flags.contains(.needsLayout)
        }
        set {
            if newValue {
                flags.insert(.needsLayout)
            } else {
                flags.remove(.needsLayout)
            }
        }
    }
    
    public func setNeedsLayout() {
        needsLayout = true
    }

    @CAProperty(name: "identifier")
    @_spi(AppKid) public var identifier: UUID

    @_spi(AppKid) public fileprivate(set) var isPresentation = false
    @_spi(AppKid) public fileprivate(set) var animations: OrderedDictionary<AnyHashable, CAAnimation> = [:]
    open var actions: [AnyHashable: CAAction]? = nil
    // smumriak:TODO: Also style property!
    // open var style: [AnyHashable: Any]? = nil

    @CAProperty(name: "bounds")
    open var bounds: CGRect

    @CAProperty(name: "position")
    open var position: CGPoint

    @CAProperty(name: "zPosition")
    open var zPosition: CGFloat

    @CAProperty(name: "anchorPoint")
    open var anchorPoint: CGPoint

    @CAProperty(name: "anchorPointZ")
    open var anchorPointZ: CGFloat

    @CAProperty(name: "transform")
    open var transform: CATransform3D

    open var affineTransform: CGAffineTransform {
        get { transform.affineTransform }
        set { transform = newValue.transform3D }
    }

    @CAProperty(name: "isHidden")
    open var isHidden: Bool

    // @CAProperty(name: "mask")
    open var mask: CALayer? = nil

    @CAProperty(name: "masksToBounds")
    open var masksToBounds: Bool

    @CAProperty(name: "backgroundColor")
    open var backgroundColor: CGColor?

    @CAProperty(name: "cornerRadius")
    open var cornerRadius: CGFloat

    @CAProperty(name: "maskedCorners")
    open var maskedCorners: CACornerMask

    @CAProperty(name: "borderWidth")
    open var borderWidth: CGFloat

    @CAProperty(name: "borderColor")
    open var borderColor: CGColor?

    @CAProperty(name: "opacity")
    open var opacity: CGFloat

    @CAProperty(name: "shadowColor")
    open var shadowColor: CGColor?

    @CAProperty(name: "shadowOpacity")
    open var shadowOpacity: CGFloat

    @CAProperty(name: "shadowOffset")
    open var shadowOffset: CGSize

    @CAProperty(name: "shadowRadius")
    open var shadowRadius: CGFloat

    @CAProperty(name: "shadowPath")
    open var shadowPath: CGPath?

    open var contents: Any? {
        didSet {
            setNeedsDisplay()
        }
    }

    open var superlayer: CALayer? = nil
    open var sublayers: [CALayer]? = nil

    public var beginTime: CFTimeInterval = 0.0
    public var duration: CFTimeInterval = 0.0
    public var speed: CGFloat = 0.0
    public var timeOffset: CFTimeInterval = 0.0
    public var repeatCount: CGFloat = 0.0
    public var repeatDuration: CFTimeInterval = 0.0
    public var autoreverses: Bool = false
    public var fillMode: CAMediaTimingFillMode = .removed

    // MARK: - Transforms

    internal var transformsAreValid = false

    @_spi(AppKid) public func invalidateTransforms() {
        transformsAreValid = false
        sublayers?.forEach { sublayer in
            sublayer.invalidateTransforms()
        }
    }

    fileprivate var _transformToRoot: mat4s = .identity
    internal var transformToRoot: mat4s {
        rebuildTransformsIfNeeded()
        return _transformToRoot
    }

    fileprivate var _transformFromRoot: mat4s = .identity
    internal var transformFromRoot: mat4s {
        rebuildTransformsIfNeeded()
        return _transformFromRoot
    }

    internal func rebuildTransformsIfNeeded() {
        if transformsAreValid { return }
        
        transformsAreValid = true
        
        if superlayer == nil {
            _transformToRoot = .identity
            _transformFromRoot = .identity
        } else {
            let superlayerTransformToRoot = superlayer?.transformToRoot ?? .identity

            // let toScreenScaleTransform = mat4s(scaleVector: vec3s(x: bounds.width, y: bounds.height, z: 1.0))
            let anchorPointTransform = mat4s(translationVector: vec3s(x: anchorPoint.x * bounds.width, y: anchorPoint.y * bounds.height, z: 0.0))

            let positionTransform = mat4s(translationVector: vec3s(x: (position.x - bounds.midX) * contentsScale, y: (position.y - bounds.midY) * contentsScale, z: 0.0))

            let _transformFromRoot =
                superlayerTransformToRoot
                    * positionTransform
                    * anchorPointTransform
                    * transform.mat4
                    * anchorPointTransform.inversed
            
            _transformToRoot = _transformFromRoot.inversed
        }
    }

    // MARK: - Geometry conversion
    
    // open func convert(_ point: CGPoint, to layer: CALayer?) -> CGPoint {
    //     let toView = layer ?? window
        
    //     let transformFromWindow = toView?.transformFromWindow ?? .identity
        
    //     return point.applying(transformToWindow).applying(transformFromWindow)
    // }
    
    // open func convert(_ point: CGPoint, from layer: CALayer?) -> CGPoint {
    //     let fromView = layer ?? window
        
    //     let transformToWindow = fromView?.transformToWindow ?? .identity
        
    //     return point.applying(transformToWindow).applying(transformFromWindow)
    // }
    
    // open func convert(_ rect: CGRect, to layer: CALayer?) -> CGRect {
    //     let toView = layer ?? window

    //     let transformFromWindow = toView?.transformFromWindow ?? .identity

    //     return rect.applying(transformToWindow).applying(transformFromWindow)
    // }
    
    // open func convert(_ rect: CGRect, from layer: CALayer?) -> CGRect {
    //     let fromView = layer ?? window

    //     let transformToWindow = fromView?.transformToWindow ?? .identity

    //     return rect.applying(transformToWindow).applying(transformFromWindow)
    // }

    // MARK: -

    public func presentation() -> Self? {
        if isPresentation {
            return self
        } else {
            return CATransaction.presentationLayer(for: self) as! Self?
        }
    }

    public func model() -> Self {
        if isPresentation {
            return CATransaction.modelLayer(for: self) as! Self
        } else {
            return self
        }
    }

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

    // smumriak:TODO:Finish this later
    public func insertSublayer(layer: CALayer, below sibling: CALayer?) throws {
        guard let sibling = sibling else {
            addSublayer(layer)
            return
        }

        guard let _ = sublayers?.firstIndex(of: sibling) else {
            // smumriak:TODO:Throw an exception here
            return
        }
    }

    public func insertSublayer(layer: CALayer, above sibling: CALayer?) throws {
        guard let sibling = sibling else {
            addSublayer(layer)
            return
        }

        guard let _ = sublayers?.firstIndex(of: sibling) else {
            // smumriak:TODO:Throw an exception here
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

    public override init() {
        super.init()

        identifier = UUID()
    }

    public convenience init(layer: Any) {
        self.init()

        if let layer = layer as? CALayer {
            values = layer.values
            isPresentation = true
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
                        flags.formUnion(.needsNewTexture)
                        return try CABackingStoreContext.global.createBackingStore(size: bounds.size, scale: contentsScale)
                    }
                }()
                
                delegate?.layerWillDraw(self)
                backingStore.update { context in
                    context.clear(bounds)
                    draw(in: context)
                }

                contents = backingStore
            } catch {
                fatalError("Failed to create backing store with error: \(error)")
            }
        }

        needsDisplay = false
    }

    // MARK: - Key Value Coding

    open override class func defaultValue(forKey key: String) -> Any? {
        switch key {
            case "bounds": return Value(CGRect.zero)
            case "position": return Value(CGPoint.zero)
            case "zPosition": return Value(CGFloat.zero)
            case "anchorPoint": return Value(CGPoint(x: 0.5, y: 0.5))
            case "anchorPointZ": return Value(CGFloat.zero)
            case "transform": return Value(CATransform3D.identity)
            case "isHidden": return Value(false)
            case "mask": return nil
            case "masksToBounds": return Value(false)
            case "backgroundColor": return nil
            case "cornerRadius": return Value(CGFloat.zero)
            case "maskedCorners": return Value(CACornerMask.allCorners)
            case "borderWidth": return Value(CGFloat.zero)
            case "borderColor": return nil
            case "opacity": return Value(CGFloat(1.0))
            case "shadowColor": return CGColor.black
            case "shadowOpacity": return Value(CGFloat.zero)
            case "shadowOffset": return Value(CGSize(width: 0.0, height: -3.0))
            case "shadowRadius": return Value(CGFloat(3.0))
            case "shadowPath": return nil

            default: return super.defaultValue(forKey: key)
        }
    }

    open override func setValue(_ value: Any?, forKey key: String) {
        let action: CAAction?

        if isPresentation {
            action = nil
        } else {
            action = self.action(forKey: key)
        }

        super.setValue(value, forKey: key)

        action?.run(forKey: key, object: self, arguments: [:])
    }

    open override func setValue(_ value: Any?, forKeyPath keyPath: String) {
        super.setValue(value, forKeyPath: keyPath)
    }

    open override func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
    }

    open override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
    }

    // MARK: - Actions

    open class func defaultAction(forKey event: String) -> CAAction? {
        return nil
    }

    open func action(forKey key: String) -> CAAction? {
        if let delegate = delegate as? CALayerActionDelegate, let action = delegate.action(for: self, forKey: key) {
            return dropNSNull(action)
        } else if let action = actions?[key] {
            return dropNSNull(action)
        } else if let action = type(of: self).defaultAction(forKey: key) {
            return dropNSNull(action)
        } else {
            return nil
        }
    }

    // MARK: - Animations

    open func add(_ animation: CAAnimation, forKey key: String?) {
        if isPresentation {
            return
        }

        let adjustedKey = key as AnyHashable? ?? animation.fallbackAnimationKey as AnyHashable
        animations[adjustedKey] = animation
    }

    open func removeAnimation(forKey key: String) {
        if isPresentation {
            return
        }

        animations[key] = nil
    }

    open func animation(forKey key: String) -> CAAnimation? {
        return animations[key]
    }

    open func removeAllAnimations() {
    }

    open func animationKeys() -> [AnyHashable]? {
        return Array(animations.keys)
    }
}

@_spi(AppKid) extension CALayer: Identifiable {}

public struct CACornerMask: OptionSet {
    public typealias RawValue = UInt
    public var rawValue: RawValue

    public init() {
        self = []
    }

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public static var layerMinXMinYCorner: CACornerMask = CACornerMask(rawValue: 1 << 0)

    public static var layerMaxXMinYCorner: CACornerMask = CACornerMask(rawValue: 1 << 1)

    public static var layerMinXMaxYCorner: CACornerMask = CACornerMask(rawValue: 1 << 2)

    public static var layerMaxXMaxYCorner: CACornerMask = CACornerMask(rawValue: 1 << 3)

    public static var allCorners: CACornerMask = [layerMinXMinYCorner, layerMaxXMinYCorner, layerMinXMaxYCorner, layerMaxXMaxYCorner]
}

extension CACornerMask: PublicInitializable {}

@_transparent
internal func dropNSNull(_ action: CAAction) -> CAAction? {
    action is NSNull ? nil : action
}

// extension CALayer: Equatable {
//     public static func == (lhs: CALayer, rhs: CALayer) -> Bool {
//         // smumriak:TODO:this is wrong, but will do for now. Change to checking the variables OR the dictionary of variables
//         return lhs === rhs
//     }
// }
