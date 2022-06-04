//
//  View.swift
//  AppKid
//
//  Created by Serhii Mumriak on 07.02.2020.
//

import Foundation
import CairoGraphics
@_spi(AppKid) import ContentAnimation

#if os(macOS)
    import struct CairoGraphics.CGAffineTransform
    import struct CairoGraphics.CGColor
    import class CairoGraphics.CGContext
#endif

open class View: Responder, CALayerActionDelegate {
    open var tag: UInt = 0
    internal weak var viewDelegate: ViewController? = nil

    public var layer: CALayer

    // MARK: - Geometry
    
    open var frame: CGRect {
        get {
            let size = bounds.applying(transform).standardized.size
            let origin = CGPoint(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
            
            return CGRect(origin: origin, size: size)
        }
        set {
            let size = newValue.size.applying(transform.inverted())

            bounds = CGRect(origin: bounds.origin, size: size)
            center = CGPoint(x: newValue.midX, y: newValue.midY)
        }
    }
    
    open var bounds: CGRect {
        get {
            return layer.bounds
        }
        set {
            layer.bounds = newValue

            invalidateTransforms()
            setNeedsLayout()
        }
    }
    
    open var center: CGPoint {
        get {
            return layer.position
        }
        set {
            layer.position = newValue

            invalidateTransforms()
        }
    }

    open var transform: CGAffineTransform = .identity {
        didSet {
            layer.affineTransform = transform
            
            invalidateTransforms()
        }
    }

    var contentScaleFactor: CGFloat {
        get {
            return layer.contentsScale
        }
        set {
            layer.contentsScale = newValue
        }
    }

    fileprivate var _transformToWindow: CGAffineTransform = .identity
    internal var transformToWindow: CGAffineTransform {
        rebuildTransformsIfNeeded()
        return _transformToWindow
    }

    fileprivate var _transformFromWindow: CGAffineTransform = .identity
    internal var transformFromWindow: CGAffineTransform {
        rebuildTransformsIfNeeded()
        return _transformFromWindow
    }

    internal var transformsAreValid = false

    open var masksToBounds: Bool {
        get { layer.masksToBounds }
        set { layer.masksToBounds = newValue }
    }

    open var cornerRaidus: CGFloat = 0.0
    open var anchorPoint = CGPoint(x: 0.5, y: 0.5)

    // MARK: - View Hierarchy
    
    open internal(set) weak var superview: View? = nil
    open internal(set) var subviews = [View]()
    open internal(set) weak var window: Window? = nil {
        didSet {
            // smumriak: Here? Maybe not. I don't know
            if let window = window {
                contentScaleFactor = window.contentScaleFactor
            }
        }
    }
    
    internal var dirtyRect: CGRect?

    // MARK: - Layout

    open var needsLayout = false
    open var autoresizingMaks: AutoresizingMask = .none
    open var autoresizesSubviews = true

    open func setNeedsLayout() {
        needsLayout = true
    }

    open func layoutIfNeeded() {
        if needsLayout {
            viewDelegate?.viewWillLayoutSubviews()

            layoutSubviews()

            needsLayout = false

            viewDelegate?.viewDidLayoutSubviews()
        }
    }

    open func layoutSubviews() {
        layoutBelowIfNeeeded()
    }

    internal func layoutBelowIfNeeeded() {
    }

    open var hidden = false
    open var alpha: CGFloat = 1.0
    open var userInteractionEnabled = true

    open var backgroundColor: CGColor {
        get {
            layer.backgroundColor ?? .white
        }
        set {
            layer.backgroundColor = newValue
        }
    }
    
    // MARK: - Init
    
    public init(with frame: CGRect) {
        layer = CALayer()
        layer.bounds = CGRect(origin: .zero, size: frame.size)
        layer.position = CGPoint(x: frame.midX, y: frame.midY)
        layer.backgroundColor = .white
        layer.masksToBounds = true

        super.init()

        layer.delegate = self
    }

    // MARK: - View Hierarchy Manipulation

    open func add(subview: View) {
        insert(subview: subview, at: subviews.count)
    }
    
    open func insert(subview: View, at index: Array<View>.Index) {
        if subview.superview == self {
            return
        }
        
        subview.removeFromSuperview()

        subview.traverseSubviews(includingSelf: true) {
            $0.willMove(toWindow: window)
        }
        subview.willMove(toSuperview: self)
        
        subviews.insert(subview, at: index)
        subview.superview = self

        layer.insertSublayer(subview.layer, at: UInt32(index))

        subview.didMoveToSuperview()

        subview.traverseSubviews(includingSelf: true) {
            $0.window = window
            $0.invalidateTransforms()
            $0.didMoveToWindow()
        }

        didAddSubview(subview)
    }
    
    open func removeFromSuperview() {
        guard let superview = superview else { return }
        
        superview.willRemoveSubview(self)
        
        traverseSubviews(includingSelf: true) {
            $0.willMove(toWindow: nil)
        }

        willMove(toSuperview: nil)
        if let index = superview.subviews.firstIndex(of: self) {
            superview.subviews.remove(at: index)
        }
        self.superview = nil
        
        layer.removeFromSuperlayer()

        didMoveToSuperview()

        traverseSubviews(includingSelf: true) {
            $0.window = nil
            $0.invalidateTransforms()
            $0.didMoveToWindow()
        }
    }
    
    open func didAddSubview(_ subview: View) {}
    open func willRemoveSubview(_ subview: View) {}
    open func willMove(toSuperview superview: View?) {}
    open func didMoveToSuperview() {}
    open func willMove(toWindow window: Window?) {}
    open func didMoveToWindow() {}
    
    internal func rebuildTransformsIfNeeded() {
        if transformsAreValid { return }
        
        transformsAreValid = true
        
        if window == nil && superview == nil {
            _transformToWindow = .identity
            _transformFromWindow = .identity
        } else {
            let superviewTransformToWindow = superview?.transformToWindow ?? .identity

            _transformToWindow = CGAffineTransform.identity
                .concatenating(CGAffineTransform(translationX: -bounds.minX, y: -bounds.minY))
                .concatenating(CGAffineTransform(translationX: -bounds.width * 0.5, y: -bounds.height * 0.5))
                .concatenating(transform)
                .concatenating(CGAffineTransform(translationX: bounds.width * 0.5, y: bounds.height * 0.5))
                .concatenating(CGAffineTransform(translationX: center.x - bounds.width * 0.5, y: center.y - bounds.height * 0.5))
                .concatenating(superviewTransformToWindow)
            
            _transformFromWindow = _transformToWindow.inverted()
        }
    }
    
    internal func invalidateTransforms() {
        layer.invalidateTransforms()

        transformsAreValid = false
        for view in subviews {
            view.invalidateTransforms()
        }
    }

    // MARK: - Geometry conversion
    
    open func convert(_ point: CGPoint, to view: View?) -> CGPoint {
        if let view = view {
            assert(window == view.window)
        }
        
        let toView = view ?? window
        
        let transformFromWindow = toView?.transformFromWindow ?? .identity
        
        return point.applying(transformToWindow).applying(transformFromWindow)
    }
    
    open func convert(_ point: CGPoint, from view: View?) -> CGPoint {
        if let view = view {
            assert(window == view.window)
        }
        
        let fromView = view ?? window
        
        let transformToWindow = fromView?.transformToWindow ?? .identity
        
        return point.applying(transformToWindow).applying(transformFromWindow)
    }
    
    open func convert(_ rect: CGRect, to view: View?) -> CGRect {
        if let view = view {
            assert(window == view.window)
        }
        
        let toView = view ?? window

        let transformFromWindow = toView?.transformFromWindow ?? .identity

        return rect.applying(transformToWindow).applying(transformFromWindow)
    }
    
    open func convert(_ rect: CGRect, from view: View?) -> CGRect {
        if let view = view {
            assert(window == view.window)
        }
        
        let fromView = view ?? window

        let transformToWindow = fromView?.transformToWindow ?? .identity

        return rect.applying(transformToWindow).applying(transformFromWindow)
    }

    // MARK: - Rendering

    open func render(in context: CGContext) {
        context.fillColor = backgroundColor

        context.fill(bounds)
    }
    
    open func setNeedsDisplay() {
        setNeedsDisplay(in: bounds)
    }
    
    open func setNeedsDisplay(in rect: CGRect) {
        dirtyRect = dirtyRect?.union(rect) ?? rect
        layer.setNeedsDisplay()
    }

    // MARK: - Hit Test
    
    open func hitTest(_ point: CGPoint) -> View? {
        var interestPoint = point

        if self.point(inside: interestPoint) == false {
            return nil
        }

        var result: View = self
        var found = false

        traverse: repeat {
            let reversedSubviews = result.subviews.reversed()

            if reversedSubviews.count > 0 {
                for subview in reversedSubviews {
                    if !subview.userInteractionEnabled || subview.hidden || subview.alpha < 0.01 {
                        continue
                    }

                    let convertedPoint = result.convert(interestPoint, to: subview)

                    if subview.point(inside: convertedPoint) {
                        result = subview
                        interestPoint = convertedPoint

                        continue traverse
                    }
                }

                found = true
            } else {
                found = true
            }
        } while !found

        return result
    }
    
    open func point(inside point: CGPoint) -> Bool {
        return bounds.contains(point)
    }

    internal func traverseSubviews(includingSelf: Bool = false, closure: (_ view: View) -> ()) {
        if includingSelf {
            closure(self)
        }

        subviews.forEach {
            $0.traverseSubviews(includingSelf: true, closure: closure)
        }
    }

    // MARK: - Responder

    internal override func responderWindow() -> Window? {
        return window
    }

    open override var nextResponder: Responder? {
        return viewDelegate ?? superview ?? super.nextResponder
    }

    // MARK: - CALayerDelegate

    public func draw(_ layer: CALayer, in context: CGContext) {
    }
    
    public func layerWillDraw(_ layer: CALayer) {
    }

    public func layoutSublayers(of layer: CALayer) {
    }

    // MARK: - CALayerActionDelegate

    public func action(for layer: CALayer, forKey event: String) -> CAAction? {
        return NSNull()
    }
}

// MARK: - Equatable

public extension View {
    static func == (lhs: View, rhs: View) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}
