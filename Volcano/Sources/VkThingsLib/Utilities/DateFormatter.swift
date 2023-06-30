//
//  DateFormatter.swift
//  Volcano
//
//  Created by Serhii Mumriak on 30.06.2023
//

import Foundation

public extension DateFormatter {
    static let header: DateFormatter = {
        let result = DateFormatter()
        result.timeZone = TimeZone(abbreviation: "UTC")
        result.locale = Locale(identifier: "en_US_POSIX")
        result.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss'Z'"

        return result
    }()
}
