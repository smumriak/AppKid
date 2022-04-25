//
//  XlibEventType.h
//  CXlib
//
//  Created by Serhii Mumriak on 20.12.2020.
//

#ifndef XlibEventType_h
#define XlibEventType_h 1

#include <X11/X.h>

#include "../../../CCore/include/CCore.h"

typedef AK_ENUM(int32_t, XlibEventType) {
    XlibEventTypeKeyPress = KeyPress,
    XlibEventTypeKeyRelease = KeyRelease,
    XlibEventTypeButtonPress = ButtonPress,
    XlibEventTypeButtonRelease = ButtonRelease,
    XlibEventTypeMotionNotify = MotionNotify,
    XlibEventTypeEnterNotify = EnterNotify,
    XlibEventTypeLeaveNotify = LeaveNotify,
    XlibEventTypeFocusIn = FocusIn,
    XlibEventTypeFocusOut = FocusOut,
    XlibEventTypeKeymapNotify = KeymapNotify,
    XlibEventTypeExpose = Expose,
    XlibEventTypeGraphicsExpose = GraphicsExpose,
    XlibEventTypeNoExpose = NoExpose,
    XlibEventTypeVisibilityNotify = VisibilityNotify,
    XlibEventTypeCreateNotify = CreateNotify,
    XlibEventTypeDestroyNotify = DestroyNotify,
    XlibEventTypeUnmapNotify = UnmapNotify,
    XlibEventTypeMapNotify = MapNotify,
    XlibEventTypeMapRequest = MapRequest,
    XlibEventTypeReparentNotify = ReparentNotify,
    XlibEventTypeConfigureNotify = ConfigureNotify,
    XlibEventTypeConfigureRequest = ConfigureRequest,
    XlibEventTypeGravityNotify = GravityNotify,
    XlibEventTypeResizeRequest = ResizeRequest,
    XlibEventTypeCirculateNotify = CirculateNotify,
    XlibEventTypeCirculateRequest = CirculateRequest,
    XlibEventTypePropertyNotify = PropertyNotify,
    XlibEventTypeSelectionClear = SelectionClear,
    XlibEventTypeSelectionRequest = SelectionRequest,
    XlibEventTypeSelectionNotify = SelectionNotify,
    XlibEventTypeColormapNotify = ColormapNotify,
    XlibEventTypeClientMessage = ClientMessage,
    XlibEventTypeMappingNotify = MappingNotify,
    XlibEventTypeGenericEvent = GenericEvent
};
#endif