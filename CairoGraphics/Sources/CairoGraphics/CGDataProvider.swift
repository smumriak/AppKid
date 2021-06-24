//
//  CGImageDataProvider.swift
//  CairoGraphics
//
//  Created by Serhii Mumriak on 08.01.2021.
//

import Foundation
import CoreFoundation
import TinyFoundation

/// A struct with callbacks for CairoGraphics to invoke when it needs to load data from sequentional data source provider
public struct CGDataProviderSequentialCallbacks {
    /// Main callback that actually loads the bytes from whatever sequetional source into the buffer provided by CairoGraphics
    /// - Parameters:
    ///     - `info`: the `sequntinalInfo` pointer that was supplied into CGDataProvider initializer
    ///     - `buffer`: the pointer to buffer pointer created by CairoGraphics into which this callback should write it's data
    ///     - `count`: the size of the buffer provided and the expected amount of bytes that callback whould write into the buffer
    /// - Returns: the actual amount of bytes that callback has written into the buffer. If none is written - return 0
    typealias CGDataProviderGetBytesCallback = (_ info: UnsafeMutableRawPointer?, _ buffer: UnsafeMutableRawPointer, _ count: Int) -> Int
    typealias CGDataProviderSkipForwardCallback = (_ info: UnsafeMutableRawPointer?, _ count: off_t) -> off_t
    typealias CGDataProviderRewindCallback = (_ pointer: UnsafeMutableRawPointer?) -> ()
    typealias CGDataProviderReleaseInfoCallback = (_ info: UnsafeMutableRawPointer?) -> ()

    let version: UInt32 = 0
    let getBytes: CGDataProviderGetBytesCallback? = nil
    let skipForward: CGDataProviderSkipForwardCallback? = nil
    let rewind: CGDataProviderRewindCallback? = nil
    let releaseInfo: CGDataProviderReleaseInfoCallback? = nil
}

public struct CGDataProviderDirectCallbacks {
    typealias CGDataProviderGetBytePointerCallback = (_ info: UnsafeMutableRawPointer?) -> UnsafeRawPointer?
    typealias CGDataProviderReleaseBytePointerCallback = (_ info: UnsafeMutableRawPointer?, _ pointer: UnsafeRawPointer) -> ()
    typealias CGDataProviderGetBytesAtPositionCallback = (_ info: UnsafeMutableRawPointer?, _ buffer: UnsafeMutableRawPointer, _ position: off_t, _ count: Int) -> Int
    typealias CGDataProviderReleaseInfoCallback = (_ info: UnsafeMutableRawPointer?) -> Void

    let version: UInt32 = 0
    let getBytePointer: CGDataProviderGetBytePointerCallback
    let releaseBytePointer: CGDataProviderReleaseBytePointerCallback
    let getBytesAtPosition: CGDataProviderGetBytesAtPositionCallback
    let releaseInfo: CGDataProviderReleaseInfoCallback
}

public typealias CGDataProviderReleaseDataCallback = (_ info: UnsafeMutableRawPointer?, _ data: UnsafeRawPointer, _ size: Int) -> ()

public class CGDataProvider {
    internal enum DataProviderType {
        case sequential(callbacks: CGDataProviderSequentialCallbacks)
        case directAccess(callbacks: CGDataProviderDirectCallbacks)
        case directData(data: UnsafeRawPointer, size: Int, releaseCallback: CGDataProviderReleaseDataCallback?)
        case data(data: Data)
        case url(url: URL)
        case filename(filename: String)
    }

    internal let providerType: DataProviderType
    public let info: UnsafeMutableRawPointer?

    deinit {
        switch providerType {
            case .sequential(let callbacks): callbacks.releaseInfo?(info)
            case .directData(let data, let size, let releaseCallback): releaseCallback?(info, data, size)
            case .data(_): break
            case .url(_): break
            case .filename(_): break
            default: fatalError("NOT YET IMPLEMENTED")
        }
    }

    public init?(sequentialInfo info: UnsafeMutableRawPointer?, callbacks: CGDataProviderSequentialCallbacks) {
        providerType = .sequential(callbacks: callbacks)
        self.info = info
    }

    public init?(directInfo info: UnsafeMutableRawPointer?, size: off_t, callbacks: CGDataProviderDirectCallbacks) {
        providerType = .directAccess(callbacks: callbacks)
        self.info = info
    }

    public init?(dataInfo info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int, releaseCallback: CGDataProviderReleaseDataCallback?) {
        providerType = .directData(data: data, size: size, releaseCallback: releaseCallback)
        self.info = info
    }

    public init?(data: Data) {
        providerType = .data(data: data)
        info = nil
    }

    public init?(url: URL) {
        providerType = .url(url: url)
        info = nil
    }

    public init(filename: String) {
        providerType = .filename(filename: filename)
        info = nil
    }

    public var data: Data? {
        switch providerType {
            case .directData(let data, let size, _): return Data(bytes: data, count: size)
            case .data(let data): return data
            case .url(let url): return try? Data(contentsOf: url)
            case .filename(let filename): return FileManager.default.contents(atPath: filename)
            default: fatalError("NOT YET IMPLEMENTED")
        }
    }
}
