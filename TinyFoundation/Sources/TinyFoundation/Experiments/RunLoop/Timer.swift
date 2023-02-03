//
//  Timer.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 24.01.2023
//

public final class Timer1: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public static func == (lhs: Timer1, rhs: Timer1) -> Bool {
        return lhs === rhs
    }
}
