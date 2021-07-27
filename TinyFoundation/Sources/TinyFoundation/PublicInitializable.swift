//
//  PublicInitializable.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 24.07.2021.
//

import Foundation

public protocol PublicInitializable {
    init()
}

extension Optional: PublicInitializable {
    public init() {
        self = .none
    }
}
