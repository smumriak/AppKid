//
//  OSNativeThreadLinux.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 16.01.2023
//

#if os(Linux) || os(Android) || os(OpenBSD)
    import CLinuxSys

    public typealias OSNativeThread = pthread_t
    public typealias OSNativeThreadAttributes = pthread_attr_t
    public typealias OSNativeThreadSpecificKey = pthread_key_t

    public extension OSNativeThread {
        @_transparent
        static var isMain: Bool {
            gettid() == getpid()
        }
    }
#endif
