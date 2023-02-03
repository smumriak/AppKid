//
//  Bag.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 02.02.2023
//

public struct Bag<Element: Hashable> {
    // element is key, value is number of times it is stored
    internal var storage: [Element: Int]

    public init(minimumCapacity: Int = 0) {
        storage = Dictionary(minimumCapacity: minimumCapacity)
    }

    public init<T: Sequence>(_ elements: T) where T.Element == Element {
        storage = elements.reduce(into: [:]) { accumulator, element in
            accumulator[element, default: 0] += 1
        }
    }

    public mutating func insert(_ object: Element) {
        storage[object, default: 0] += 1
    }

    public mutating func add(_ object: Element) {
        insert(object)
    }

    @discardableResult
    public mutating func remove(_ element: Element) -> Element? {
        guard let count = storage[element], count > 0 else {
            return nil
        }
        if count == 1 {
            storage[element] = nil
        } else {
            storage[element] = count - 1
        }

        return element
    }

    public func contains(_ element: Element) -> Bool {
        storage.keys.contains(element)
    }

    public var count: Int {
        storage.reduce(0) { accumulator, element in
            accumulator + element.value
        }
    }

    public func count(of element: Element) -> Int {
        storage[element] ?? 0
    }
}

extension Bag: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Element

    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(elements)
    }
}

// extension Bag: Collection {
//     public typealias Index = Dictionary<Element, Int>.Index
//     // TODO: Add proper subsequence type
//     public typealias SubSequence = Dictionary<Element, Int>.SubSequence
//     public typealias Indices = Dictionary<Element, Int>.Indices
//     // TODO: Add proper iterator type
//     public typealias Iterator = Dictionary<Element, Int>.Iterator
    
//     public var startIndex: Index {
//         storage.startIndex
//     }

//     public var endIndex: Index {
//         storage.endIndex
//     }

//     public func makeIterator() -> Iterator {
//     }

//     public subscript(position: Index) -> Element {
//         _read {
//         }
//     }

//     public subscript(bounds: Range<Index>) -> SubSequence {
//         storage[bounds]
//     }

//     public var indices: Indices {
//         storage.indices
//     }

//     public func _customIndexOfEquatableElement(_ element: Element) -> Index?? {
//         storage.keys._customIndexOfEquatableElement(element)
//     }

//     public func _customLastIndexOfEquatableElement(_ element: Element) -> Index?? {
//         storage.keys._customLastIndexOfEquatableElement(element)
//     }

//     public func index(_ i: Index, offsetBy distance: Int) -> Index {
//         storage.index(i, offsetBy: distance)
//     }

//     public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
//         storage.index(i, offsetBy: distance, limitedBy: limit)
//     }

//     public func distance(from start: Index, to end: Index) -> Int {
//         storage.distance(from: start, to: end)
//     }

//     public func _failEarlyRangeCheck(_ index: Index, bounds: Range<Index>) {
//         storage._failEarlyRangeCheck(index, bounds: bounds)
//     }

//     public func _failEarlyRangeCheck(_ index: Index, bounds: ClosedRange<Index>) {
//         storage._failEarlyRangeCheck(index, bounds: bounds)
//     }

//     public func _failEarlyRangeCheck(_ range: Range<Index>, bounds: Range<Index>) {
//         storage._failEarlyRangeCheck(range, bounds: bounds)
//     }

//     public func index(after i: Index) -> Index {
//         storage.index(after: i)
//     }

//     public func formIndex(after i: inout Index) {
//         storage.formIndex(after: &i)
//     }

//     public func makeIterator() -> Iterator {
//         storage.makeIterator()
//     }

//     public func _customContainsEquatableElement(_ element: Element) -> Bool? {
//         storage.keys._customContainsEquatableElement(element)
//     }

//     public func _copyToContiguousArray() -> ContiguousArray<Element> {
//         storage.keys._copyToContiguousArray()
//     }

//     public func _copyContents(initializing ptr: UnsafeMutableBufferPointer<Element>) -> (Iterator, UnsafeMutableBufferPointer<Element>.Index) {
//     }

//     public func withContiguousStorageIfAvailable<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R? {
//     }
// }
