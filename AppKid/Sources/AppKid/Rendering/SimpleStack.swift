//
//  SimpleStack.swift
//  AppKid
//
//  Created by Serhii Mumriak on 13.04.2021.
//

import Foundation
import CoreFoundation
import Volcano
import TinyFoundation

internal class SimpleStack<Type> {
    fileprivate var entities: [Type] = []

    @inlinable @inline(__always)
    var root: Type {
        entities.first!
    }

    func push(_ entity: Type) {
        entities.append(entity)
    }

    func pop() {
        entities.removeLast()
    }
}
