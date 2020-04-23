//
//  View.swift
//  AppKid
//
//  Created by Serhii Mumriak on 07.02.2020.
//

import Foundation
import CairoGraphics

open class View: Responder {
    open var tag: UInt = 0
    internal weak var viewDelegate: ViewController? = nil

    // MARK: Geometry
    fileprivate var _bounds: CGRect {
        didSet {
            invalidateTransforms()
            setNeedsLayout()
        }
    }
    fileprivate var _center: CGPoint {
        didSet {
            invalidateTransforms()
        }
    }
    
    open var frame: CGRect {
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

            setNeedsLayout()
        }
    }
    
    open var bounds: CGRect {
        get {
            return _bounds
        }
        set {
            _bounds = newValue
        }
    }
    
    open var center: CGPoint {
        get {
            return _center
        }
        set {
            _center = newValue
        }
    }

    open var transform: CairoGraphics.CGAffineTransform = .identity {
        didSet {
            invalidateTransforms()
        }
    }

    fileprivate var _transformToWindow: CairoGraphics.CGAffineTransform = .identity
    internal var transformToWindow: CairoGraphics.CGAffineTransform {
        rebuildTransformsIfNeeded()
        return _transformToWindow
    }
    fileprivate var _transformFromWindow: CairoGraphics.CGAffineTransform = .identity
    internal var transformFromWindow: CairoGraphics.CGAffineTransform {
        rebuildTransformsIfNeeded()
        return _transformFromWindow
    }
    internal var transformsAreValid = false

    open var masksToBounds = true
    open var cornerRaidus: CGFloat = 0.0
    open var anchorPoint = CGPoint(x: 0.5, y: 0.5)

    // MARK: View Hierarchy
    
    open internal(set) weak var superview: View? = nil
    open internal(set) var subviews = [View]()
    open internal(set) weak var window: Window? = nil
    
    internal var dirtyRect: CGRect? {
        didSet {
            if let dirtyRect = dirtyRect {
                superview?.setNeedsDisplay(in: convert(dirtyRect, to: superview))
            }
        }
    }

    // MARK: Layout
    open var needsLayout = false

    open func setNeedsLayout() {
        needsLayout = true
    }

    open func layoutIfNeeded() {
        if needsLayout {
            viewDelegate?.viewWillLayoutSubviews()

            layoutSubviews()

            viewDelegate?.viewDidLayoutSubviews()
        }
    }

    open func layoutSubviews() {}


    open var hidden = false
    open var alpha: CGFloat = 1.0
    open var userInteractionEnabled = true

    open var backgroundColor: CairoGraphics.CGColor = .white

    // MARK: Init
    
    public init(with frame: CGRect) {
        _bounds = CGRect(origin: .zero, size: frame.size)
        _center = CGPoint(x: frame.midX, y: frame.midY)
        
        super.init()
    }

    // MARK: View Hierarchy Manipulation

    open func add(subview: View) {
        insert(subview: subview, at: subviews.count)
    }
    
    open func insert(subview: View, at index: Array<View>.Index) {
        subview.removeFromSuperView()

        subview.traverseSubviews(includingSelf: true) {
            $0.willMove(toWindow: window)
        }
        subview.willMove(toSuperview: self)
        
        subviews.insert(subview, at: index)
        subview.superview = self

        subview.didMoveToSuperview()

        subview.traverseSubviews(includingSelf: true) {
            $0.window = window
            $0.invalidateTransforms()
            $0.didMoveToWindow()
        }

        didAddSubview(subview)
    }
    
    open func removeFromSuperView() {
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

    // MARK: Geometry conversion
    
    open func convert(_ point: CGPoint, to view: View?) -> CGPoint {
        let toView = view ?? window
        
        let transformFromWindow = toView?.transformFromWindow ?? .identity
        
        return point.applying(transformToWindow).applying(transformFromWindow)
    }
    
    open func convert(_ point: CGPoint, from view: View?) -> CGPoint {
        let fromView = view ?? window
        
        let transformToWindow = fromView?.transformToWindow ?? .identity
        
        return point.applying(transformToWindow).applying(transformFromWindow)
    }
    
    open func convert(_ rect: CGRect, to view: View?) -> CGRect {
        return rect
    }
    
    open func convert(_ rect: CGRect, from view: View?) -> CGRect {
        return rect
    }

    // MARK: Rendering

    open func render(in context: CairoGraphics.CGContext) {
        context.fillColor = backgroundColor

        context.fill(bounds)
    }
    
    open func setNeedsDisplay() {
        setNeedsDisplay(in: bounds)
    }
    
    open func setNeedsDisplay(in rect: CGRect) {
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

    // MARK: Hit Test
    
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

    // MARK: Responder

    internal override func responderWindow() -> Window? {
        return window
    }

    open override var nextResponder: Responder? {
        return viewDelegate ?? superview ?? super.nextResponder
    }
}

// MARK: Equatable

public extension View {
    static func == (lhs: View, rhs: View) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
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
