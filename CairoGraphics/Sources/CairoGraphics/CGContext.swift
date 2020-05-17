//
//  CGContext.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 03.02.2020.
//

import Foundation
import CCairo
import TinyFoundation

public enum CGPathFillRule: Int {
    case winding
    case evenOdd
}

public enum CGLineCap : Int {
    case butt
    case round
    case square
}

public enum CGLineJoin: Int {
    case miter
    case round
    case bevel
}

open class CGContext {
    internal var _contextPointer: ReferablePointer<cairo_t>
    internal var _context: UnsafeMutablePointer<cairo_t> {
        get {
            return _contextPointer.pointer
        }
        set {
            _contextPointer = ReferablePointer(with: newValue)
        }
    }

    internal var _state = CGContextState()
    internal var _statesStack: [CGContextState] = []
    open internal(set) var size: CGSize

    open var shouldAntialias = false {
        didSet {
            if shouldAntialias {
                cairo_set_antialias(_context, CAIRO_ANTIALIAS_GOOD)
            } else {
                cairo_set_antialias(_context, CAIRO_ANTIALIAS_NONE)
            }
        }
    }
    
    internal init(cairoContext: UnsafeMutablePointer<cairo_t>, size: CGSize) {
        self._contextPointer = ReferablePointer(with: cairoContext)
        self.size = size
        _state.defaultPattern = cairo_get_source(_context)
    }
    
    public init(surface: UnsafeMutablePointer<cairo_surface_t>, size: CGSize) {
        let cairoContext = cairo_create(surface)!
        self._contextPointer = ReferablePointer(with: cairoContext)
        cairoContext.release()
        self.size = size
        _state.defaultPattern = cairo_get_source(_context)
    }
    
    public convenience init(_ context: CGContext) {
        self.init(cairoContext: context._context, size: context.size)
    }
}

public extension CGContext {
    func saveState() {
        _statesStack.append(_state)
        _state = CGContextState()
        cairo_save(_context)
    }
    
    func restoreState() {
        cairo_restore(_context)
        if let state = _statesStack.popLast() {
            _state = state
        } else {
            _state = CGContextState()
        }
    }
}

public extension CGContext {
    func beginPath() {
        cairo_new_path(_context)
    }
    
    func closePath() {
        cairo_close_path(_context)
    }
    
    var isPathEmpty: Bool {
        return boundingBoxOfPath.isNull
    }
    
    var currentPointOfPath: CGPoint {
        var x: Double = .zero
        var y: Double = .zero
        cairo_get_current_point(_context, &x, &y)
        return CGPoint(x: x, y: y)
    }
    
    var boundingBoxOfPath: CGRect {
        var x1: Double = .zero
        var y1: Double = .zero
        var x2: Double = .zero
        var y2: Double = .zero
        
        cairo_path_extents(_context, &x1, &y1, &x2, &y2)
        
        if x1.isZero && y1.isZero && x2.isZero && y2.isZero {
            return .null
        } else {
            return CGRect(x: min(x1, x2), y: min(y1, y2), width: max(x1, x2) - min(x1, x2), height: max(y1, y2) - min(y1, y2))
        }
    }
    
    var path: CGPath? {
        return CGPath(currentPath: _context)
    }
}

public extension CGContext {
    func move(to point: CGPoint) {
        cairo_move_to(_context, Double(point.x), Double(point.y))
    }
    
    func addLine(to point: CGPoint) {
        cairo_line_to(_context, Double(point.x), Double(point.y))
    }
    
    func addRect(_ rect: CGRect) {
        cairo_rectangle(_context, Double(rect.origin.x), Double(rect.origin.y), Double(rect.width), Double(rect.height))
    }
    
    func addCurve(to end: CGPoint, control1: CGPoint, control2: CGPoint) {
        cairo_curve_to(_context,
                       Double(control1.x), Double(control1.y),
                       Double(control2.x), Double(control2.y),
                       Double(end.x), Double(end.y))
    }
    
    func addQuadCurve(to end: CGPoint, control: CGPoint) {
        let current = currentPointOfPath
        
        let control1 = CGPoint(x: (current.x / 3.0) + (2.0 * control.x/3.0), y: (current.y / 3.0) + (2.0 * control.y/3.0))
        let control2 = CGPoint(x: (2.0 * control.x / 3.0) + (end.x / 3.0), y: (2.0 * control.y / 3.0) + (end.y / 3.0))
        
        addCurve(to: end, control1: control1, control2: control2)
    }
    
    func addLines(between points: [CGPoint]) {
        if points.count == 0 { return }
        
        move(to: points[0])
        
        for i in 1..<points.count {
            addLine(to: points[i])
        }
    }
    
    func addRects(_ rects: [CGRect]) {
        for rect in rects {
            addRect(rect)
        }
    }
    
    func addArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
        if clockwise {
          cairo_arc_negative(_context, Double(center.x), Double(center.y), Double(radius), Double(startAngle), Double(endAngle))
        }
        else {
          cairo_arc(_context, Double(center.x), Double(center.y), Double(radius), Double(startAngle), Double(endAngle))
        }
    }
    
    func addArc(tangent1End: CGPoint, tangent2End: CGPoint, radius: CGFloat) {
        // palkovnik:TODO: Implement
    }
    
    func addEllipse(in rect: CGRect) {
        // palkovnik:TODO: Implement
    }
    
    func addPath(_ path: CGPath) {
        cairo_append_path(_context, path._path)
    }
}

public extension CGContext {
    func fillPath(using rule: CGPathFillRule = .winding) {
        cairo_set_source(_context, _state.fillPattern)

        switch rule {
        case .winding:
            cairo_set_fill_rule(_context, CAIRO_FILL_RULE_WINDING)
        case .evenOdd:
            cairo_set_fill_rule(_context, CAIRO_FILL_RULE_EVEN_ODD)
        }
        cairo_fill(_context)
    }
    
    func clip(using rule: CGPathFillRule = .winding) {
        switch rule {
        case .winding:
            cairo_set_fill_rule(_context, CAIRO_FILL_RULE_WINDING)
        case .evenOdd:
            cairo_set_fill_rule(_context, CAIRO_FILL_RULE_EVEN_ODD)
        }
        cairo_clip_preserve(_context)
    }

    func resetClip() {
        cairo_reset_clip(_context)
    }
    
    func strokePath() {
        cairo_set_source(_context, _state.strokePattern)
        cairo_stroke(_context)
    }
}

public extension CGContext {
    func fill(_ rect: CGRect) {
        beginPath()
        addRect(rect)
        closePath()
        fillPath()
    }
    
    func stroke(_ rect: CGRect) {
        beginPath()
        addRect(rect)
        closePath()
        strokePath()
    }
}

public extension CGContext {
    var fillColor: CGColor {
        get {
            return _state.fillColor
        }
        set {
            _state.fillColor = newValue
        }
    }
    
    var strokeColor: CGColor {
        get {
            return _state.strokeColor
        }
        set {
            _state.strokeColor = newValue
        }
    }

    var lineWidth: CGFloat {
        get {
            return CGFloat(cairo_get_line_width(_context))
        }
        set {
            cairo_set_line_width(_context, Double(newValue))
        }
    }

    var lineCap: CGLineCap {
        get {
            let lineCap = cairo_get_line_cap(_context)

            switch lineCap {
            case CAIRO_LINE_CAP_BUTT: return .butt
            case CAIRO_LINE_CAP_ROUND: return .round
            case CAIRO_LINE_CAP_SQUARE: return .square
            default: fatalError("Invalid line cap in cairo context")
            }
        }
        set {
            let lineCap: cairo_line_cap_t = {
                switch newValue {
                case .butt: return CAIRO_LINE_CAP_BUTT
                case .round: return CAIRO_LINE_CAP_ROUND
                case .square: return CAIRO_LINE_CAP_SQUARE
                }
            }()

            cairo_set_line_cap(_context, lineCap)
        }
    }

    var lineJoin: CGLineJoin {
        get {
            let lineJoin = cairo_get_line_join(_context)

            switch lineJoin {
            case CAIRO_LINE_JOIN_MITER: return .miter
            case CAIRO_LINE_JOIN_ROUND: return .round
            case CAIRO_LINE_JOIN_BEVEL: return .bevel
            default: fatalError("Invalid line join in cairo context")
            }
        }
        set {
            let lineJoin: cairo_line_join_t = {
                switch newValue {
                case .miter: return CAIRO_LINE_JOIN_MITER
                case .round: return CAIRO_LINE_JOIN_ROUND
                case .bevel: return CAIRO_LINE_JOIN_BEVEL
                }
            }()

            cairo_set_line_join(_context, lineJoin)
        }
    }

    var miterLimit: CGFloat {
        get {
            return CGFloat(cairo_get_miter_limit(_context))
        }
        set {
            cairo_set_miter_limit(_context, Double(newValue))
        }
    }
}

public extension CGContext {
    var ctm: CGAffineTransform {
        get {
            var matrix = cairo_matrix_t()
            cairo_get_matrix(_context, &matrix)
            return CGAffineTransform(matrix: matrix)
        }
        set {
            var matrix = newValue._matrix
            cairo_set_matrix(_context, &matrix)
        }
    }
    
    func setIdentityTransform() {
        cairo_identity_matrix(_context)
    }
    
    func scaleBy(x sx: CGFloat, y sy: CGFloat) {
        cairo_scale(_context, Double(sx), Double(sy))
    }
    
    func translateBy(x tx: CGFloat, y ty: CGFloat) {
        cairo_translate(_context, Double(tx), Double(ty))
    }
    
    func rotate(by angle: CGFloat) {
        cairo_rotate(_context, Double(angle))
    }
    
    func concatenate(_ transform: CGAffineTransform) {
        var matrix = transform._matrix
        cairo_transform(_context, &matrix)
    }
}
