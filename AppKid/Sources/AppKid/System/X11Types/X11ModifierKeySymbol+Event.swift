//
//  X11ModifierKeySymbol+Event.swift
//  AppKid
//
//  Created by Serhii Mumriak on 23.04.2020.
//

import Foundation
import CXlib

extension X11ModifierKeySymbol: CaseIterable {
    public typealias AllCases = [X11ModifierKeySymbol]
    public static var allCases: AllCases = [
        .leftShift,
        .rightShift,
        .leftControl,
        .rightControl,
        .caps,
        .shift,
        .leftMeta,
        .rightMeta,
        .leftAlt,
        .rightAlt,
        .leftSuper,
        .rightSuper,
        .leftHyper,
        .rightHyper,
        .modeSwitch,
        .level3Shift,
    ]

    var isValidRawValue: Bool {
        return Self.allCases
            .map { $0.rawValue }
            .contains(rawValue)
    }

    var modifierFlag: Event.ModifierFlags {
        switch self {
            case .leftShift: return .shift
            case .rightShift: return .shift
            case .leftControl: return .control
            case .rightControl: return .control
            case .caps: return .capsLock
            case .shift: return .shift
            case .leftMeta: return .none
            case .rightMeta: return .none
            case .leftAlt: return .option
            case .rightAlt: return .option
            case .leftSuper: return .command
            case .rightSuper: return .command
            case .leftHyper: return .none
            case .rightHyper: return .none
            case .modeSwitch: return .option
            case .level3Shift: return .option
            @unknown default: return .none
        }
    }
}
