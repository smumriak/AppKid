//
//  Size.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 10.12.2020.
//

import Foundation

public struct Size<StorageType> where StorageType: BinaryInteger {
    public var width: StorageType
    public var height: StorageType

    public init(width: StorageType, height: StorageType) {
        self.width = width
        self.height = height
    }
}

public extension Size {
    var cgSize: CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
}

public extension CGSize {
    func size<StorageType>() -> Size<StorageType> where StorageType: BinaryInteger {
        return Size(width: StorageType(width), height: StorageType(height))
    }
}
