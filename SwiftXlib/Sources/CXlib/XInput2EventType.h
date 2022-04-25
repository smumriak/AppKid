//
//  XInput2EventType.h
//  CXlib
//
//  Created by Serhii Mumriak on 23.12.2020.
//

#ifndef XInput2EventType_h
#define XInput2EventType_h 1

#include <X11/extensions/XInput2.h>
#include <X11/extensions/XI.h>

#include "../../../CCore/include/CCore.h"

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

#endif