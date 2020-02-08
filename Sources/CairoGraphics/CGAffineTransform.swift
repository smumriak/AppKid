//
//  CGAffineTransform.swift
//  AppKid
//
//  Created by Serhii Mumriak on 7/2/20.
//

import CCairo
import Foundation

public struct CGAffineTransform {
    fileprivate var matrix = cairo_matrix_t()
    
    public init() {}
    
    var a: CGFloat {
        get { return CGFloat(matrix.xx) }
        set { matrix.xx = Double(newValue) }
    }
    var b: CGFloat {
        get { return CGFloat(matrix.xy) }
        set { matrix.xy = Double(newValue) }
    }
    var c: CGFloat {
        get { return CGFloat(matrix.yx) }
        set { matrix.yx = Double(newValue) }
    }
    var d: CGFloat {
        get { return CGFloat(matrix.yy) }
        set { matrix.yy = Double(newValue) }
    }
    var tx: CGFloat {
        get { return  CGFloat(matrix.x0) }
        set { matrix.x0 = Double(newValue) }
    }
    var ty: CGFloat {
        get { return CGFloat(matrix.y0) }
        set { matrix.y0 = Double(newValue) }
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
        return lhs.matrix == rhs.matrix
    }
}

extension CGAffineTransform {
    public static var identity: CGAffineTransform = {
        var result = CGAffineTransform()
        cairo_matrix_init_identity(&result.matrix)
        return result
    }()
}

extension CGAffineTransform {
    public init(translationX tx: CGFloat, y ty: CGFloat) {
        cairo_matrix_init_translate(&matrix, Double(tx), Double(ty))
    }
    
    public init(scaleX sx: CGFloat, y sy: CGFloat) {
        cairo_matrix_init_scale(&matrix, Double(sx), Double(sy))
    }
    
    public init(rotationAngle angle: CGFloat) {
        cairo_matrix_init_rotate(&matrix, Double(angle))
    }
    
    var isIdentity: Bool {
        return self == .identity
    }
    
    public func translatedBy(x tx: CGFloat, y ty: CGFloat) -> CGAffineTransform {
        var result = self
        
        cairo_matrix_translate(&result.matrix, Double(tx), Double(ty))
        
        return result
    }
    
    public func scaledBy(x sx: CGFloat, y sy: CGFloat) -> CGAffineTransform {
        var result = self
        
        cairo_matrix_scale(&result.matrix, Double(sx), Double(sy))
        
        return result
    }
    
    public func rotated(by angle: CGFloat) -> CGAffineTransform {
        var result = self
        
        cairo_matrix_rotate(&result.matrix, Double(angle))
        
        return result
    }
    
    public func inverted() -> CGAffineTransform {
        var result = self
        
        let success = cairo_matrix_invert(&result.matrix)
        
        if (success == CAIRO_STATUS_INVALID_MATRIX) {
            return self
        } else {
            return result
        }
    }
    
    public func concatenating(_ t2: CGAffineTransform) -> CGAffineTransform {
        var result = CGAffineTransform()
        var lhs = matrix
        var rhs = t2.matrix
        
        cairo_matrix_multiply(&result.matrix, &lhs, &rhs)
        
        return result
    }
}

public extension CGPoint {
    func applying(_ t: CGAffineTransform) -> CGPoint {
        var x: Double = 0.0
        var y: Double = 0.0
        var transform = t
        
        cairo_matrix_transform_point(&transform.matrix, &x, &y)
        
        return CGPoint(x: x, y: y)
    }
}

public extension CGSize {
    func applying(_ t: CGAffineTransform) -> CGSize {
        var width: Double = 0.0
        var height: Double = 0.0
        var transform = t
        
        cairo_matrix_transform_distance(&transform.matrix, &width, &height)
        
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
