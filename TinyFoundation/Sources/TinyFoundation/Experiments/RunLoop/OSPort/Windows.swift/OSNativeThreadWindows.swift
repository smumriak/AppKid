//
//  OSNativeThreadWindows.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 16.01.2023
//

#if os(Windows)
    import WinSDK

    public typealias OSNativeThread = HANDLE
    public typealias OSNativeThreadAttributes = (dwSizeOfAttributes: CUnsignedLong, dwThreadStackReservation: CUnsignedLong)
    public typealias OSNativeThreadSpecificKey = CUnsignedLong
        
    public extension OSNativeThread {
        internal(set) static lazy var initialThread: HANDLE = {
            var result: HANDLE = INVALID_HANDLE_VALUE
            DuplicateHandle(GetCurrentProcess(), GetCurrentThread(),
                            GetCurrentProcess(), &result, 0, 0,
                            DUPLICATE_SAME_ACCESS)
            return result
        }()

        @_transparent
        static var isMain: Bool {
            CompareObjectHandles(OSThread.initialThread, GetCurrentThread()) == 1
        }
    }
#endif
