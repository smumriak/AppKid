//
//  CXInput2_umbrella.h
//  SwiftyFan
//
//  Created by Serhii Mumriak on 21.04.2020.
//

#ifndef CXInput2_umbrella_h
#define CXInput2_umbrella_h 1

#include <X11/extensions/XInput2.h>

#include "../CCore/CCore_umbrella.h"

typedef AK_ENUM(int32_t, XInput2EventType) {
    XInput2EventTypeDeviceChanged = XI_DeviceChanged,
    XInput2EventTypeKeyPress = XI_KeyPress,
    XInput2EventTypeKeyRelease = XI_KeyRelease,
    XInput2EventTypeButtonPress = XI_ButtonPress,
    XInput2EventTypeButtonRelease = XI_ButtonRelease,
    XInput2EventTypeMotion = XI_Motion,
    XInput2EventTypeEnter = XI_Enter,
    XInput2EventTypeLeave = XI_Leave,
    XInput2EventTypeFocusIn = XI_FocusIn,
    XInput2EventTypeFocusOut = XI_FocusOut,
    XInput2EventTypeHierarchyChanged = XI_HierarchyChanged,
    XInput2EventTypePropertyEvent = XI_PropertyEvent,
    XInput2EventTypeRawKeyPress = XI_RawKeyPress,
    XInput2EventTypeRawKeyRelease = XI_RawKeyRelease,
    XInput2EventTypeRawButtonPress = XI_RawButtonPress,
    XInput2EventTypeRawButtonRelease = XI_RawButtonRelease,
    XInput2EventTypeRawMotion = XI_RawMotion,
    XInput2EventTypeTouchBegin = XI_TouchBegin,
    XInput2EventTypeTouchUpdate = XI_TouchUpdate,
    XInput2EventTypeTouchEnd = XI_TouchEnd,
    XInput2EventTypeTouchOwnership = XI_TouchOwnership,
    XInput2EventTypeRawTouchBegin = XI_RawTouchBegin,
    XInput2EventTypeRawTouchUpdate = XI_RawTouchUpdate,
    XInput2EventTypeRawTouchEnd = XI_RawTouchEnd,
    XInput2EventTypeBarrierHit = XI_BarrierHit,
    XInput2EventTypeBarrierLeave = XI_BarrierLeave
};

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
