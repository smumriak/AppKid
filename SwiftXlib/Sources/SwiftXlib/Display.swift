//
//  Display.swift
//  SwiftXlib
//
//  Created by Serhii Mumriak on 10.12.2020.
//

import Foundation
import TinyFoundation

import CXlib

extension CXlib.Display: ReleasableCType {
    public static var releaseFunc: (UnsafeMutablePointer<CXlib.Display>?) -> () {
        return {
            XCloseDisplay($0)
        }
    }
}

internal extension SharedPointer where Pointee == CXlib.Display {
    func queryKnownAtom(_ name: KnownAtomName) -> Atom {
        let result = XInternAtom(pointer, name.rawValue, 1)

        if result == CXlib.None {
            fatalError("X11 atom named \(name.rawValue) does not exist")
        }

        return result
    }
}

public class Display: SharedPointerStorage<CXlib.Display> {
    public let xInput2ExtensionOpcode: CInt

    internal var atoms: [String: CXlib.Atom]

    public let connectionFileDescriptor: CInt
    
    public private(set) lazy var rootWindow = RootWindow(display: self, screen: screens[0])
    public private(set) var screens: [Screen] = [Screen()]

    public init(_ display: String? = nil) throws {
        guard let pointer = XOpenDisplay(display) ?? XOpenDisplay(nil) ?? XOpenDisplay(":0") else {
            throw XlibError.failedToOpenDisplay
        }

        let handle = ReleasablePointer(with: pointer)

        let knownAtomNames = KnownAtomName.allCases

        let knownAtoms = knownAtomNames.map {
            ($0.rawValue, handle.queryKnownAtom($0))
        }

        atoms = Dictionary(uniqueKeysWithValues: knownAtoms)

        var event: CInt = 0
        var error: CInt = 0

        if XSyncQueryExtension(pointer, &event, &error) == 0 {
            throw XlibError.missingExtension(.sync)
        }

        var xSyncMajorVersion: CInt = 3
        var xSyncMinorVersion: CInt = 1
        if XSyncInitialize(pointer, &xSyncMajorVersion, &xSyncMinorVersion) == 0 {
            throw XlibError.missingExtension(.sync)
        }

        var xInput2ExtensionOpcode: CInt = 0

        if XQueryExtension(pointer, "XInputExtension".cString(using: .ascii), &xInput2ExtensionOpcode, &event, &error) == 0 {
            throw XlibError.missingExtension(.input2)
        }

        self.xInput2ExtensionOpcode = xInput2ExtensionOpcode

        var xInputMajorVersion: CInt = 2
        var xInputMinorVersion: CInt = 0
        if XIQueryVersion(pointer, &xInputMajorVersion, &xInputMinorVersion) == BadRequest {
            throw XlibError.missingExtension(.input2)
        }

        self.connectionFileDescriptor = XConnectionNumber(pointer)

        super.init(handle: handle)
    }

    public func flush() {
        XFlush(pointer)
    }

    public func withLocked<T>(_ body: (Display) throws -> (T)) rethrows -> T {
        XLockDisplay(pointer)
        defer { XUnlockDisplay(pointer) }

        return try body(self)
    }

    public func knownAtom(_ name: KnownAtomName) -> CXlib.Atom {
        return atoms[name.rawValue]!
    }

    public func getAtom<T: AtomName>(_ name: T, onlyIfExists: Bool = false) -> CXlib.Atom? {
        if let result = atoms[name.rawValue] {
            return result
        }

        let result = XInternAtom(pointer, name.rawValue, onlyIfExists ? 1 : 0)

        if result == CXlib.None {
            return nil
        } else {
            atoms[name.rawValue] = result
            return result
        }
    }
}
