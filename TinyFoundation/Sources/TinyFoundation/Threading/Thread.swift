//
//  Thread.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 13.01.2023
//

// This code was salvaged from swift-corelibs-foundation project located at https://github.com/apple/swift-corelibs-foundation/blob/3c390df83b75a2bb362cacd2fc7f64e8b31123f0/Sources/Foundation/Thread.swift
// Original code was distributed under Apache License 2.0 located at https://github.com/apple/swift-corelibs-foundation/blob/3c390df83b75a2bb362cacd2fc7f64e8b31123f0/LICENSE
// The reason for salvaging is this thread https://forums.swift.org/t/what-s-next-for-foundation/61939
// Only small part was salvaged that is needed by Lock classes in the first iteration
// Thanks all swift-corelibs-foundation contributors for ability to preserve functionality of Thread family of classes

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

#else
    #if canImport(CLinuxSys)
        import CLinuxSys
    #endif

    #if os(Windows)
        internal typealias _swift_CFThreadRef = HANDLE
    #else
        internal typealias _swift_CFThreadRef = pthread_t
    #endif
#endif
