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

public enum ComparisonResult: Int {
    case descending
    case same
    case ascending
}

public extension Comparable {
    @_transparent
    static func ascendingPredicate(_ lhs: Self, _ rhs: Self) -> ComparisonResult {
        if lhs < rhs {
            return .ascending
        } else if lhs > rhs {
            return .descending
        } else {
            return .same
        }
    }

    @_transparent
    static func descendingPredicate(_ lhs: Self, _ rhs: Self) -> ComparisonResult {
        if lhs > rhs {
            return .ascending
        } else if lhs < rhs {
            return .descending
        } else {
            return .same
        }
    }
}

public extension RandomAccessCollection {
    @_transparent
    func findInsertionIndex<T: Comparable>(for element: Element, keyPath: KeyPath<Element, T>, options: BinarySearchOptions = .anyEqual) -> Index {
        findInsertionIndex(for: element, keyPath: keyPath, options: options, predicate: T.ascendingPredicate)
    }

    @_transparent
    func findInsertionIndex<T: Comparable>(for element: Element, keyPath: KeyPath<Element, T>, options: BinarySearchOptions = .anyEqual, predicate: (_ lhs: T, _ rhs: T) throws -> (ComparisonResult)) rethrows -> Index {
        try findInsertionIndex(for: element, options: options) {
            try predicate($0[keyPath: keyPath], $1[keyPath: keyPath])
        }
    }

    func findInsertionIndex(for element: Element, options: BinarySearchOptions = .anyEqual, predicate: (_ lhs: Element, _ rhs: Element) throws -> (ComparisonResult)) rethrows -> Index {
        var left = startIndex
        if isEmpty {
            return left
        }

        if try predicate(element, self[left]) == .ascending {
            return left
        }
        
        var right = index(endIndex, offsetBy: -1)
        let rightElement = self[right]
        if try predicate(element, rightElement) == .descending {
            return endIndex
        }

        var result: Index? = nil
        var lastGreaterThan: Index? = nil
        
        loop: while left <= right {
            let middle = index(left, offsetBy: distance(from: left, to: right) / 2)
            let middleElement = self[middle]

            let comparisonResult = try predicate(element, middleElement)

            switch comparisonResult {
                case .ascending: // search right
                    lastGreaterThan = middle
                    right = index(before: middle)

                case .descending: // search left
                    left = index(after: middle)

                case .same: // =
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
            }
        }
        
        if let result {
            if options == .lastEqual {
                return index(after: result)
            } else {
                return result
            }
        } else {
            return lastGreaterThan ?? startIndex
        }
    }
}

public extension RandomAccessCollection where Element: Comparable {
    @_transparent
    func findInsertionIndex(for element: Element, options: BinarySearchOptions = .anyEqual) -> Index {
        findInsertionIndex(for: element, options: options, predicate: Element.ascendingPredicate)
    }
}
