//
//  CGAffineTransform_cglm_WorkInProgress.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 05.09.2020.
//

import Foundation
import CCairo
import SimpleGLM
import cglm

// public typealias CGAffineTransform = CGAffineTransform_cglm_WorkInProgress;

public struct CGAffineTransform_cglm_WorkInProgress {
    internal fileprivate(set) var matrix: mat3s = .identity
    
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

    public init() {
        self = .identity
    }

    internal init(matrix: mat3s) {
        self.matrix = matrix
    }

    internal init(matrix: cairo_matrix_t) {
        self.matrix = .identity
        _matrix = matrix
    }

    public var a: CGFloat {
        get { CGFloat(matrix.m00) }
        set { matrix.m00 = Float(newValue) }
    }

    public var b: CGFloat {
        get { CGFloat(matrix.m01) }
        set { matrix.m01 = Float(newValue) }
    }

    public var c: CGFloat {
        get { CGFloat(matrix.m10) }
        set { matrix.m10 = Float(newValue) }
    }

    public var d: CGFloat {
        get { CGFloat(matrix.m11) }
        set { matrix.m11 = Float(newValue) }
    }

    public var tx: CGFloat {
        get { CGFloat(matrix.m20) }
        set { matrix.m20 = Float(newValue) }
    }

    public var ty: CGFloat {
        get { CGFloat(matrix.m21) }
        set { matrix.m21 = Float(newValue) }
    }
}

extension CGAffineTransform_cglm_WorkInProgress: Hashable {
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool { lhs.matrix == rhs.matrix }

    public func hash(into hasher: inout Hasher) { hasher.combine(matrix) }
}

public extension CGAffineTransform_cglm_WorkInProgress {
    static let identity = CGAffineTransform_cglm_WorkInProgress(matrix: .identity)
    static let zero = CGAffineTransform_cglm_WorkInProgress(matrix: .zero)

    var isIdentity: Bool { matrix.isIdentity }

    var inversed: Self { CGAffineTransform_cglm_WorkInProgress(matrix: matrix.inversed) }
    mutating func inverse() { matrix.inverse() }
}

public extension CGAffineTransform_cglm_WorkInProgress {
    init(translationX tx: CGFloat, y ty: CGFloat) {
        matrix = mat3s(translationVector: vec2s(tx, ty))
    }
    
    init(scaleX sx: CGFloat, y sy: CGFloat) {
        matrix = mat3s(scaleVector: vec2s(sx, sy))
    }
    
    init(rotationAngle angle: CGFloat) {
        matrix = mat3s(rotationAngle: angle)
    }
    
    func translatedBy(x tx: CGFloat, y ty: CGFloat) -> CGAffineTransform_cglm_WorkInProgress {
        return CGAffineTransform_cglm_WorkInProgress(matrix: matrix.translated(by: vec2s(tx, ty)))
    }
    
    func scaledBy(x sx: CGFloat, y sy: CGFloat) -> CGAffineTransform_cglm_WorkInProgress {
        return CGAffineTransform_cglm_WorkInProgress(matrix: matrix.scaled(by: vec2s(sx, sy)))
    }
    
    func rotated(by angle: CGFloat) -> CGAffineTransform_cglm_WorkInProgress {
        return CGAffineTransform_cglm_WorkInProgress(matrix: matrix.rotated(by: angle))
    }

    // palkovnik:For unknown reason this code crashes swift compiler on raspberry pi
    // func inverted() -> CGAffineTransform_cglm_WorkInProgress {
    //     if isIdentity { return self }

    //     if matrix.determinant == 0 { return self }

    //     return CGAffineTransform_cglm_WorkInProgress(matrix: matrix.inversed)
    // }
    
    func concatenating(_ t2: CGAffineTransform_cglm_WorkInProgress) -> CGAffineTransform_cglm_WorkInProgress {
        var result = CGAffineTransform_cglm_WorkInProgress(matrix: matrix * t2.matrix)
        result.tx = tx * t2.a + ty * t2.c + t2.tx
        result.ty = tx * t2.b + ty * t2.d + t2.ty
        return result
    }
}

public extension CGPoint {
    @inlinable @inline(__always)
    func applying(_ t: CGAffineTransform_cglm_WorkInProgress) -> CGPoint {
        CGPoint(x: (t.a * x) + (t.c * y) + t.tx,
                y: (t.b * x) + (t.d * y) + t.ty)
    }
}

public extension CGSize {
    @inlinable @inline(__always)
    func applying(_ t: CGAffineTransform_cglm_WorkInProgress) -> CGSize {
        CGSize(width: (t.a * width) + (t.c * height),
               height: (t.b * width) + (t.d * height))
    }
}

public extension CGRect {
    func applying(_ t: CGAffineTransform_cglm_WorkInProgress) -> CGRect {
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

extension CGAffineTransform_cglm_WorkInProgress: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        CGAffineTransform
        a: \(a), b: \(b)
        c: \(c), d: \(d)
        tx: \(tx), ty: \(ty)
        """
    }
}
