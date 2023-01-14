//
//  Lock.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 13.01.2023
//

// This code was salvaged from swift-corelibs-foundation project located at https://github.com/apple/swift-corelibs-foundation/blob/3c390df83b75a2bb362cacd2fc7f64e8b31123f0/Sources/Foundation/NSLock.swift
// Original code was distributed under Apache License 2.0 located at https://github.com/apple/swift-corelibs-foundation/blob/3c390df83b75a2bb362cacd2fc7f64e8b31123f0/LICENSE
// The reason for salvaging is this thread https://forums.swift.org/t/what-s-next-for-foundation/61939
// After salvaging original code was heavily modified to use more convenience features that swift provides and is not source-compatible with original
// Thanks all swift-corelibs-foundation contributors for ability to preserve functionality of Lock family of classes

import Foundation

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    public typealias LockProtocol = NSLocking
    public typealias Lock = NSLock
    public typealias RecursiveLock = NSRecursiveLock
#else
    #if canImport(CLinuxSys)
        import CLinuxSys
    #endif

    #if os(Windows)
        import WinSDK
    #endif

    public protocol LockProtocol: NSLocking {
        func lock()
        func unlock()
    }

    extension NSLock: LockProtocol {}
    extension NSRecursiveLock: LockProtocol {}
    extension NSConditionLock: LockProtocol {}

    @_transparent
    fileprivate func newOSMutex() -> Lock.Mutex {
        let result = Lock.Mutex.allocate(capacity: 1, deleter: Lock.MutexDeleter)
        #if os(Windows)
            InitializeSRWLock(result.pointer)
        #else
            pthread_mutex_init(result.pointer, nil)
        #endif
        return result
    }

    @_transparent
    fileprivate func newOSRecursiveMutex() -> Lock.RecursiveMutex {
        let result = Lock.RecursiveMutex.allocate(capacity: 1, deleter: Lock.RecursiveMutexDeleter)
        #if os(Windows)
            InitializeCriticalSection(result.pointer)
        #else
            #if CYGWIN || os(OpenBSD)
                var attributes: pthread_mutexattr_t? = nil
            #else
                var attributes = pthread_mutexattr_t()
            #endif
            withUnsafeMutablePointer(to: &attributes) { attributes in
                pthread_mutexattr_init(attributes)
                #if os(OpenBSD)
                    let type = Int32(PTHREAD_MUTEX_RECURSIVE.rawValue)
                #else
                    let type = Int32(PTHREAD_MUTEX_RECURSIVE)
                #endif
                pthread_mutexattr_settype(attributes, type)
                pthread_mutex_init(result.pointer, attributes)
            }
        #endif
        return result
    }

    @_transparent
    fileprivate func newOSConditionalVariable() -> Lock.ConditionVariable {
        let result = Lock.ConditionVariable.allocate(capacity: 1, deleter: Lock.ConditionVariableDeleter)
        #if os(Windows)
            InitializeConditionVariable(result.pointer)
        #else
            pthread_cond_init(result.pointer, nil)
        #endif
        return result
    }

    public final class Lock: LockProtocol {
        internal var mutex = newOSMutex()

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(Windows)
            private var timeoutConditionalVariable = newOSConditionalVariable()
            private var timeoutMutex = newOSMutex()
        #endif
        public var name: String?

        public init() {}

        public func lock() {
            mutex.lock()
        }

        public func unlock() {
            #if os(Windows)
                mutex.unlock()
                timeoutMutex.lock()
                WakeAllConditionVariable(timeoutConditionalVariable.pointer)
                timeoutMutex.unlock()
            #else
                mutex.unlock()
                #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
                    timeoutMutex.lock()
                    pthread_cond_broadcast(timeoutConditionalVariable.pointer)
                    timeoutMutex.unlock()
                #endif
            #endif
        }
    
        public func `try`() -> Bool {
            #if os(Windows)
                mutex.try() != 0
            #else
                mutex.try() == 0
            #endif
        }

        public func lock(before limit: Date) -> Bool {
            #if os(Windows)
                if mutex.try() != 0 {
                    return true
                }
            #else
                if mutex.try() == 0 {
                    return true
                }
            #endif

            #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(Windows)
                return timedLock(mutex: mutex.pointer, endTime: limit, using: timeoutConditionalVariable.pointer, with: timeoutMutex.pointer)
            #else
                guard var endTime = limit.timeSpec else {
                    return false
                }
                #if os(WASI)
                    return true
                #else
                    return pthread_mutex_timedlock(mutex.pointer, &endTime) == 0
                #endif
            #endif
        }
    }

    public final class RecursiveLock: LockProtocol {
        internal var mutex = newOSRecursiveMutex()

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(Windows)
            private var timeoutConditionalVariable = newOSConditionalVariable()
            private var timeoutMutex = newOSMutex()
        #endif
        public var name: String?

        public init() {}

        public func lock() {
            mutex.lock()
        }

        public func unlock() {
            #if os(Windows)
                mutex.unlock()
                timeoutMutex.lock()
                WakeAllConditionVariable(timeoutConditionalVariable.pointer)
                timeoutMutex.unlock()
            #else
                mutex.unlock()
                #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
                    timeoutMutex.lock()
                    pthread_cond_broadcast(timeoutConditionalVariable.pointer)
                    timeoutMutex.unlock()
                #endif
            #endif
        }
    
        public func `try`() -> Bool {
            #if os(Windows)
                mutex.try() != 0
            #else
                mutex.try() == 0
            #endif
        }

        public func lock(before limit: Date) -> Bool {
            #if os(Windows)
                if mutex.try() != 0 {
                    return true
                }
            #else
                if mutex.try() == 0 {
                    return true
                }
            #endif

            #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(Windows)
                return timedLock(mutex: mutex.pointer, endTime: limit, using: timeoutConditionalVariable.pointer, with: timeoutMutex.pointer)
            #else
                guard var endTime = limit.timeSpec else {
                    return false
                }
                #if os(WASI)
                    return true
                #else
                    return pthread_mutex_timedlock(mutex.pointer, &endTime) == 0
                #endif
            #endif
        }
    }

    #if !os(WASI)
        // open class ConditionLock: LockProtocol {
        //     internal var _cond = Condition()
        //     internal var _value: Int
        //     internal var _thread: _swift_CFThreadRef?
    
        //     public override convenience init() {
        //         self.init(condition: 0)
        //     }
    
        //     public init(condition: Int) {
        //         _value = condition
        //     }

        //     open func lock() {
        //         let _ = lock(before: Date.distantFuture)
        //     }

        //     open func unlock() {
        //         _cond.lock()
        //         #if os(Windows)
        //             _thread = INVALID_HANDLE_VALUE
        //         #else
        //             _thread = nil
        //         #endif
        //         _cond.broadcast()
        //         _cond.unlock()
        //     }
    
        //     open var condition: Int {
        //         return _value
        //     }

        //     open func lock(whenCondition condition: Int) {
        //         let _ = lock(whenCondition: condition, before: Date.distantFuture)
        //     }

        //     open func `try`() -> Bool {
        //         return lock(before: Date.distantPast)
        //     }
    
        //     open func tryLock(whenCondition condition: Int) -> Bool {
        //         return lock(whenCondition: condition, before: Date.distantPast)
        //     }

        //     open func unlock(withCondition condition: Int) {
        //         _cond.lock()
        //         #if os(Windows)
        //             _thread = INVALID_HANDLE_VALUE
        //         #else
        //             _thread = nil
        //         #endif
        //         _value = condition
        //         _cond.broadcast()
        //         _cond.unlock()
        //     }

        //     open func lock(before limit: Date) -> Bool {
        //         _cond.lock()
        //         while _thread != nil {
        //             if !_cond.wait(until: limit) {
        //                 _cond.unlock()
        //                 return false
        //             }
        //         }
        //         #if os(Windows)
        //             _thread = GetCurrentThread()
        //         #else
        //             _thread = pthread_self()
        //         #endif
        //         _cond.unlock()
        //         return true
        //     }
    
        //     open func lock(whenCondition condition: Int, before limit: Date) -> Bool {
        //         _cond.lock()
        //         while _thread != nil || _value != condition {
        //             if !_cond.wait(until: limit) {
        //                 _cond.unlock()
        //                 return false
        //             }
        //         }
        //         #if os(Windows)
        //             _thread = GetCurrentThread()
        //         #else
        //             _thread = pthread_self()
        //         #endif
        //         _cond.unlock()
        //         return true
        //     }
    
        //     open var name: String?
        // }
    #endif

    // open class Condition: LockProtocol {
    //     internal var mutex = _MutexPointer.allocate(capacity: 1)
    //     internal var cond = _ConditionVariablePointer.allocate(capacity: 1)

    //     public override init() {
    //         #if os(Windows)
    //             InitializeSRWLock(mutex)
    //             InitializeConditionVariable(cond)
    //         #else
    //             pthread_mutex_init(mutex, nil)
    //             pthread_cond_init(cond, nil)
    //         #endif
    //     }
    
    //     deinit {
    //         #if os(Windows)
    //         // SRWLock do not need to be explicitly destroyed
    //         #else
    //             pthread_mutex_destroy(mutex)
    //             pthread_cond_destroy(cond)
    //         #endif
    //         mutex.deinitialize(count: 1)
    //         cond.deinitialize(count: 1)
    //         mutex.deallocate()
    //         cond.deallocate()
    //     }
    
    //     open func lock() {
    //         #if os(Windows)
    //             AcquireSRWLockExclusive(mutex)
    //         #else
    //             pthread_mutex_lock(mutex)
    //         #endif
    //     }
    
    //     open func unlock() {
    //         #if os(Windows)
    //             ReleaseSRWLockExclusive(mutex)
    //         #else
    //             pthread_mutex_unlock(mutex)
    //         #endif
    //     }
    
    //     open func wait() {
    //         #if os(Windows)
    //             SleepConditionVariableSRW(cond, mutex, WinSDK.INFINITE, 0)
    //         #else
    //             pthread_cond_wait(cond, mutex)
    //         #endif
    //     }

    //     open func wait(until limit: Date) -> Bool {
    //         #if os(Windows)
    //             return SleepConditionVariableSRW(cond, mutex, timeoutFrom(date: limit), 0)
    //         #else
    //             guard var timeout = timeSpecFrom(date: limit) else {
    //                 return false
    //             }
    //             return pthread_cond_timedwait(cond, mutex, &timeout) == 0
    //         #endif
    //     }
    
    //     open func signal() {
    //         #if os(Windows)
    //             WakeConditionVariable(cond)
    //         #else
    //             pthread_cond_signal(cond)
    //         #endif
    //     }
    
    //     open func broadcast() {
    //         #if os(Windows)
    //             WakeAllConditionVariable(cond)
    //         #else
    //             pthread_cond_broadcast(cond)
    //         #endif
    //     }
    
    //     open var name: String?
    // }

    internal extension Lock {
        #if os(Windows)
            typealias Mutex = SharedPointer<SRWLOCK>
            static var MutexDeleter: Mutex.Deleter = .system

            typealias RecursiveMutex = SharedPointer<CRITICAL_SECTION>
            static var RecursiveMutexDeleter: RecursiveMutex.Deleter = .custom {
                DeleteCriticalSection($0)
                $0.deallocate
            }

            typealias ConditionVariable = SharedPointer<CONDITION_VARIABLE>
            static var ConditionVariableDeleter: ConditionVariable.Deleter = .system

        #elseif CYGWIN || os(OpenBSD)
            typealias Mutex = SharedPointer<pthread_mutex_t?>
            static var MutexDeleter: Mutex.Deleter = .custom {
                pthread_mutex_destroy($0)
                $0.deallocate()
            }

            typealias RecursiveMutex = SharedPointer<pthread_mutex_t?>
            static var RecursiveMutexDeleter: RecursiveMutex.Deleter = .custom {
                pthread_mutex_destroy($0)
                $0.deallocate()
            }

            typealias ConditionVariable = SharedPointer<pthread_cond_t?>
            static var ConditionVariableDeleter: ConditionVariable.Deleter = .custom {
                pthread_cond_destroy($0)
                $0.deallocate()
            }

        #else
            typealias Mutex = SharedPointer<pthread_mutex_t>
            static var MutexDeleter: Mutex.Deleter = .custom {
                pthread_mutex_destroy($0)
                $0.deallocate()
            }

            typealias RecursiveMutex = SharedPointer<pthread_mutex_t>
            static var RecursiveMutexDeleter: RecursiveMutex.Deleter = .custom {
                pthread_mutex_destroy($0)
                $0.deallocate()
            }

            typealias ConditionVariable = SharedPointer<pthread_cond_t>
            static var ConditionVariableDeleter: ConditionVariable.Deleter = .custom {
                pthread_cond_destroy($0)
                $0.deallocate()
            }
        #endif
    }

    fileprivate extension Date {
        #if os(Windows)
            @_transparent
            var timeout: Int {
                let timeIntervalSinceNow = timeIntervalSinceNow
                if timeIntervalSinceNow <= 0 {
                    return 0
                } else {
                    return Int(timeIntervalSinceNow * 1000)
                }
            }
        #else
            @_transparent
            var timeSpec: timespec? {
                if timeIntervalSinceNow <= 0 {
                    return nil
                } else {
                    let nsecPerSec: Int64 = 1000000000
                    let intervalNS = Int64(timeIntervalSince1970 * Double(nsecPerSec))

                    return timespec(tv_sec: time_t(intervalNS / nsecPerSec),
                                    tv_nsec: Int(intervalNS % nsecPerSec))
                }
            }
        #endif
    }

    fileprivate protocol OSNativeLock {
        associatedtype ErrorCode: BinaryInteger

        @inline(__always)
        func lock() -> ErrorCode
        
        @inline(__always)
        func unlock() -> ErrorCode
        
        @inline(__always)
        func `try`() -> ErrorCode
    }

    #if os(Windows)
        extension Lock.Mutex: OSNativeLock {
            @_transparent @discardableResult
            func lock() -> UInt8 {
                AcquireSRWLockExclusive(pointer)
            }

            @_transparent @discardableResult
            func unlock() -> UInt8 {
                ReleaseSRWLockExclusive(pointer)
            }

            @_transparent @discardableResult
            func `try`() -> UInt8 {
                TryAcquireSRWLockExclusive(pointer)
            }
        }

        extension Lock.RecursiveMutex: OSNativeLock {
            @_transparent @discardableResult
            func lock() -> UInt8 {
                EnterCriticalSection(pointer)
            }

            @_transparent @discardableResult
            func unlock() -> UInt8 {
                LeaveCriticalSection(pointer)
            }

            @_transparent @discardableResult
            func `try`() -> UInt8 {
                TryEnterCriticalSection(pointer)
            }
        }

        extension Lock.ConditionVariable {
        }

    #elseif CYGWIN || os(OpenBSD)
        extension Lock.Mutex: OSNativeLock {
            @_transparent
            static func newMutex() -> Lock.Mutex {
                let result = Lock.Mutex.allocate(capacity: 1, deleter: Lock.MutexDeleter)
                pthread_mutex_init(result.pointer, nil)
                return result
            }

            @_transparent @discardableResult
            func lock() -> CInt {
                pthread_mutex_lock(pointer)
            }

            @_transparent @discardableResult
            func unlock() -> CInt {
                pthread_mutex_unlock(pointer)
            }

            @_transparent @discardableResult
            func `try`() -> CInt {
                pthread_mutex_trylock(pointer)
            }
        }
    #else
        extension Lock.Mutex: OSNativeLock {
            @_transparent @discardableResult
            func lock() -> CInt {
                pthread_mutex_lock(pointer)
            }

            @_transparent @discardableResult
            func unlock() -> CInt {
                pthread_mutex_unlock(pointer)
            }

            @_transparent @discardableResult
            func `try`() -> CInt {
                pthread_mutex_trylock(pointer)
            }
        }
    #endif

    #if os(Windows)
        @_transparent
        fileprivate func timedLock<T: OSNativeLock>(mutex: T, endTime: Date,
                                                    using timeoutConditionalVariable: Lock.ConditionVariable,
                                                    with timeoutMutex: Lock.Mutex) -> Bool {
            repeat {
                timeoutMutex.lock()
                SleepConditionVariableSRW(timeoutConditionalVariable.pointer, timeoutMutex.pointer, timeoutFrom(date: endTime), 0)
                timeoutMutex.unlock()
                if mutex.try() != 0 {
                    return true
                }
            } while timeoutFrom(date: endTime) != 0
            return false
        }
    // #elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    #else
        @_transparent
        fileprivate func timedLock<T: OSNativeLock>(mutex: T, endTime: Date,
                                                    using timeoutConditionalVariable: Lock.ConditionVariable,
                                                    with timeoutMutex: Lock.Mutex) -> Bool {
            while var ts = endTime.timeSpec {
                let lockval = timeoutMutex.lock()
                precondition(lockval == 0)
                let waitval = pthread_cond_timedwait(timeoutConditionalVariable.pointer, timeoutMutex.pointer, &ts)
                precondition(waitval == 0 || waitval == ETIMEDOUT)
                let unlockval = timeoutMutex.unlock()
                precondition(unlockval == 0)

                if waitval == ETIMEDOUT {
                    return false
                }
                let tryval = mutex.try()
                precondition(tryval == 0 || tryval == EBUSY)
                if tryval == 0 { // The lock was obtained.
                    return true
                }
            }
            return false
        }
    #endif
#endif
