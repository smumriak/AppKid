//
//  XInput2EventTypeMask.h
//  CXlib
//
//  Created by Serhii Mumriak on 23.12.2020.
//

#ifndef XInput2EventTypeMask_h
#define XInput2EventTypeMask_h 1

#include <X11/extensions/XInput2.h>
#include <X11/extensions/XI.h>

#include "../../../SharedSystemLibs/CCore/include/CCore.h"

typedef AK_OPTIONS(int32_t, XInput2EventTypeMask) {
    XInput2EventTypeMaskKeyPress = XI_KeyPressMask,
    XInput2EventTypeMaskKeyRelease = XI_KeyReleaseMask,
    XInput2EventTypeMaskButtonPress = XI_ButtonPressMask,
    XInput2EventTypeMaskButtonRelease = XI_ButtonReleaseMask,
    XInput2EventTypeMaskMotion = XI_MotionMask,
    XInput2EventTypeMaskEnter = XI_EnterMask,
    XInput2EventTypeMaskLeave = XI_LeaveMask,
    XInput2EventTypeMaskFocusIn = XI_FocusInMask,
    XInput2EventTypeMaskFocusOut = XI_FocusOutMask,
    XInput2EventTypeMaskHierarchyChanged = XI_HierarchyChangedMask,
    XInput2EventTypeMaskPropertyEvent = XI_PropertyEventMask,
    XInput2EventTypeMaskRawKeyPress = XI_RawKeyPressMask,
    XInput2EventTypeMaskRawKeyRelease = XI_RawKeyReleaseMask,
    XInput2EventTypeMaskRawButtonPress = XI_RawButtonPressMask,
    XInput2EventTypeMaskRawButtonRelease = XI_RawButtonReleaseMask,
    XInput2EventTypeMaskRawMotion = XI_RawMotionMask,
    XInput2EventTypeMaskTouchBegin = XI_TouchBeginMask,
    XInput2EventTypeMaskTouchEnd = XI_TouchEndMask,
    XInput2EventTypeMaskTouchOwnershipChanged = XI_TouchOwnershipChangedMask,
    XInput2EventTypeMaskTouchUpdate = XI_TouchUpdateMask,
    XInput2EventTypeMaskRawTouchBegin = XI_RawTouchBeginMask,
    XInput2EventTypeMaskRawTouchEnd = XI_RawTouchEndMask,
    XInput2EventTypeMaskRawTouchUpdate = XI_RawTouchUpdateMask,
    XInput2EventTypeMaskBarrierHit = XI_BarrierHitMask,
    XInput2EventTypeMaskBarrierLeave = XI_BarrierLeaveMask
};

#endif