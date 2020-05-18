//
//  SmartPointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

public protocol SmartPointer {
    associatedtype Pointer_t
    var pointer: Pointer_t { get set }

    init(with pointer: Pointer_t)
}
