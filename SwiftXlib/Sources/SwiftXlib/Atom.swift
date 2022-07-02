//
//  Atom.swift
//  SwiftXlib
//
//  Created by Serhii Mumriak on 21.05.2022.
//

import Foundation
import TinyFoundation
import CXlib

public protocol AtomName: Hashable {
    var rawValue: String { get }
}

public struct UnknownAtomName: AtomName {
    public var rawValue: String
}

// smumriak: i can not imagine a way to make this strongly typed. X11 atoms are literally identifiers represented by arbitrary strings
public enum KnownAtomName: String, CaseIterable, AtomName {
    case takeFocus = "WM_TAKE_FOCUS"
    case deleteWindow = "WM_DELETE_WINDOW"
        
    case ping = "_NET_WM_PING"
    case syncRequest = "_NET_WM_SYNC_REQUEST"
    case fullscreenMonitors = "_NET_WM_FULLSCREEN_MONITORS"

    case normalHints = "WM_NORMAL_HINTS"
    case sizeHints = "WM_SIZE_HINTS"
    case hints = "WM_HINTS"
    case `class` = "WM_CLASS"
    case transientFor = "WM_TRANSIENT_FOR"
    case protocols = "WM_PROTOCOLS"
    case clientMachine = "WM_CLIENT_MACHINE"
    case iconSize = "WM_ICON_SIZE"
        
    case name = "_NET_WM_NAME"
    case visibleName = "_NET_WM_VISIBLE_NAME"
    case iconName = "_NET_WM_ICON_NAME"
    case desktopNumber = "_NET_WM_DESKTOP"
    case windowType = "_NET_WM_WINDOW_TYPE"
    case state = "_NET_WM_STATE"
    case allowedActions = "_NET_WM_ALLOWED_ACTIONS"
    case strut = "_NET_WM_STRUT"
    case strutPartial = "_NET_WM_STRUT_PARTIAL"
    case iconGeometry = "_NET_WM_ICON_GEOMETRY"
    case icon = "_NET_WM_ICON"
    case processIdentifier = "_NET_WM_PID"
    case userTime = "_NET_WM_USER_TIME"
    case userTimeWindow = "_NET_WM_USER_TIME_WINDOW"
    case frameExtents = "_NET_FRAME_EXTENTS"
    case opaqueRegion = "_NET_WM_OPAQUE_REGION"
    case bypassCompositor = "_NET_WM_BYPASS_COMPOSITOR"
    case opacity = "_NET_WM_WINDOW_OPACITY"

    case supportedHints = "_NET_SUPPORTED"
    case clientList = "_NET_CLIENT_LIST"
    case numberOfDesktops = "_NET_NUMBER_OF_DESKTOPS"
    case desktopGeometry = "_NET_DESKTOP_GEOMETRY"
    case desktopViewport = "_NET_DESKTOP_VIEWPORT"
    case currentDesktop = "_NET_CURRENT_DESKTOP"
    case desktopNames = "_NET_DESKTOP_NAMES"
    case activeWindow = "_NET_ACTIVE_WINDOW"
    case workarea = "_NET_WORKAREA"
    case supportingWmCheck = "_NET_SUPPORTING_WM_CHECK"
    case virtualRoots = "_NET_VIRTUAL_ROOTS"
    case desktopLayout = "_NET_DESKTOP_LAYOUT"
    case showingDesktop = "_NET_SHOWING_DESKTOP"

    case closeWindow = "_NET_CLOSE_WINDOW"
    case moveresizeWindow = "_NET_MOVERESIZE_WINDOW"
    case moveresize = "_NET_WM_MOVERESIZE"
    case restackWindow = "_NET_RESTACK_WINDOW"

    case stateModal = "_NET_WM_STATE_MODAL"
    case stateSticky = "_NET_WM_STATE_STICKY"
    case stateMaximizedVert = "_NET_WM_STATE_MAXIMIZED_VERT"
    case stateMaximizedHorz = "_NET_WM_STATE_MAXIMIZED_HORZ"
    case stateShaded = "_NET_WM_STATE_SHADED"
    case stateSkipTaskbar = "_NET_WM_STATE_SKIP_TASKBAR"
    case stateSkipPager = "_NET_WM_STATE_SKIP_PAGER"
    case stateHidden = "_NET_WM_STATE_HIDDEN"
    case stateFullscreen = "_NET_WM_STATE_FULLSCREEN"
    case stateAbove = "_NET_WM_STATE_ABOVE"
    case stateBelow = "_NET_WM_STATE_BELOW"
    case stateDemandsAttention = "_NET_WM_STATE_DEMANDS_ATTENTION"

    case windowTypeDesktop = "_NET_WM_WINDOW_TYPE_DESKTOP"
    case windowTypeDock = "_NET_WM_WINDOW_TYPE_DOCK"
    case windowTypeToolbar = "_NET_WM_WINDOW_TYPE_TOOLBAR"
    case windowTypeMenu = "_NET_WM_WINDOW_TYPE_MENU"
    case windowTypeUtility = "_NET_WM_WINDOW_TYPE_UTILITY"
    case windowTypeSplash = "_NET_WM_WINDOW_TYPE_SPLASH"
    case windowTypeDialog = "_NET_WM_WINDOW_TYPE_DIALOG"
    case windowTypeDropdownMenu = "_NET_WM_WINDOW_TYPE_DROPDOWN_MENU"
    case windowTypePopupMenu = "_NET_WM_WINDOW_TYPE_POPUP_MENU"
    case windowTypeTooltip = "_NET_WM_WINDOW_TYPE_TOOLTIP"
    case windowTypeNotification = "_NET_WM_WINDOW_TYPE_NOTIFICATION"
    case windowTypeCombo = "_NET_WM_WINDOW_TYPE_COMBO"
    case windowTypeDragged = "_NET_WM_WINDOW_TYPE_DND"
    case windowTypeNormal = "_NET_WM_WINDOW_TYPE_NORMAL"

    case actionMove = "_NET_WM_ACTION_MOVE"
    case actionResize = "_NET_WM_ACTION_RESIZE"
    case actionMinimize = "_NET_WM_ACTION_MINIMIZE"
    case actionShade = "_NET_WM_ACTION_SHADE"
    case actionStick = "_NET_WM_ACTION_STICK"
    case actionMaximizeHorizontal = "_NET_WM_ACTION_MAXIMIZE_HORZ"
    case actionMaximizeVertical = "_NET_WM_ACTION_MAXIMIZE_VERT"
    case actionTransitionToFullscreen = "_NET_WM_ACTION_FULLSCREEN"
    case actionChangeDesktop = "_NET_WM_ACTION_CHANGE_DESKTOP"
    case actionClose = "_NET_WM_ACTION_CLOSE"

    case syncCounter = "_NET_WM_SYNC_REQUEST_COUNTER"
    // case syncFences = "_NET_WM_SYNC_FENCES"
    // case syncDrawn = "_NET_WM_SYNC_DRAWN"
    case frameDrawn = "_NET_WM_FRAME_DRAWN"
    case frameTimings = "_NET_WM_FRAME_TIMINGS"

    case inputKeyboard = "KEYBOARD"
    case inputMouse = "MOUSE"
    case inputTablet = "TABLET"
    case inputTouchscreen = "TOUCHSCREEN"
    case inputTouchpad = "TOUCHPAD"
    case inputBarcode = "BARCODE"
    case inputButtonBox = "BUTTONBOX"
    case inputKnobBox = "KNOB_BOX"
    case inputOneKnob = "ONE_KNOB"
    case inputNineKnob = "NINE_KNOB"
    case inputTrackball = "TRACKBALL"
    case inputQuadrature = "QUADRATURE"
    case inputIdModule = "ID_MODULE"
    case inputSpaceball = "SPACEBALL"
    case inputDataGlove = "DATAGLOVE"
    // case inputEyeTracker = "EYETRACKER"
    // case inputCursorKeys = "CURSORKEYS"
    // case inputFootMouse = "FOOTMOUSE"
    // case inputJoystick = "JOYSTICK"
}
