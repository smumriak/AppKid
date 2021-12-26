//
//  CAAction.swift
//  ContentAnimation
//
//  Created by Serhii Mumriak on 26.11.2021.
//

import Foundation

public protocol CAAction {
    func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable: Any]?)
}

public extension CAAction {
    func run(forKey event: String, object anObject: Any, arguments dict: [AnyHashable: Any]?) {}
}

extension NSNull: CAAction {}
