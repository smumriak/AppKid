//
//  DylibWrapper.swift
//  AppKid
//
//  Created by Serhii Mumriak on 24.04.2020.
//

import Foundation

internal class DylibWrapper {
    enum Error: Swift.Error {
        case couldNotOpenLibrary(name: String)
        case noSychSymbol(name: String)
    }

    fileprivate var handle: UnsafeMutableRawPointer

    deinit {
        dlclose(handle)
    }

    init(name: String) throws {
        guard let handle = dlopen(name, RTLD_NOW) else {
            throw Error.couldNotOpenLibrary(name: name)
        }

        self.handle = handle
    }

    static func perform(on name: String, closure: (_ dlWrapper: DylibWrapper) throws -> ()) throws {
        let dlWrapper = try DylibWrapper(name: name)

        try closure(dlWrapper)
    }

    static func perform<Result>(on name: String, closure: (_ dlWrapper: DylibWrapper) throws -> (Result)) throws -> Result {
        let dlWrapper = try DylibWrapper(name: name)

        return try closure(dlWrapper)
    }

    func loadCFunction<Function>(with name: String) throws -> Function {
        guard let symbol = dlsym(handle, name) else {
            throw Error.noSychSymbol(name: name)
        }

        return unsafeBitCast(symbol, to: Function.self)
    }
}
