//
//  UnsafeTypedPointerProtocol.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 29.09.2021.
//

import Foundation

public protocol UnsafeTypedPointerProtocol {
    associatedtype Pointee
    var pointee: Pointee { get }
}

extension UnsafePointer: UnsafeTypedPointerProtocol {}
extension UnsafeMutablePointer: UnsafeTypedPointerProtocol {}