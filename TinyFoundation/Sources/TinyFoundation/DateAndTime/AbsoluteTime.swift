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
                    // smumriak: Original is using CLOCK_MONOTONIC clock, but it's semantically wrong since CLOCK_MONOTONIC can be adjusted by syscall adjtime. Doc for mach_absolute_time tells that it's equivalent to clock_gettime_nsec_np(CLOCK_UPTIME_RAW), which means that we should use here CLOCK_MONOTONIC_RAW. BEWARE!!! CLOCK_MONOTONIC_RAW in mach kernel is not the same as in Linux
                    clock_gettime(CLOCK_MONOTONIC_RAW /* clock_id */,
                                  &timespec /* res */ )
                }
            } catch {
                assertionFailure("Sorry, failed to get current time from OS with error: \(error)")
            }
            return UInt64(timespec.tv_nsec) + UInt64(timespec.tv_sec * 1_000_000_000)
        #elseif os(Windows)
            return 0
        #else
            return 0
        #endif
    }
}
