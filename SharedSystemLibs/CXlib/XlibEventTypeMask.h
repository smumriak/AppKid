//
//  XlibEventTypeMask.h
//  CXlib
//
//  Created by Serhii Mumriak on 20.12.2020.
//

#ifndef XlibEventTypeMask_h
#define XlibEventTypeMask_h 1

#include <X11/X.h>

#include "../CCore/CCore_umbrella.h"

typedef AK_OPTIONS(int32_t, XlibEventTypeMask) {
    XlibEventTypeMaskNoEvent = NoEventMask,
    XlibEventTypeMaskKeyPress = KeyPressMask,
    XlibEventTypeMaskKeyRelease = KeyReleaseMask,
    XlibEventTypeMaskButtonPress = ButtonPressMask,
    XlibEventTypeMaskButtonRelease = ButtonReleaseMask,
    XlibEventTypeMaskEnterWindow = EnterWindowMask,
    XlibEventTypeMaskLeaveWindow = LeaveWindowMask,
    XlibEventTypeMaskPointerMotion = PointerMotionMask,
    XlibEventTypeMaskPointerMotionHint = PointerMotionHintMask,
    XlibEventTypeMaskButton1Motion = Button1MotionMask,
    XlibEventTypeMaskButton2Motion = Button2MotionMask,
    XlibEventTypeMaskButton3Motion = Button3MotionMask,
    XlibEventTypeMaskButton4Motion = Button4MotionMask,
    XlibEventTypeMaskButton5Motion = Button5MotionMask,
    XlibEventTypeMaskButtonMotion = ButtonMotionMask,
    XlibEventTypeMaskKeymapState = KeymapStateMask,
    XlibEventTypeMaskExposure = ExposureMask,
    XlibEventTypeMaskVisibilityChange = VisibilityChangeMask,
    XlibEventTypeMaskStructureNotify = StructureNotifyMask,
    XlibEventTypeMaskResizeRedirect = ResizeRedirectMask,
    XlibEventTypeMaskSubstructureNotify = SubstructureNotifyMask,
    XlibEventTypeMaskSubstructureRedirect = SubstructureRedirectMask,
    XlibEventTypeMaskFocusChange = FocusChangeMask,
    XlibEventTypeMaskPropertyChange = PropertyChangeMask,
    XlibEventTypeMaskColormapChange = ColormapChangeMask,
    XlibEventTypeMaskOwnerGrabButton = OwnerGrabButtonMask
};

#endif