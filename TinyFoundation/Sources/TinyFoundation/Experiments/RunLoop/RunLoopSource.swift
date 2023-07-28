//
//  RunLoopSource.swift
//  TinyFoundation
//
//  Created by Serhii Mumriak on 14.01.2023
//

import Atomics

#if !(os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
    public protocol RunLoopSourceContext0: AnyObject, Hashable, Equatable {
        func didSchedule(runLoop: RunLoop1, mode: RunLoop1.Mode)
        func didCancel(runLoop: RunLoop1, mode: RunLoop1.Mode)
        func perform()
    }

    public protocol RunLoopSourceContext1: AnyObject, Hashable, Equatable {
        associatedtype Port: OSPortProtocol
        var port: Port { get }
        func perform()
    }

    public extension RunLoopSourceContext0 {
        func didSchedule(runLoop: RunLoop1, mode: RunLoop1.Mode) {}
        func didCancel(runLoop: RunLoop1, mode: RunLoop1.Mode) {}
    }

    public extension RunLoop1 {
        final class Source: Hashable {
            internal let lock = RecursiveLock()
            // smumriak: only used for source 0
            public let order: Int
        
            @inlinable @inline(__always)
            @TFValid
            public internal(set) var isValid: Bool = true

            // smumriak: original CoreFoundation code performs compareExchange operation with acquire then release rules for success and failure. this code does not need that since it explicitly checks initial state on every operation, so it is safe to use atomic release storage operation
            @AtomicAcquiring
            internal var signaledTime: UInt64 = 0
        
            internal let context: Context
            internal var runLoops: [RunLoop1] = []
        
            internal enum Context {
                case zero(_ context: any RunLoopSourceContext0)
                case one(_ context: any RunLoopSourceContext1)

                @_transparent
                func perform() {
                    switch self {
                        case let .zero(context):
                            context.perform()
                    
                        case let .one(context):
                            context.perform()
                    }
                }

                @_transparent
                func didSchedule(runLoop: RunLoop1, mode: RunLoop1.Mode) {
                    switch self {
                        case let .zero(context):
                            context.didSchedule(runLoop: runLoop, mode: mode)

                        case .one(_):
                            break
                    }
                }

                @_transparent
                func didCancel(runLoop: RunLoop1, mode: RunLoop1.Mode) {
                    switch self {
                        case let .zero(context):
                            context.didCancel(runLoop: runLoop, mode: mode)

                        case .one(_):
                            break
                    }
                }

                @_transparent
                func cleanupOnDeinit(runLoop: RunLoop1, mode: RunLoopMode, name: RunLoop1.Mode) {
                    switch self {
                        case let .zero(context):
                            // smumriak: This is cleanup for source 0
                            context.didCancel(runLoop: runLoop, mode: name)

                        case let .one(context):
                            // smumriak: This is cleanup for source 1. original code calls getPort as a form of callout at this point
                            do {
                                try mode.portSet.removePort(context.port)
                            } catch {
                                fatalError("Sorry, RunLoop failed to remove native OS port from port set: \(error.localizedDescription)")
                            }
                    }
                }

                @_transparent
                func addTo(portSet: inout OSPortSet) {
                    switch self {
                        case .zero(_):
                            break

                        case let .one(context):
                            do {
                                try portSet.addPort(context.port)
                            } catch {
                                fatalError("Sorry, RunLoop failed to add native OS port to port set: \(error.localizedDescription)")
                            }
                    }
                }

                @_transparent
                func removeFrom(portSet: inout OSPortSet) {
                    switch self {
                        case .zero(_):
                            break

                        case let .one(context):
                            do {
                                try portSet.removePort(context.port)
                            } catch {
                                fatalError("Sorry, RunLoop failed to remove native OS port from port set: \(error.localizedDescription)")
                            }
                    }
                }
            }

            public var isSignaled: Bool {
                switch context {
                    case .zero(_): return signaledTime != 0
                    case .one(_): return false
                }
            }

            deinit {
                invalidate()
            }
        
            public init<T: RunLoopSourceContext0>(order: Int, context: T) {
                self.order = order
                self.context = .zero(context)
            }

            public init<T: RunLoopSourceContext1>(order: Int, context: T) {
                self.order = order
                self.context = .one(context)
            }

            public func signal() {
                switch context {
                    case .one(_):
                        // NO-OP
                        break

                    case .zero(_):
                        guard isValid else { return }
                }
            }

            public func invalidate() {
                guard isValid else { return }
            
                lock.synchronized {
                    isValid = false

                    if runLoops.isEmpty == false {
                        lock.desynchronized {
                            runLoops.forEach {
                                $0.removeSource(self)
                            }
                        }
                    }
                }
            }

            public func hash(into hasher: inout Hasher) {
                hasher.combine(ObjectIdentifier(self))
            }

            public static func == (lhs: Source, rhs: Source) -> Bool {
                return lhs === rhs
            }
        }

        @_transparent
        internal func removeSource(_ source: Source) {
            lock.synchronized {
                commonModeItems.sources.remove(source)
                modes.values.forEach { mode in
                    mode.removeSource(source)
                }
            }
        }

        func addSource(_ source: Source, mode modeName: Mode) {
            lock.synchronized {
                if modeName == .common {
                    commonModeItems.sources.insert(source)
                    commonModes.forEach {
                        modes[$0]?.addSource(source)
                    }
                } else {
                    modes[modeName]?.addSource(source)
                }
            }
        }

        func removeSource(_ source: Source, mode modeName: Mode) {
            lock.synchronized {
                if modeName == .common {
                    commonModeItems.sources.remove(source)
                    commonModes.forEach {
                        modes[$0]?.removeSource(source)
                    }
                } else {
                    modes[modeName]?.removeSource(source)
                }
            }
        }
    }

#endif
