//
//  Point.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 10.12.2020.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    import CoreGraphics
#else
    import Foundation
#endif

public struct Rect<StorageType> where StorageType: BinaryInteger {
    public var origin: Point<StorageType>
    public var size: Size<StorageType>

    @_transparent
    public var x: StorageType {
        get { origin.x }
        set { origin.x = newValue }
    }

    @_transparent
    public var y: StorageType {
        get { origin.y }
        set { origin.y = newValue }
    }

    @_transparent
    public var width: StorageType {
        get { size.width }
        set { size.width = newValue }
    }

    @_transparent
    public var height: StorageType {
        get { size.height }
        set { size.height = newValue }
    }

    @_transparent
    public init(origin: Point<StorageType>, size: Size<StorageType>) {
        self.origin = origin
        self.size = size
    }

    @_transparent
    public init(x: StorageType, y: StorageType, width: StorageType, height: StorageType) {
        self.origin = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }
}

public extension Rect {
    @_transparent
    var cgRect: CGRect {
        return CGRect(origin: origin.cgPoint, size: size.cgSize)
    }
}

public extension CGRect {
    @_transparent
    func rect<StorageType>() -> Rect<StorageType> where StorageType: BinaryInteger {
        let standardized = self.standardized
        return Rect(origin: standardized.origin.point(), size: standardized.size.size())
    }
}
