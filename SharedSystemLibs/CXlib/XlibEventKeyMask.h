//
//  XlibEventKeyMask.h
//  CXlib
//
//  Created by Serhii Mumriak on 20.12.2020.
//

#ifndef XlibEventKeyMask_h
#define XlibEventKeyMask_h 1

#include <X11/X.h>

#include "../CCore/include/CCore.h"

typedef AK_OPTIONS(int32_t, XlibEventKeyMask) {
    XlibEventKeyMaskShift = ShiftMask,
    XlibEventKeyMaskLock = LockMask,
    XlibEventKeyMaskControl = ControlMask,
    XlibEventKeyMaskMod1 = Mod1Mask,
    XlibEventKeyMaskMod2 = Mod2Mask,
    XlibEventKeyMaskMod3 = Mod3Mask,
    XlibEventKeyMaskMod4 = Mod4Mask,
    XlibEventKeyMaskMod5 = Mod5Mask,
};

#endif