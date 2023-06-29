//
//  String.swift
//  Volcano
//
//  Created by Serhii Mumriak on 29.06.2023
//

import Foundation

public extension String {
    var camelcased: String {
        return camelcased(capitalizeFirst: false)
    }

    var strippingVKPrevix: String {
        if self.hasPrefix("VK_") {
            return String(self.dropFirst(3))
        } else {
            return self
        }
    }

    func camelcased(capitalizeFirst: Bool = false) -> String {
        return split(separator: "_")
            .enumerated()
            .map {
                if $0.offset == 0 && !capitalizeFirst {
                    return $0.element.lowercased()
                } else {
                    return $0.element.capitalized
                }
            }
            .joined()
    }

    func tagSuffix(tags: [TagDefinition], withoutUnderscore: Bool = false, caseSensitive: Bool = true) -> String? {
        for tag in tags {
            let name = caseSensitive ? tag.name : tag.name.lowercased()
            let checkedValue = caseSensitive ? self : self.lowercased()
            
            let suffix: String
            if withoutUnderscore {
                suffix = name
            } else {
                suffix = "_" + name
            }
            if checkedValue.hasSuffix(suffix) {
                return suffix
            }
        }

        return nil
    }

    mutating func stripTagSuffix(tags: [TagDefinition], withoutUnderscore: Bool = false) {
        self = strippingTagSuffix(tags: tags, withoutUnderscore: withoutUnderscore)
    }

    func strippingTagSuffix(tags: [TagDefinition], withoutUnderscore: Bool = false, caseSensitive: Bool = true) -> String {
        for tag in tags {
            let name = caseSensitive ? tag.name : tag.name.lowercased()
            let checkedValue = caseSensitive ? self : self.lowercased()
            
            let suffix: String
            if withoutUnderscore {
                suffix = name
            } else {
                suffix = "_" + name
            }
            if checkedValue.hasSuffix(suffix) {
                // FIXME: replace self with checkedValue
                return String(self.dropLast(suffix.count))
            }
        }

        return self
    }

    func tagPrefix(tags: [TagDefinition], withoutUnderscore: Bool = false, caseSensitive: Bool = true) -> String? {
        for tag in tags {
            let name = caseSensitive ? tag.name : tag.name.lowercased()
            let checkedValue = caseSensitive ? self : self.lowercased()
            
            let prefix: String
            if withoutUnderscore {
                prefix = name
            } else {
                prefix = name + "_"
            }
            
            if checkedValue.hasPrefix(prefix) {
                return prefix
            }
        }

        return nil
    }

    mutating func stripTagPrefix(tags: [TagDefinition], withoutUnderscore: Bool = false) {
        self = strippingTagPrefix(tags: tags, withoutUnderscore: withoutUnderscore)
    }

    func strippingTagPrefix(tags: [TagDefinition], withoutUnderscore: Bool = false, caseSensitive: Bool = true) -> String {
        for tag in tags {
            let name = caseSensitive ? tag.name : tag.name.lowercased()
            let checkedValue = caseSensitive ? self : self.lowercased()
            
            let prefix: String
            if withoutUnderscore {
                prefix = name
            } else {
                prefix = name + "_"
            }
            
            if checkedValue.hasPrefix(prefix) {
                return String(self.dropFirst(prefix.count))
            }
        }

        return self
    }

    mutating func lowercaseFirst() {
        self = lowercasedFirst()
    }

    func lowercasedFirst() -> String {
        if isEmpty {
            return ""
        }

        let afterFirst = dropFirst()
        return first!.lowercased() + afterFirst
    }

    var spelledOutNumberCamelcasedString: String {
        let number = Int(self)!
        if number < 100 {
            return NumberFormatter.spellOut.string(from: NSNumber(value: number))!
                .replacingOccurrences(of: "-", with: "_")
                .camelcased
        } else {
            return enumerated().reduce("") { accumulator, element in
                let number = Int(String(element.element))!
                let result = NumberFormatter.spellOut.string(from: NSNumber(value: number))!
                return accumulator + (element.offset == 0 ? result.lowercased() : result.capitalized)
            }
        }
    }
}
