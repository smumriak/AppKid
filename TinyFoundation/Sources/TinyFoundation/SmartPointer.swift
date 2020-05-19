//
//  SmartPointer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 17.05.2020.
//

import Foundation

public protocol SmartPointer {
    associatedtype Pointee
    typealias Pointer_t = UnsafeMutablePointer<Pointee>
    
    var pointer: Pointer_t { get set }
}
