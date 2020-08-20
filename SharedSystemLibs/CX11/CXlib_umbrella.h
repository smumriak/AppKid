//
//  CXlib_umbrella.h
//  SwiftyFan
//
//  Created by Serhii Mumriak on 29.01.2020.
//

#ifndef CXlib_umbrella_h
#define CXlib_umbrella_h 1

#ifndef XLIB_ILLEGAL_ACCESS
#define XLIB_ILLEGAL_ACCESS 1
#endif
#ifndef NeedWidePrototypes
#define NeedWidePrototypes 1
#endif

struct _XIM {};
struct _XIC {};

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xos.h>
#include <X11/XKBlib.h>
#include <X11/Xatom.h>
#include <X11/extensions/sync.h>

#include "../CCore/CCore_umbrella.h"

typedef AK_ENUM(KeySym, X11ModifierKeySymbol) {
    X11ModifierKeySymbolLeftShift = XK_Shift_L,
    X11ModifierKeySymbolRightShift = XK_Shift_R,
    X11ModifierKeySymbolLeftControl = XK_Control_L,
    X11ModifierKeySymbolRightControl = XK_Control_R,
    X11ModifierKeySymbolCaps = XK_Caps_Lock,
    X11ModifierKeySymbolShift = XK_Shift_Lock,
    X11ModifierKeySymbolLeftMeta = XK_Meta_L,
    X11ModifierKeySymbolRightMeta = XK_Meta_R,
    X11ModifierKeySymbolLeftAlt = XK_Alt_L,
    X11ModifierKeySymbolRightAlt = XK_Alt_R,
    X11ModifierKeySymbolLeftSuper = XK_Super_L,
    X11ModifierKeySymbolRightSuper = XK_Super_R,
    X11ModifierKeySymbolLeftHyper = XK_Hyper_L,
    X11ModifierKeySymbolRightHyper = XK_Hyper_R,
    X11ModifierKeySymbolModeSwitch = XK_Mode_switch,
    X11ModifierKeySymbolLevel3Shift = XK_ISO_Level3_Shift
};

static inline char *XGetInputMethodStyles(XIM inputMethod, XIMStyles **styles) {
    return XGetIMValues(inputMethod, XNQueryInputStyle, styles, NULL);
}

static inline XIC XCreateInputContext(XIM inputMethod, XIMStyle style, Window window) {
    return XCreateIC(inputMethod, XNInputStyle, style, XNClientWindow, window, XNFocusWindow, window, NULL);
}

#endif
