//
//  View.swift
//  AppKid
//
//  Created by Serhii Mumriak on 7/2/20.
//

import Foundation
import CairoGraphics

open class View: Responder {
    fileprivate var _frame: CGRect
    fileprivate var _bounds: CGRect
    
    public var frame: CGRect {
        get {
            return _frame
        }
        set {
            _frame = newValue
            _bounds.size = newValue.size
        }
    }
    public var bounds: CGRect {
        get {
            return _bounds
        }
        set {
            _bounds = newValue
            _frame.size = newValue.size
        }
    }
    public var center: CGPoint {
        get {
            return CGPoint(x: frame.midX, y: frame.midY)
        }
    }
    
    public internal(set) weak var superview: View? = nil
    public internal(set) var subviews = [View]()
    public internal(set) weak var window: Window? = nil
    
    public var needsDisplay = false
    public var needsLayout = false
    public var hidden = false
    public var alpha: CGFloat = 1.0
    public var userInteractionEnabled = true
    public var transform: CairoGraphics.CGAffineTransform = .identity
    
    public init(with frame: CGRect) {
        _frame = frame
        _bounds = CGRect(origin: .zero, size: frame.size)
        
        super.init()
    }
    
    public func add(_ subview: View) {
        insert(subview, at: subviews.count)
    }
    
    public func insert(_ subview: View, at index: Array<View>.Index) {
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
    
    public func convert(_ point: CGPoint, from view: View?) -> CGPoint {
        return point
    }
    
    public func convert(_ point: CGPoint, to view: View?) -> CGPoint {
//        if window == nil {
//            fatalError("Converting points in invalid conditions")
//        }
//
//        let interestedView = view ?? window!
//
//        if window != interestedView.window || window == nil || interestedView.window == nil{
//            fatalError("Converting points in invalid conditions")
//        }
//
//        if self == interestedView.superview {
//            return point - interestedView.frame.origin
//        } else if interestedView == self.superview {
//            return point + frame.origin
//        } else {
//
//        }
//
        return point
    }
    
    public func convert(_ rect: CGRect, from view: View?) -> CGRect {
        return rect
    }

    public func convert(_ rect: CGRect, to view: View?) -> CGRect {
        return rect
    }
    
    public func display() {}
    
    public func displayIfNeeded() {
        if needsDisplay {
            display()
            needsDisplay = false
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
