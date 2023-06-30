//
//  NumberFormatter.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

import Foundation

public extension NumberFormatter {
    static let spellOut: NumberFormatter = {
        let result = NumberFormatter()
        result.numberStyle = .spellOut
        result.locale = Locale(identifier: "en_US")

        return result
    }()
}
