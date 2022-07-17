//
//  EventProcessor.swift
//  AppKid
//
//  Created by Serhii Mumriak on 08.07.2022
//

import Foundation

protocol EventProcessor {
    associatedtype NativeEvent
    associatedtype Context
    associatedtype Error

    func process(event: NativeEvent, context: Context, timestamp: TimeInterval) throws -> Event
}
