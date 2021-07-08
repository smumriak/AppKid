//
//  SimpleStack.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 13.04.2021.
//

import Foundation
import Collections

public class SimpleStack<Type> {
    fileprivate var entities: Deque<Type> = []

    public init() {}

    public var root: Type {
        entities.first!
    }

    public func push(_ entity: Type) {
        entities.append(entity)
    }

    public func pop() {
        entities.removeLast()
    }
}
