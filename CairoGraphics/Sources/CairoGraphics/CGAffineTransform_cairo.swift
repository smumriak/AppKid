//
//  CGAffineTransform_cairo.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 07.02.2020.
//

import CCairo
import Foundation
import TinyFoundation

public struct CGAffineTransform_cairo {
    internal fileprivate(set) var _matrix = cairo_matrix_t()
    
    public init() {
        cairo_matrix_init_identity(&_matrix)
    }
    
    internal init(matrix: cairo_matrix_t) {
        _matrix = matrix
    }
    
    public var a: CGFloat {
        get { return CGFloat(_matrix.xx) }
        set { _matrix.xx = Double(newValue) }
    }

    public var b: CGFloat {
        get { return CGFloat(_matrix.yx) }
        set { _matrix.xy = Double(newValue) }
    }

    public var c: CGFloat {
        get { return CGFloat(_matrix.xy) }
        set { _matrix.yx = Double(newValue) }
    }

    public var d: CGFloat {
        get { return CGFloat(_matrix.yy) }
        set { _matrix.yy = Double(newValue) }
    }

    public var tx: CGFloat {
        get { return CGFloat(_matrix.x0) }
        set { _matrix.x0 = Double(newValue) }
    }

    public var ty: CGFloat {
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

extension CGAffineTransform_cairo: Equatable {
    public static func == (lhs: CGAffineTransform_cairo, rhs: CGAffineTransform_cairo) -> Bool {
        return lhs._matrix == rhs._matrix
    }
}

public extension CGAffineTransform_cairo {
    static let identity: CGAffineTransform_cairo = CGAffineTransform_cairo()
}

public extension CGAffineTransform_cairo {
    init(translationX tx: CGFloat, y ty: CGFloat) {
        cairo_matrix_init_translate(&_matrix, Double(tx), Double(ty))
    }
    
    init(scaleX sx: CGFloat, y sy: CGFloat) {
        cairo_matrix_init_scale(&_matrix, Double(sx), Double(sy))
    }
    
    init(rotationAngle angle: CGFloat) {
        cairo_matrix_init_rotate(&_matrix, Double(angle))
    }
    
    var isIdentity: Bool {
        return self == .identity
    }
    
    func translatedBy(x tx: CGFloat, y ty: CGFloat) -> CGAffineTransform_cairo {
        var result = self
        
        cairo_matrix_translate(&result._matrix, Double(tx), Double(ty))

        return result
    }
    
    func scaledBy(x sx: CGFloat, y sy: CGFloat) -> CGAffineTransform_cairo {
        var result = self
        
        cairo_matrix_scale(&result._matrix, Double(sx), Double(sy))
        
        return result
    }
    
    func rotated(by angle: CGFloat) -> CGAffineTransform_cairo {
        var result = self
        
        cairo_matrix_rotate(&result._matrix, Double(angle))
        
        return result
    }
    
    func inverted() -> CGAffineTransform_cairo {
        if self.isIdentity { return self }
        
        var result = self
        
        let success = cairo_matrix_invert(&result._matrix)
        
        if success == CAIRO_STATUS_INVALID_MATRIX {
            return self
        } else {
            return result
        }
    }
    
    func concatenating(_ t2: CGAffineTransform_cairo) -> CGAffineTransform_cairo {
        var result = self

        withUnsafeMutablePointer(to: &result._matrix) { result in
            withUnsafePointer(to: self._matrix) { lhs in
                withUnsafePointer(to: t2._matrix) { rhs in
                    cairo_matrix_multiply(result, lhs, rhs)
                }
            }
        }
        
        return result
    }
}

public extension CGPoint {
    func applying(_ t: CGAffineTransform_cairo) -> CGPoint {
        var x = Double(self.x)
        var y = Double(self.y)
        var transform = t
        
        cairo_matrix_transform_point(&transform._matrix, &x, &y)
        
        return CGPoint(x: x, y: y)
    }
}

public extension CGSize {
    func applying(_ t: CGAffineTransform_cairo) -> CGSize {
        var width = Double(self.width)
        var height = Double(self.height)
        var transform = t
        
        cairo_matrix_transform_distance(&transform._matrix, &width, &height)
        
        return CGSize(width: width, height: height)
    }
}

public extension CGRect {
    func applying(_ t: CGAffineTransform_cairo) -> CGRect {
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

extension cairo_matrix_t: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        cairo_matrix_t
        xx: \(xx), xy: \(xy)
        yx: \(yx), yy: \(yy)
        x0: \(x0), y0: \(y0)
        """
    }
}

extension CGAffineTransform_cairo: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        CGAffineTransform
        a: \(a), b: \(b)
        c: \(c), d: \(d)
        tx: \(tx), ty: \(ty)
        """
    }
}
