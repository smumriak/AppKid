//
//  CStringUtils.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 13.06.2020.
//

import Foundation

public extension Array where Element == String {
    var cStrings: [SmartPointer<Int8>] {
        let deleter = SmartPointer<Int8>.Deleter.custom { free($0) }

        return map {
            SmartPointer<Int8>(with: strdup($0), deleter: deleter)
        }
    }
}
