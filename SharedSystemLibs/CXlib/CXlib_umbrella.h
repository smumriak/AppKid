//
//  CXlib_umbrella.h
//  AppKid
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

#ifndef XLIB_ILLEGAL_ACCESS
#define XLIB_ILLEGAL_ACCESS 1
#endif

#include <X11/X.h> 
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xos.h>
#include <X11/XKBlib.h>
#include <X11/Xatom.h>
#include <X11/extensions/sync.h>
#include <X11/extensions/Xrandr.h> 
#include <X11/extensions/XInput2.h>
#include <X11/extensions/XI.h>

#include "../CCore/CCore_umbrella.h"

#include "XlibResult.h"
#include "XlibEventKeyMask.h"
#include "XlibEventButtonMask.h"
#include "XlibEventButtonName.h"
#include "XlibEventTypeMask.h"
#include "XlibEventType.h"
#include "X11ModifierKeySymbol.h"
#include "XInput2EventType.h"
#include "XInput2EventTypeMask.h"

static inline char *XGetInputMethodStyles(XIM inputMethod, XIMStyles **styles) {
    return XGetIMValues(inputMethod, XNQueryInputStyle, styles, NULL);
}

static inline XIC XCreateInputContext(XIM inputMethod, XIMStyle style, Window window) {
    return XCreateIC(inputMethod, XNInputStyle, style, XNClientWindow, window, XNFocusWindow, window, NULL);
}

#endif
