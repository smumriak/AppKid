//
//  syscall.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 02.02.2023
//

#if canImport(LinuxSys)
    import LinuxSys
#endif

#if canImport(Glibc)
    import Glibc
#endif

#if os(Linux) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(Android) || os(OpenBSD)
    @discardableResult
    @_transparent
    public func syscall<T: BinaryInteger>(_ invocation: () -> (T)) throws -> T {
        var result: T = 0
        repeat {
            result = invocation()
        } while result == -1 && result == EINTR

        switch result {
            case -1: throw POSIXErrorCode(rawValue: errno)!
            default: return result
        }
    }
#endif

@discardableResult
@_transparent
public func syscall<T: BinaryInteger>(_ invocation: @autoclosure () -> (T)) throws -> T {
    try syscall {
        invocation()
    }
}
