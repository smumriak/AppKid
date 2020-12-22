//
//  Point.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 10.12.2020.
//

import Foundation

public struct Point<StorageType> where StorageType: BinaryInteger {
    public var x: StorageType
    public var y: StorageType

    public init(x: StorageType, y: StorageType) {
        self.x = x
        self.y = y
    }
}


public extension Point {
    var cgPoint: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

public extension CGPoint {
    func point<StorageType>() -> Point<StorageType> where StorageType: BinaryInteger {
        return Point(x: StorageType(x), y: StorageType(y))
    }
}
