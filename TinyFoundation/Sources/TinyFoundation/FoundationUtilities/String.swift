//
//  String.swift
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

public extension StringProtocol {
    @_alwaysEmitIntoClient
    @inlinable @_transparent
    static var newline: Self {
        #if os(Windows)
            "\r\n"
        #else
            "\n"
        #endif
    }
}
