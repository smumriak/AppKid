//
//  CGAffineTransform.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 07.02.2020.
//

import Foundation
import CCairo

public struct CGAffineTransform {
    public var a: CGFloat
    public var b: CGFloat
    public var c: CGFloat
    public var d: CGFloat
    public var tx: CGFloat
    public var ty: CGFloat

    internal fileprivate(set) var _matrix: cairo_matrix_t {
        get {
            cairo_matrix_t(xx: Double(a), yx: Double(b),
                           xy: Double(c), yy: Double(d),
                           x0: Double(tx), y0: Double(ty))
        }
        set {
            a = CGFloat(newValue.xx)
            b = CGFloat(newValue.yx)
            c = CGFloat(newValue.xy)
            d = CGFloat(newValue.yy)
            tx = CGFloat(newValue.x0)
            ty = CGFloat(newValue.y0)
        }
    }

    internal init(matrix: cairo_matrix_t) {
        a = CGFloat(matrix.xx)
        b = CGFloat(matrix.yx)
        c = CGFloat(matrix.xy)
        d = CGFloat(matrix.yy)
        tx = CGFloat(matrix.x0)
        ty = CGFloat(matrix.y0)
    }
}

public extension CGAffineTransform {
    static var identity = CGAffineTransform(a: 1.0, b: 0.0,
                                            c: 0.0, d: 1.0,
                                            tx: 0.0, ty: 0.0)

    static var zero = CGAffineTransform(a: 0.0, b: 0.0,
                                        c: 0.0, d: 0.0,
                                        tx: 0.0, ty: 0.0)
   
    var determinant: CGFloat { a * d - b * c }

    init() {
        self = .identity
    }

    init(a: CGFloat, b: CGFloat, c: CGFloat, d: CGFloat, tx: CGFloat, ty: CGFloat) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
        self.tx = tx
        self.ty = ty
    }

    init(translationX tx: CGFloat, y ty: CGFloat) {
        self.init(a: 1.0, b: 0.0,
                  c: 0.0, d: 1.0,
                  tx: tx, ty: ty)
    }
    
    init(scaleX sx: CGFloat, y sy: CGFloat) {
        self.init(a: sx, b: 0.0,
                  c: 0.0, d: sy,
                  tx: 0.0, ty: 0.0)
    }
    
    init(rotationAngle angle: CGFloat) {
        let sine = sin(angle)
        let cosine = cos(angle)

        self.init(a: cosine, b: sine,
                  c: -sine, d: cosine,
                  tx: 0.0, ty: 0.0)
    }

    var isIdentity: Bool {
        self == .identity
    }
    
    func translatedBy(x tx: CGFloat, y ty: CGFloat) -> CGAffineTransform {
        CGAffineTransform(translationX: tx, y: ty).concatenating(self)
    }
    
    func scaledBy(x sx: CGFloat, y sy: CGFloat) -> CGAffineTransform {
        CGAffineTransform(scaleX: sx, y: sy).concatenating(self)
    }
    
    func rotated(by angle: CGFloat) -> CGAffineTransform {
        CGAffineTransform(rotationAngle: angle).concatenating(self)
    }
    
    func inverted() -> CGAffineTransform {
        if isIdentity { return self }

        let determinant = self.determinant

        if determinant == 0 { return self }

        return CGAffineTransform(a: d / determinant, b: -b / determinant,
                                 c: -c / determinant, d: a / determinant,
                                 tx: (c * ty - d * tx) / determinant, ty: (b * tx - a * ty) / determinant)
    }
    
    func concatenating(_ t2: CGAffineTransform) -> CGAffineTransform {
        CGAffineTransform(
            a: a * t2.a + b * t2.c, b: a * t2.b + b * t2.d,
            c: c * t2.a + d * t2.c, d: c * t2.b + d * t2.d,
            tx: tx * t2.a + ty * t2.c + t2.tx, ty: tx * t2.b + ty * t2.d + t2.ty
        )
    }
}

extension CGAffineTransform: Hashable {
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.a == rhs.a && 
        lhs.b == rhs.b && 
        lhs.c == rhs.c && 
        lhs.d == rhs.d && 
        lhs.tx == rhs.tx && 
        lhs.ty == rhs.ty
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(a)
        hasher.combine(b)
        hasher.combine(c)
        hasher.combine(d)
        hasher.combine(tx)
        hasher.combine(ty)
    }
}

public extension CGPoint {
    func applying(_ t: CGAffineTransform) -> CGPoint {
        CGPoint(x: t.a * x + t.c * y + t.tx,
                y: t.b * x + t.d * y + t.ty)
    }
}

public extension CGSize {
    func applying(_ t: CGAffineTransform) -> CGSize {
        CGSize(width: t.a * width + t.c * height,
               height: t.b * width + t.d * height)
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

extension CGAffineTransform: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        CGAffineTransform
        a: \(a), b: \(b)
        c: \(c), d: \(d)
        tx: \(tx), ty: \(ty)
        """
    }
}
