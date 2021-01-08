//
//  Point.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 10.12.2020.
//

import Foundation

public struct Rect<StorageType> where StorageType: BinaryInteger {
    public var origin: Point<StorageType>
    public var size: Size<StorageType>

    public var x: StorageType {
        get { origin.x }
        set { origin.x = newValue }
    }

    public var y: StorageType {
        get { origin.y }
        set { origin.y = newValue }
    }

    public var width: StorageType {
        get { size.width }
        set { size.width = newValue }
    }

    public var height: StorageType {
        get { size.height }
        set { size.height = newValue }
    }

    public init(origin: Point<StorageType>, size: Size<StorageType>) {
        self.origin = origin
        self.size = size
    }

    public init(x: StorageType, y: StorageType, width: StorageType, height: StorageType) {
        self.origin = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }
}

public extension Rect {
    var cgRect: CGRect {
        return CGRect(origin: origin.cgPoint, size: size.cgSize)
    }
}

public extension CGRect {
    @inlinable @inline(__always)
    func rect<StorageType>() -> Rect<StorageType> where StorageType: BinaryInteger {
        let standardized = self.standardized
        return Rect(origin: standardized.origin.point(), size: standardized.size.size())
    }
}
