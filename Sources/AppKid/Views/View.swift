//
//  View.swift
//  AppKid
//
//  Created by Serhii Mumriak on 7/2/20.
//

import Foundation
import CairoGraphics

open class View: Responder {
    fileprivate var _bounds: CGRect
    fileprivate var _center: CGPoint
    
    public var frame: CGRect {
        get {
            let transform = CairoGraphics.CGAffineTransform.identity
                .translatedBy(x: _bounds.midX, y: _bounds.midY)
                .concatenating(self.transform)
                .translatedBy(x: -_bounds.midX, y: -_bounds.midY)
            
            var result = _bounds.applying(transform)
            result.origin.x = center.x - result.width / 2.0
            result.origin.y = center.y - result.height / 2.0
            
            return result
        }
        set {
            // palkovnik:TODO: Implement inverse setting of origin and bounds from frame. also transforms can break things
//            let transformedFrame = newValue.applying(transform.inverted())
            let transformedFrame = newValue
            _bounds.size = transformedFrame.size
            _center = CGPoint(x: transformedFrame.midX, y: transformedFrame.midY)
        }
    }
    
    public var bounds: CGRect {
        get {
            return _bounds
        }
        set {
            _bounds = newValue
        }
    }
    
    public var center: CGPoint {
        get {
            return _center
        }
        set {
            _center = newValue
        }
    }
    
    public var anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    public internal(set) weak var superview: View? = nil
    public internal(set) var subviews = [View]()
    public internal(set) weak var window: Window? = nil
    
    internal var dirtyRect: CGRect? {
        didSet {
            if let dirtyRect = dirtyRect {
                superview?.setNeedsDisplay(in: convert(dirtyRect, to: superview))
            }
        }
    }
    public var needsLayout = false
    public var hidden = false
    public var alpha: CGFloat = 1.0
    public var userInteractionEnabled = true
    public var transform: CairoGraphics.CGAffineTransform = .identity {
        didSet {
            invalidateTransforms()
        }
    }
    public var backgroundColor: CairoGraphics.CGColor = .white
    
    internal var _transformToWindow: CairoGraphics.CGAffineTransform = .identity
    internal var transformToWindow: CairoGraphics.CGAffineTransform {
        rebuildTransformsIfNeeded()
        return _transformToWindow
    }
    internal var _transformFromWindow: CairoGraphics.CGAffineTransform = .identity
    internal var transformFromWindow: CairoGraphics.CGAffineTransform {
        rebuildTransformsIfNeeded()
        return _transformFromWindow
    }
    internal var transformsAreValid = false
    
    public init(with frame: CGRect) {
        _bounds = CGRect(origin: .zero, size: frame.size)
        _center = CGPoint(x: frame.midX, y: frame.midY)
        
        super.init()
    }
    
    public func add(subview: View) {
        insert(subview: subview, at: subviews.count)
    }
    
    public func insert(subview: View, at index: Array<View>.Index) {
        subview.removeFromSuperView()
        
        subview.willMove(toWindow: window)
        subview.willMove(toSuperview: self)
        
        subviews.insert(subview, at: index)
        subview.superview = self
        subview.window = window
        
        subview.didMoveToSuperview()
        subview.didMoveToWindow()
        
        didAddSubview(subview)
    }
    
    public func removeFromSuperView() {
        guard let superview = superview else { return }
        
        superview.willRemoveSubview(self)
        
        willMove(toWindow: nil)
        willMove(toSuperview: nil)
        if let index = superview.subviews.firstIndex(of: self) {
            superview.subviews.remove(at: index)
        }
        didMoveToSuperview()
        didMoveToWindow()
    }
    
    public func didAddSubview(_ subview: View) {
        subview.nextResponder = self
    }
    
    public func willRemoveSubview(_ subview: View) {
        subview.nextResponder = nil
    }
    
    public func willMove(toSuperview superview: View?) {}
    
    public func didMoveToSuperview() {}
    
    public func willMove(toWindow window: Window?) {}
    
    public func didMoveToWindow() {}
    
    internal func rebuildTransformsIfNeeded() {
        if transformsAreValid { return }
        
        transformsAreValid = true
        
        if window == nil && superview == nil {
            _transformToWindow = .identity
            _transformFromWindow = .identity
        } else {
            let superviewTransformToWindow = superview?.transformToWindow ?? .identity
            // palkovnik:TODO: don't forget to add bounds transform
//            let boundsScaleTransform = CGAffineTransform.init(scaleX: frame.width / bounds.width, y: frame.height / bounds.height)
            
            _transformToWindow =
                CairoGraphics.CGAffineTransform.identity
                    .concatenating(CGAffineTransform(translationX: -self.bounds.width / 2.0, y: -self.bounds.height / 2.0))
                    .concatenating(self.transform)
                    .concatenating(CGAffineTransform(translationX: self.bounds.width / 2.0, y: self.bounds.height / 2.0))
                    .concatenating(CGAffineTransform(translationX: center.x - bounds.width / 2.0, y: center.y - bounds.height / 2.0))
                    .concatenating(superviewTransformToWindow)
            
            _transformFromWindow = _transformToWindow.inverted()
        }
    }
    
    internal func invalidateTransforms() {
        transformsAreValid = false
        for view in subviews {
            view.invalidateTransforms()
        }
    }
    
    public func convert(_ point: CGPoint, to view: View?) -> CGPoint {
        let toView = view ?? window
        
        let transformFromWindow = toView?.transformFromWindow ?? .identity
        
        return point.applying(transformToWindow).applying(transformFromWindow)
    }
    
    public func convert(_ point: CGPoint, from view: View?) -> CGPoint {
        let fromView = view ?? window
        
        let transformToWindow = fromView?.transformToWindow ?? .identity
        
        return point.applying(transformToWindow).applying(transformFromWindow)
    }
    
    public func convert(_ rect: CGRect, to view: View?) -> CGRect {
        return rect
    }
    
    public func convert(_ rect: CGRect, from view: View?) -> CGRect {
        return rect
    }

    public func render(in context: CairoGraphics.CGContext) {
        context.setFillColor(backgroundColor)
        var displayRect = bounds
        displayRect.origin.x = -bounds.width * 0.5
        displayRect.origin.y = -bounds.height * 0.5
        context.fill(displayRect)

        context.setFillColor(.black)
        displayRect.size = CGSize(width: 10.0, height: 10.0)
        context.fill(displayRect)
    }
    
    public func setNeedsDisplay() {
        setNeedsDisplay(in: bounds)
    }
    
    public func setNeedsDisplay(in rect: CGRect) {
        if let dirtyRect = dirtyRect {
            let minX = min(dirtyRect.minX, rect.minX)
            let minY = min(dirtyRect.minY, rect.minY)
            let maxX = max(dirtyRect.maxX, rect.maxX)
            let maxY = max(dirtyRect.maxY, rect.maxY)
            self.dirtyRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        } else {
            dirtyRect = rect
        }
    }
    
    open func hitTest(_ point: CGPoint) -> View? {
        var interestPoint = point
        var result: View = self
        var found = false

        repeat {
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
                    }
                }
            } else {
                found = true
            }
        } while !found
        
        return result
    }
    
    open func point(inside point: CGPoint) -> Bool {
        return bounds.contains(point)
    }
}

extension View: Equatable {
    public static func == (lhs: View, rhs: View) -> Bool {
        return lhs === rhs
    }
}

fileprivate extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}
