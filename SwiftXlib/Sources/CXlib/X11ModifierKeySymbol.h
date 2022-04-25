//
//  X11ModifierKeySymbol.h
//  CXlib
//
//  Created by Serhii Mumriak on 23.12.2020.
//

#ifndef X11ModifierKeySymbol_h
#define X11ModifierKeySymbol_h 1

#include <X11/X.h>

#include "../../../CCore/CCore.h"

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

#endif