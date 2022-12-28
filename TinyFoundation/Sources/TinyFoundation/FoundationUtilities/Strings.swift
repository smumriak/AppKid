//
//  Strings.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 27.12.2022
//

@_transparent
public func == (lhs: any StringProtocol, rhs: String) -> Bool {
    String(lhs) == rhs
}

@_transparent
public func == (lhs: String, rhs: any StringProtocol) -> Bool {
    rhs == lhs
}
