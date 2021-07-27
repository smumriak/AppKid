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

internal extension CGPathFillRule {
    var cairoFillRule: cairo_fill_rule_t {
        switch self {
            case .winding: return .winding
            case .evenOdd: return .evenOdd
        }
    }
}

public enum CGLineCap: Int {
    case butt
    case round
    case square
}

internal extension CGLineCap {
    var cairoLineCap: cairo_line_cap_t {
        switch self {
            case .butt: return .butt
            case .round: return .round
            case .square: return .square
        }
    }
}

internal extension cairo_line_cap_t {
    var lineCap: CGLineCap {
        switch self {
            case .butt: return .butt
            case .round: return .round
            case .square: return .square
            default: fatalError("Invalid line cap in cairo context")
        }
    }
}

public enum CGLineJoin: Int {
    case miter
    case round
    case bevel
}

internal extension CGLineJoin {
    var cairoLineJoin: cairo_line_join_t {
        switch self {
            case .miter: return .miter
            case .round: return .round
            case .bevel: return .bevel
        }
    }
}

internal extension cairo_line_join_t {
    var lineJoin: CGLineJoin {
        switch self {
            case .miter: return .miter
            case .round: return .round
            case .bevel: return .bevel
            default: fatalError("Invalid line cap in cairo context")
        }
    }
}

@_spi(AppKid) public class CGContextDataStore {
    //palkovnik: swift-atomics libabry can not be built on macOS. oh the irony
    private let lock = NSRecursiveLock()
    
    private var useCount: UInt

    public let surface: SmartPointer<cairo_surface_t>
    public let data: UnsafeMutableRawPointer

    public init(surface: SmartPointer<cairo_surface_t>, useCount: UInt = 1) {
        self.surface = surface
        self.data = UnsafeMutableRawPointer(cairo_image_surface_get_data(surface.pointer))
        self.useCount = useCount
    }

    public func currentValue() -> UInt {
        lock.lock()
        defer { lock.unlock() }

        return useCount
    }

    public func increaseUseCount() {
        lock.lock()
        defer { lock.unlock() }

        useCount += 1
    }

    public func decreaseUseCount() {
        lock.lock()
        defer { lock.unlock() }

        assert(useCount > 0, "Can't decrement use count from zero")

        useCount -= 1
    }
}

open class CGContext {
    @_spi(AppKid) public var context: RetainablePointer<cairo_t>
    @_spi(AppKid) public var surface: RetainablePointer<cairo_surface_t>

    internal var _state = CGContextState()
    internal var _statesStack: [CGContextState] = []

    internal var dataStore: CGContextDataStore?

    open var shouldAntialias = false {
        didSet {
            if shouldAntialias {
                cairo_set_antialias(context.pointer, CAIRO_ANTIALIAS_GOOD)
            } else {
                cairo_set_antialias(context.pointer, CAIRO_ANTIALIAS_NONE)
            }
        }
    }

    public internal(set) var bitmapInfo: CGBitmapInfo = []
    public internal(set) var alphaInfo: CGImageAlphaInfo = .none
    public internal(set) var bitsPerComponent: Int = 0
    public internal(set) var bitsPerPixel: Int = 0
    public internal(set) var bytesPerRow: Int = 0
    public internal(set) var colorSpace: CGColorSpace? = nil
    public var data: UnsafeMutableRawPointer? { dataStore?.data }
    public internal(set) var height: Int = 0
    public internal(set) var width: Int = 0

    deinit {
        dataStore?.decreaseUseCount()
    }
    
    internal init(cairoContext: UnsafeMutablePointer<cairo_t>, width: Int, height: Int) {
        self.context = RetainablePointer(with: cairoContext)
        self.surface = RetainablePointer(with: cairo_get_target(context.pointer))
        self.width = width
        self.height = height
        _state.defaultPattern = cairo_get_source(context.pointer)
    }

    public init(_ context: CGContext) {
        self.context = context.context
        self.surface = context.surface
        self.width = context.width
        self.height = context.height
        _state.defaultPattern = cairo_get_source(self.context.pointer)
    }
    
    public init(surface: RetainablePointer<cairo_surface_t>, width: Int, height: Int) {
        self.context = RetainablePointer(withRetained: cairo_create(surface.pointer)!)
        self.surface = surface
        self.width = width
        self.height = height
        _state.defaultPattern = cairo_get_source(context.pointer)
    }
}

public extension CGContext {
    func saveState() {
        _statesStack.append(_state)
        _state = CGContextState()
        cairo_save(context.pointer)
    }
    
    func restoreState() {
        cairo_restore(context.pointer)
        if let state = _statesStack.popLast() {
            _state = state
        } else {
            _state = CGContextState()
        }
    }
}

public extension CGContext {
    func beginPath() {
        cairo_new_path(context.pointer)
    }
    
    func closePath() {
        cairo_close_path(context.pointer)
    }
    
    var isPathEmpty: Bool {
        return boundingBoxOfPath.isNull
    }
    
    var currentPointOfPath: CGPoint {
        var x: Double = .zero
        var y: Double = .zero
        cairo_get_current_point(context.pointer, &x, &y)
        return CGPoint(x: x, y: y)
    }
    
    var boundingBoxOfPath: CGRect {
        var x1: Double = .zero
        var y1: Double = .zero
        var x2: Double = .zero
        var y2: Double = .zero
        
        cairo_path_extents(context.pointer, &x1, &y1, &x2, &y2)
        
        if x1.isZero && y1.isZero && x2.isZero && y2.isZero {
            return .null
        } else {
            return CGRect(x: min(x1, x2), y: min(y1, y2), width: max(x1, x2) - min(x1, x2), height: max(y1, y2) - min(y1, y2))
        }
    }
    
    var path: CGPath? {
        return CGPath(from: context.pointer)
    }
}

public extension CGContext {
    func move(to point: CGPoint) {
        cairo_move_to(context.pointer, Double(point.x), Double(point.y))
    }
    
    func addLine(to point: CGPoint) {
        cairo_line_to(context.pointer, Double(point.x), Double(point.y))
    }
    
    func addRect(_ rect: CGRect) {
        cairo_rectangle(context.pointer, Double(rect.origin.x), Double(rect.origin.y), Double(rect.width), Double(rect.height))
    }
    
    func addCurve(to end: CGPoint, control1: CGPoint, control2: CGPoint) {
        cairo_curve_to(context.pointer,
                       Double(control1.x), Double(control1.y),
                       Double(control2.x), Double(control2.y),
                       Double(end.x), Double(end.y))
    }
    
    func addQuadCurve(to end: CGPoint, control: CGPoint) {
        let current = currentPointOfPath
        
        let control1 = CGPoint(x: (current.x / 3.0) + (2.0 * control.x / 3.0), y: (current.y / 3.0) + (2.0 * control.y / 3.0))
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
            cairo_arc_negative(context.pointer, Double(center.x), Double(center.y), Double(radius), Double(startAngle), Double(endAngle))
        } else {
            cairo_arc(context.pointer, Double(center.x), Double(center.y), Double(radius), Double(startAngle), Double(endAngle))
        }
    }
    
    func addArc(tangent1End: CGPoint, tangent2End: CGPoint, radius: CGFloat) {
        // TODO: palkovnik: Implement
    }
    
    func addEllipse(in rect: CGRect) {
        // TODO: palkovnik: Implement
    }
    
    func addPath(_ path: CGPath) {
        cairo_append_path(context.pointer, path._path)
    }
}

public extension CGContext {
    func fillPath(using rule: CGPathFillRule = .winding) {
        recreateDataIfNeeded()

        cairo_set_source(context.pointer, _state.fillPattern)

        cairo_set_fill_rule(context.pointer, rule.cairoFillRule)
        cairo_fill(context.pointer)
    }
    
    func clip(using rule: CGPathFillRule = .winding) {
        recreateDataIfNeeded()

        cairo_set_fill_rule(context.pointer, rule.cairoFillRule)
        cairo_clip_preserve(context.pointer)
    }

    func resetClip() {
        recreateDataIfNeeded()

        cairo_reset_clip(context.pointer)
    }
    
    func strokePath() {
        recreateDataIfNeeded()

        cairo_set_source(context.pointer, _state.strokePattern)
        cairo_stroke(context.pointer)
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
            return CGFloat(cairo_get_line_width(context.pointer))
        }
        set {
            cairo_set_line_width(context.pointer, Double(newValue))
        }
    }

    var lineCap: CGLineCap {
        get {
            return cairo_get_line_cap(context.pointer).lineCap
        }
        set {
            cairo_set_line_cap(context.pointer, newValue.cairoLineCap)
        }
    }

    var lineJoin: CGLineJoin {
        get {
            return cairo_get_line_join(context.pointer).lineJoin
        }
        set {
            cairo_set_line_join(context.pointer, newValue.cairoLineJoin)
        }
    }

    var miterLimit: CGFloat {
        get {
            return CGFloat(cairo_get_miter_limit(context.pointer))
        }
        set {
            cairo_set_miter_limit(context.pointer, Double(newValue))
        }
    }
}

public extension CGContext {
    var ctm: CGAffineTransform {
        get {
            var matrix = cairo_matrix_t()
            cairo_get_matrix(context.pointer, &matrix)
            return CGAffineTransform(matrix: matrix)
        }
        set {
            var matrix = newValue._matrix
            cairo_set_matrix(context.pointer, &matrix)
        }
    }
    
    func setIdentityTransform() {
        cairo_identity_matrix(context.pointer)
    }
    
    func scaleBy(x sx: CGFloat, y sy: CGFloat) {
        cairo_scale(context.pointer, Double(sx), Double(sy))
    }
    
    func translateBy(x tx: CGFloat, y ty: CGFloat) {
        cairo_translate(context.pointer, Double(tx), Double(ty))
    }
    
    func rotate(by angle: CGFloat) {
        cairo_rotate(context.pointer, Double(angle))
    }
    
    func concatenate(_ transform: CGAffineTransform) {
        var matrix = transform._matrix
        cairo_transform(context.pointer, &matrix)
    }
}

public extension CGContext {
    func makeImage() -> CGImage? {
        return CGImage(context: self)
    }
}

internal extension CGContext {
    func recreateDataIfNeeded() {
        guard let oldDataStore = dataStore else {
            return
        }

        if oldDataStore.currentValue() <= 1 {
            return
        }

        let surfaceRaw = cairo_image_surface_create(cairo_image_surface_get_format(oldDataStore.surface.pointer), CInt(width), CInt(height))!

        let surface = RetainablePointer(withRetained: surfaceRaw)

        self.context = RetainablePointer(withRetained: cairo_create(surface.pointer)!)
        self.surface = surface
        dataStore = CGContextDataStore(surface: surface)

        dataStore?.data.copyMemory(from: oldDataStore.data, byteCount: height * bytesPerRow)
    }
}
