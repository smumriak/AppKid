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

public enum AtomName: String {
    case deleteWindow = "WM_DELETE_WINDOW"
    case takeFocus = "WM_TAKE_FOCUS"
    case sizeHints = "WM_SIZE_HINTS"

    case syncRequest = "_NET_WM_SYNC_REQUEST"
    case syncCounter = "_NET_WM_SYNC_REQUEST_COUNTER"
    case syncFences = "_NET_WM_SYNC_FENCES"
    case syncDrawn = "_NET_WM_SYNC_DRAWN"
    case frameTimings = "_NET_WM_FRAME_TIMINGS"

    case state = "_NET_WM_STATE"
    case stayAbove = "_NET_WM_STATE_ABOVE"
    case stayBelow = "_NET_WM_STATE_BELOW"
    case stateMaximizedVertical = "_NET_WM_STATE_MAXIMIZED_VERT"
    case stateMaximizedHorizontal = "_NET_WM_STATE_MAXIMIZED_HORZ"
    case stateFullscreen = "_NET_WM_STATE_FULLSCREEN"
    
    case opacity = "_NET_WM_WINDOW_OPACITY"
    
    case desktopWindowType = "_NET_WM_WINDOW_TYPE_DESKTOP"
    case dockWindowType = "_NET_WM_WINDOW_TYPE_DOCK"
    case toolbarWindowType = "_NET_WM_WINDOW_TYPE_TOOLBAR"
    case menuWindowType = "_NET_WM_WINDOW_TYPE_MENU"
    case utilityWindowType = "_NET_WM_WINDOW_TYPE_UTILITY"
    case splashWindowType = "_NET_WM_WINDOW_TYPE_SPLASH"
    case dialogWindowType = "_NET_WM_WINDOW_TYPE_DIALOG"
    case normalWindowType = "_NET_WM_WINDOW_TYPE_NORMAL"
    
    case xiKeyboard = "KEYBOARD"
    case xiMouse = "MOUSE"
    case xiTablet = "TABLET"
    case xiTouchscreen = "TOUCHSCREEN"
    case xiTouchpad = "TOUCHPAD"
    case xiBarcode = "BARCODE"
    case xiButtonBox = "BUTTONBOX"
    case xiKnobBox = "KNOB_BOX"
    case xiOneKnob = "ONE_KNOB"
    case xiNineKnob = "NINE_KNOB"
    case xiTrackball = "TRACKBALL"
    case xiQuadrature = "QUADRATURE"
    case xiIdModule = "ID_MODULE"
    case xiSpaceball = "SPACEBALL"
    case xiDataGlove = "DATAGLOVE"
    case xiEyeTracker = "EYETRACKER"
    case xiCursorKeys = "CURSORKEYS"
    case xiFootMouse = "FOOTMOUSE"
    case xiJoystick = "JOYSTICK"
}

internal extension SmartPointer where Pointee == CXlib.Display {
    func query(atom: AtomName, onlyIfExists: Bool = false) -> CXlib.Atom {
        XInternAtom(pointer, atom.rawValue, onlyIfExists ? 1 : 0)
    }
}

public class Display: HandleStorage<SmartPointer<CXlib.Display>> {
    public let xInput2ExtensionOpcode: CInt

    public let deleteWindowAtom: CXlib.Atom
    public let takeFocusAtom: CXlib.Atom
    public let sizeHintsAtom: CXlib.Atom

    public let syncRequestAtom: CXlib.Atom
    public let syncCounterAtom: CXlib.Atom
    public let syncFencesAtom: CXlib.Atom
    public let syncDrawnAtom: CXlib.Atom

    public let frameTimingsAtom: CXlib.Atom

    public let stateAtom: CXlib.Atom
    public let stayAboveAtom: CXlib.Atom
    public let stayBelowAtom: CXlib.Atom
    public let stateMaximizedVerticalAtom: CXlib.Atom
    public let stateMaximizedHorizontalAtom: CXlib.Atom
    public let stateFullscreenAtom: CXlib.Atom

    public let opacityAtom: CXlib.Atom

    public let desktopWindowTypeAtom: CXlib.Atom
    public let dockWindowTypeAtom: CXlib.Atom
    public let toolbarWindowTypeAtom: CXlib.Atom
    public let menuWindowTypeAtom: CXlib.Atom
    public let utilityWindowTypeAtom: CXlib.Atom
    public let splashWindowTypeAtom: CXlib.Atom
    public let dialogWindowTypeAtom: CXlib.Atom
    public let normalWindowTypeAtom: CXlib.Atom

    public let xiKeyboardAtom: CXlib.Atom
    public let xiMouseAtom: CXlib.Atom
    public let xiTabletAtom: CXlib.Atom
    public let xiTouchscreenAtom: CXlib.Atom
    public let xiTouchpadAtom: CXlib.Atom
    public let xiBarcodeAtom: CXlib.Atom
    public let xiButtonBoxAtom: CXlib.Atom
    public let xiKnobBoxAtom: CXlib.Atom
    public let xiOneKnobAtom: CXlib.Atom
    public let xiNineKnobAtom: CXlib.Atom
    public let xiTrackballAtom: CXlib.Atom
    public let xiQuadratureAtom: CXlib.Atom
    public let xiIdModuleAtom: CXlib.Atom
    public let xiSpaceballAtom: CXlib.Atom
    public let xiDataGloveAtom: CXlib.Atom
    public let xiEyeTrackerAtom: CXlib.Atom
    public let xiCursorKeysAtom: CXlib.Atom
    public let xiFootMouseAtom: CXlib.Atom
    public let xiJoystickAtom: CXlib.Atom

    public let connectionFileDescriptor: CInt

    public internal(set) var screens: [Screen] = []

    public init(_ display: String? = nil) throws {
        guard let handle = XOpenDisplay(display) ?? XOpenDisplay(nil) ?? XOpenDisplay(":0") else {
            throw XlibError.failedToOpenDisplay
        }

        let handlePointer = ReleasablePointer(with: handle)

        deleteWindowAtom = handlePointer.query(atom: .deleteWindow)
        takeFocusAtom = handlePointer.query(atom: .takeFocus)
        sizeHintsAtom = handlePointer.query(atom: .sizeHints)

        syncRequestAtom = handlePointer.query(atom: .syncRequest)
        syncCounterAtom = handlePointer.query(atom: .syncCounter)
        syncFencesAtom = handlePointer.query(atom: .syncFences)
        syncDrawnAtom = handlePointer.query(atom: .syncDrawn)

        frameTimingsAtom = handlePointer.query(atom: .frameTimings)

        stateAtom = handlePointer.query(atom: .state)
        stayAboveAtom = handlePointer.query(atom: .stayAbove)
        stayBelowAtom = handlePointer.query(atom: .stayBelow)
        stateMaximizedVerticalAtom = handlePointer.query(atom: .stateMaximizedVertical)
        stateMaximizedHorizontalAtom = handlePointer.query(atom: .stateMaximizedHorizontal)
        stateFullscreenAtom = handlePointer.query(atom: .stateFullscreen)

        opacityAtom = handlePointer.query(atom: .opacity)

        desktopWindowTypeAtom = handlePointer.query(atom: .desktopWindowType)
        dockWindowTypeAtom = handlePointer.query(atom: .dockWindowType)
        toolbarWindowTypeAtom = handlePointer.query(atom: .toolbarWindowType)
        menuWindowTypeAtom = handlePointer.query(atom: .menuWindowType)
        utilityWindowTypeAtom = handlePointer.query(atom: .utilityWindowType)
        splashWindowTypeAtom = handlePointer.query(atom: .splashWindowType)
        dialogWindowTypeAtom = handlePointer.query(atom: .dialogWindowType)
        normalWindowTypeAtom = handlePointer.query(atom: .normalWindowType)

        xiKeyboardAtom = handlePointer.query(atom: .xiKeyboard)
        xiMouseAtom = handlePointer.query(atom: .xiMouse)
        xiTabletAtom = handlePointer.query(atom: .xiTablet)
        xiTouchscreenAtom = handlePointer.query(atom: .xiTouchscreen)
        xiTouchpadAtom = handlePointer.query(atom: .xiTouchpad)
        xiBarcodeAtom = handlePointer.query(atom: .xiBarcode)
        xiButtonBoxAtom = handlePointer.query(atom: .xiButtonBox)
        xiKnobBoxAtom = handlePointer.query(atom: .xiKnobBox)
        xiOneKnobAtom = handlePointer.query(atom: .xiOneKnob)
        xiNineKnobAtom = handlePointer.query(atom: .xiNineKnob)
        xiTrackballAtom = handlePointer.query(atom: .xiTrackball)
        xiQuadratureAtom = handlePointer.query(atom: .xiQuadrature)
        xiIdModuleAtom = handlePointer.query(atom: .xiIdModule)
        xiSpaceballAtom = handlePointer.query(atom: .xiSpaceball)
        xiDataGloveAtom = handlePointer.query(atom: .xiDataGlove)
        xiEyeTrackerAtom = handlePointer.query(atom: .xiEyeTracker)
        xiCursorKeysAtom = handlePointer.query(atom: .xiCursorKeys)
        xiFootMouseAtom = handlePointer.query(atom: .xiFootMouse)
        xiJoystickAtom = handlePointer.query(atom: .xiJoystick)

        var event: CInt = 0
        var error: CInt = 0

        if XSyncQueryExtension(handle, &event, &error) == 0 {
            throw XlibError.missingExtension(.sync)
        }

        var xSyncMajorVersion: CInt = 3
        var xSyncMinorVersion: CInt = 1
        if XSyncInitialize(handle, &xSyncMajorVersion, &xSyncMinorVersion) == 0 {
            throw XlibError.missingExtension(.sync)
        }

        var xInput2ExtensionOpcode: CInt = 0

        if XQueryExtension(handle, "XInputExtension".cString(using: .ascii), &xInput2ExtensionOpcode, &event, &error) == 0 {
            throw XlibError.missingExtension(.input2)
        }

        self.xInput2ExtensionOpcode = xInput2ExtensionOpcode

        var xInputMajorVersion: CInt = 2
        var xInputMinorVersion: CInt = 0
        if XIQueryVersion(handle, &xInputMajorVersion, &xInputMinorVersion) == BadRequest {
            throw XlibError.missingExtension(.input2)
        }

        self.connectionFileDescriptor = XConnectionNumber(handle)

        super.init(handlePointer: handlePointer)
    }

    public func flush() {
        XFlush(handle)
    }

    public func withLocked<T>(_ body: (Display) throws -> (T)) rethrows -> T {
        XLockDisplay(handle)
        defer { XUnlockDisplay(handle) }

        return try body(self)
    }
}
