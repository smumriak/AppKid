//
//  DylibWrapper.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 24.04.2020.
//

import Foundation

public class DylibWrapper {
    public enum Error: Swift.Error {
        case couldNotOpenLibrary(name: String)
        case noSychSymbol(name: String)
    }

    public struct LoadingFlags: OptionSet {
        public typealias RawValue = Int32
        public var rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public static let local = LoadingFlags(rawValue: RTLD_LOCAL)
        public static let lazy = LoadingFlags(rawValue: RTLD_LAZY)
        public static let now = LoadingFlags(rawValue: RTLD_NOW)
        #if os(Linux)
        public static let bindingMask = LoadingFlags(rawValue: RTLD_BINDING_MASK)
        public static let deepBind = LoadingFlags(rawValue: RTLD_DEEPBIND)
        #endif
        public static let noLoad = LoadingFlags(rawValue: RTLD_NOLOAD)
        public static let global = LoadingFlags(rawValue: RTLD_GLOBAL)
        public static let noDelete = LoadingFlags(rawValue: RTLD_NODELETE)
    }

    fileprivate var handle: UnsafeMutableRawPointer

    deinit {
        dlclose(handle)
    }

    public init(name: String, loadingFlags: LoadingFlags = [.now]) throws {
        guard let handle = dlopen(name, loadingFlags.rawValue) else {
            throw Error.couldNotOpenLibrary(name: name)
        }

        self.handle = handle
    }

    public static func perform(on name: String, loadingFlags: LoadingFlags = [.now], closure: (_ dlWrapper: DylibWrapper) throws -> ()) throws {
        let dlWrapper = try DylibWrapper(name: name, loadingFlags: loadingFlags)

        try closure(dlWrapper)
    }

    public static func perform<Result>(on name: String, loadingFlags: LoadingFlags = [.now], closure: (_ dlWrapper: DylibWrapper) throws -> (Result)) throws -> Result {
        let dlWrapper = try DylibWrapper(name: name, loadingFlags: loadingFlags)

        return try closure(dlWrapper)
    }

    public func loadCFunction<Function>(with name: String) throws -> Function {
        guard let symbol = dlsym(handle, name) else {
            throw Error.noSychSymbol(name: name)
        }

        return unsafeBitCast(symbol, to: Function.self)
    }
}
