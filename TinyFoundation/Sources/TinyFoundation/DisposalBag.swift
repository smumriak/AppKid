//
//  DisposalBag.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 03.10.2021.
//

import Collections

public class DisposalBag {
    public init() {}
    
    private var items: Deque<Any> = []

    public func append(_ item: Any) {
        items.append(item)
    }

    public func dispose() {
        items.removeAll()
    }
}
