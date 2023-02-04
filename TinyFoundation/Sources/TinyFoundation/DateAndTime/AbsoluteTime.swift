//
//  AbsoluteTime.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 20.01.2023
//
#if canImport(LinuxSys)
    import LinuxSys
#endif

#if canImport(GLibc)
    import Glibc
#endif

#if canImport(Darwin)
    import Darwin
#endif

#if canImport(WinSDK)
    import WinSDK
#endif

public extension UInt64 {
    @_transparent
    static var absoluteTime: UInt64 {
        #if os(Linux) || os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(Android) || os(OpenBSD)
            var timespec = timespec()
            do {
                try syscall {
                    clock_gettime(CLOCK_MONOTONIC /* clock_id */,
                                  &timespec /* res */ )
                }
            } catch {
                assertionFailure("Sorry, failed to get current time from OS with error: \(error)")
            }
            return UInt64(timespec.tv_nsec) + UInt64(timespec.tv_sec * 1000000000)
        #elseif os(Windows)
            return 0
        #else
            return 0
        #endif
    }
}
