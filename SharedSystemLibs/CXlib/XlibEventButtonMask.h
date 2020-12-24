//
//  XlibEventButtonMask.h
//  CXlib
//
//  Created by Serhii Mumriak on 20.12.2020.
//

#ifndef XlibEventButtonMask_h
#define XlibEventButtonMask_h 1

#include <X11/X.h>

#include "../CCore/CCore_umbrella.h"

typedef AK_OPTIONS(int32_t, XlibEventButtonMask) {
    XlibEventButtonMaskOne = Button1Mask,
    XlibEventButtonMaskTwo = Button2Mask,
    XlibEventButtonMaskThree = Button3Mask,
    XlibEventButtonMaskFour = Button4Mask,
    XlibEventButtonMaskFive = Button5Mask,
    XlibEventButtonMaskAny = AnyModifier,
};

#endif