//
//  LVEmptyPath.swift
//  Volcano
//
//  Created by Serhii Mumriak on 10.01.2023
//

import TinyFoundation

public struct LVEmptyPath<Struct: InitializableWithNew>: LVPath {
    @inlinable @_transparent
    public init() {}
}
