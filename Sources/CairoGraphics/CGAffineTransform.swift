//
//  CGAffineTransform.swift
//  AppKid
//
//  Created by Serhii Mumriak on 7/2/20.
//

import CCairo
import Foundation

public struct CGAffineTransform {
    internal fileprivate(set) var _matrix = cairo_matrix_t()
    
    public init() {}
    
    internal init(matrix: cairo_matrix_t) {
        _matrix = matrix
    }
    
    var a: CGFloat {
        get { return CGFloat(_matrix.xx) }
        set { _matrix.xx = Double(newValue) }
    }
    var b: CGFloat {
        get { return CGFloat(_matrix.xy) }
        set { _matrix.xy = Double(newValue) }
    }
    var c: CGFloat {
        get { return CGFloat(_matrix.yx) }
        set { _matrix.yx = Double(newValue) }
    }
    var d: CGFloat {
        get { return CGFloat(_matrix.yy) }
        set { _matrix.yy = Double(newValue) }
    }
    var tx: CGFloat {
        get { return  CGFloat(_matrix.x0) }
        set { _matrix.x0 = Double(newValue) }
    }
    var ty: CGFloat {
        get { return CGFloat(_matrix.y0) }
        set { _matrix.y0 = Double(newValue) }
    }
}

fileprivate extension cairo_matrix_t {
    static func == (lhs: cairo_matrix_t, rhs: cairo_matrix_t) -> Bool {
        return lhs.xx == rhs.xx &&
        lhs.xy == rhs.xy &&
        lhs.yx == rhs.yx &&
        lhs.yy == rhs.yy &&
        lhs.x0 == rhs.x0 &&
        lhs.y0 == rhs.y0
    }
}

extension CGAffineTransform: Equatable {
    public static func == (lhs: CGAffineTransform, rhs: CGAffineTransform) -> Bool {
        return lhs._matrix == rhs._matrix
    }
}

extension CGAffineTransform {
    public static var identity: CGAffineTransform = {
        var result = CGAffineTransform()
        cairo_matrix_init_identity(&result._matrix)
        return result
    }()
}

extension CGAffineTransform {
    public init(translationX tx: CGFloat, y ty: CGFloat) {
        cairo_matrix_init_translate(&_matrix, Double(tx), Double(ty))
    }
    
    public init(scaleX sx: CGFloat, y sy: CGFloat) {
        cairo_matrix_init_scale(&_matrix, Double(sx), Double(sy))
    }
    
    public init(rotationAngle angle: CGFloat) {
        cairo_matrix_init_rotate(&_matrix, Double(angle))
    }
    
    var isIdentity: Bool {
        return self == .identity
    }
    
    public func translatedBy(x tx: CGFloat, y ty: CGFloat) -> CGAffineTransform {
        var result = self
        
        cairo_matrix_translate(&result._matrix, Double(tx), Double(ty))
        
        return result
    }
    
    public func scaledBy(x sx: CGFloat, y sy: CGFloat) -> CGAffineTransform {
        var result = self
        
        cairo_matrix_scale(&result._matrix, Double(sx), Double(sy))
        
        return result
    }
    
    public func rotated(by angle: CGFloat) -> CGAffineTransform {
        var result = self
        
        cairo_matrix_rotate(&result._matrix, Double(angle))
        
        return result
    }
    
    public func inverted() -> CGAffineTransform {
        if self.isIdentity { return self}
        
        var result = self
        
        let success = cairo_matrix_invert(&result._matrix)
        
        if (success == CAIRO_STATUS_INVALID_MATRIX) {
            return self
        } else {
            return result
        }
    }
    
    public func concatenating(_ t2: CGAffineTransform) -> CGAffineTransform {
        var result = self
        var lhs = _matrix
        var rhs = t2._matrix
        
        cairo_matrix_multiply(&result._matrix, &lhs, &rhs)
        
        return result
    }
}

public extension CGPoint {
    func applying(_ t: CGAffineTransform) -> CGPoint {
        var x = Double(self.x)
        var y = Double(self.y)
        var transform = t
        
        cairo_matrix_transform_point(&transform._matrix, &x, &y)
        
        return CGPoint(x: x, y: y)
    }
}

public extension CGSize {
    func applying(_ t: CGAffineTransform) -> CGSize {
        var width = Double(self.width)
        var height = Double(self.height)
        var transform = t
        
        cairo_matrix_transform_distance(&transform._matrix, &width, &height)
        
        return CGSize(width: width, height: height)
    }
}

public extension CGRect {
    func applying(_ t: CGAffineTransform) -> CGRect {
        let topLeft = CGPoint(x: minX, y: minY).applying(t)
        let topRight = CGPoint(x: maxX, y: minY).applying(t)
        let bottomLeft = CGPoint(x: minX, y: maxY).applying(t)
        let bottomRight = CGPoint(x: maxX, y: maxY).applying(t)
        
        let origin = CGPoint(x: min(topLeft.x, topRight.x, bottomLeft.x, bottomRight.x),
                             y: min(topLeft.y, topRight.y, bottomLeft.y, bottomRight.y))
        let size = CGSize(width: max(topLeft.x, topRight.x, bottomLeft.x, bottomRight.x) - origin.x,
                          height: max(topLeft.y, topRight.y, bottomLeft.y, bottomRight.y) - origin.y)
        
        return CGRect(origin: origin, size: size)
    }
}
