//
//  CX_umbrella.h
//  SwiftyFan
//
//  Created by Serhii Mumriak on 29.01.2020.
//

#ifndef CX_umbrella_h
#define CX_umbrella_h 1

#ifndef XLIB_ILLEGAL_ACCESS
#define XLIB_ILLEGAL_ACCESS 1
#endif

#include <X11/X.h>

#include "../CCore/CCore_umbrella.h"

typedef AK_ENUM(int32_t, X11EventType) {
    X11EventTypeKeyPress = KeyPress,
    X11EventTypeKeyRelease = KeyRelease,
    X11EventTypeButtonPress = ButtonPress,
    X11EventTypeButtonRelease = ButtonRelease,
    X11EventTypeMotionNotify = MotionNotify,
    X11EventTypeEnterNotify = EnterNotify,
    X11EventTypeLeaveNotify = LeaveNotify,
    X11EventTypeFocusIn = FocusIn,
    X11EventTypeFocusOut = FocusOut,
    X11EventTypeKeymapNotify = KeymapNotify,
    X11EventTypeExpose = Expose,
    X11EventTypeGraphicsExpose = GraphicsExpose,
    X11EventTypeNoExpose = NoExpose,
    X11EventTypeVisibilityNotify = VisibilityNotify,
    X11EventTypeCreateNotify = CreateNotify,
    X11EventTypeDestroyNotify = DestroyNotify,
    X11EventTypeUnmapNotify = UnmapNotify,
    X11EventTypeMapNotify = MapNotify,
    X11EventTypeMapRequest = MapRequest,
    X11EventTypeReparentNotify = ReparentNotify,
    X11EventTypeConfigureNotify = ConfigureNotify,
    X11EventTypeConfigureRequest = ConfigureRequest,
    X11EventTypeGravityNotify = GravityNotify,
    X11EventTypeResizeRequest = ResizeRequest,
    X11EventTypeCirculateNotify = CirculateNotify,
    X11EventTypeCirculateRequest = CirculateRequest,
    X11EventTypePropertyNotify = PropertyNotify,
    X11EventTypeSelectionClear = SelectionClear,
    X11EventTypeSelectionRequest = SelectionRequest,
    X11EventTypeSelectionNotify = SelectionNotify,
    X11EventTypeColormapNotify = ColormapNotify,
    X11EventTypeClientMessage = ClientMessage,
    X11EventTypeMappingNotify = MappingNotify,
    X11EventTypeGenericEvent = GenericEvent
};

typedef AK_OPTIONS(int32_t, X11EventTypeMask) {
    X11EventTypeMaskNoEvent = NoEventMask,
    X11EventTypeMaskKeyPress = KeyPressMask,
    X11EventTypeMaskKeyRelease = KeyReleaseMask,
    X11EventTypeMaskButtonPress = ButtonPressMask,
    X11EventTypeMaskButtonRelease = ButtonReleaseMask,
    X11EventTypeMaskEnterWindow = EnterWindowMask,
    X11EventTypeMaskLeaveWindow = LeaveWindowMask,
    X11EventTypeMaskPointerMotion = PointerMotionMask,
    X11EventTypeMaskPointerMotionHint = PointerMotionHintMask,
    X11EventTypeMaskButton1Motion = Button1MotionMask,
    X11EventTypeMaskButton2Motion = Button2MotionMask,
    X11EventTypeMaskButton3Motion = Button3MotionMask,
    X11EventTypeMaskButton4Motion = Button4MotionMask,
    X11EventTypeMaskButton5Motion = Button5MotionMask,
    X11EventTypeMaskButtonMotion = ButtonMotionMask,
    X11EventTypeMaskKeymapState = KeymapStateMask,
    X11EventTypeMaskExposure = ExposureMask,
    X11EventTypeMaskVisibilityChange = VisibilityChangeMask,
    X11EventTypeMaskStructureNotify = StructureNotifyMask,
    X11EventTypeMaskResizeRedirect = ResizeRedirectMask,
    X11EventTypeMaskSubstructureNotify = SubstructureNotifyMask,
    X11EventTypeMaskSubstructureRedirect = SubstructureRedirectMask,
    X11EventTypeMaskFocusChange = FocusChangeMask,
    X11EventTypeMaskPropertyChange = PropertyChangeMask,
    X11EventTypeMaskColormapChange = ColormapChangeMask,
    X11EventTypeMaskOwnerGrabButton = OwnerGrabButtonMask
};

#endif
