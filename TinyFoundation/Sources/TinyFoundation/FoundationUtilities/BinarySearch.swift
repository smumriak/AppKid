//
//  BinarySearch.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 05.02.2023
//

public enum BinarySearchOptions: Int {
    case anyEqual // first index that fits
    case firstEqual // lowest possible index
    case lastEqual // highest possible index, will be +1 after the last equal element
}

public extension RandomAccessCollection where Element: Comparable {
    @_transparent
    func findInsertionIndex(for element: Element, options: BinarySearchOptions = .anyEqual) -> Index? {
        findInsertionIndex(for: element, options: options, predicate: <)
    }

    @_transparent
    func findInsertionIndex<T: Comparable>(for element: Element, keyPath: KeyPath<Element, T>, options: BinarySearchOptions = .anyEqual) -> Index? {
        findInsertionIndex(for: element, options: options, predicate: <)
    }

    @_transparent
    func findInsertionIndex<T: Comparable>(for element: Element, keyPath: KeyPath<Element, T>, options: BinarySearchOptions = .anyEqual, predicate: (_ lhs: T, _ rhs: T) throws -> (Bool)) rethrows -> Index? {
        try findInsertionIndex(for: element, options: options) {
            try predicate($0[keyPath: keyPath], $1[keyPath: keyPath])
        }
    }

    func findInsertionIndex(for element: Element, options: BinarySearchOptions = .anyEqual, predicate: (_ lhs: Element, _ rhs: Element) throws -> (Bool)) rethrows -> Index? {
        var left = startIndex
        if isEmpty {
            return left
        }

        if try predicate(element, self[left]) {
            return left
        }
        
        var right = index(endIndex, offsetBy: -1)
        let rightElement = self[right]
        if try predicate(element, rightElement) == false && element != rightElement {
            return endIndex
        }

        var result: Index? = nil
        var lastGreaterThan: Index? = nil
        
        loop: while left <= right {
            let middle = index(left, offsetBy: distance(from: left, to: right) / 2)
            let middleElement = self[middle]

            if try predicate(element, middleElement) { // search right
                lastGreaterThan = middle
                right = index(before: middle)
            } else if element == middleElement { // =
                result = middle
                switch options {
                    case .anyEqual:
                        break loop

                    case .firstEqual:
                        lastGreaterThan = middle
                        right = index(before: middle)

                    case .lastEqual:
                        left = index(after: middle)
                }
            } else { // search left
                left = index(after: middle)
            }
        }
        
        if let result {
            if options == .lastEqual {
                return index(after: result)
            } else {
                return result
            }
        } else {
            return lastGreaterThan
        }
    }
}
