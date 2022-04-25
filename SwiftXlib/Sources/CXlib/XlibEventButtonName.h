//
//  XlibEventButtonName.h
//  CXlib
//
//  Created by Serhii Mumriak on 20.12.2020.
//

#ifndef XlibEventButtonName_h
#define XlibEventButtonName_h 1

#include <X11/X.h>

#include "../../../CCore/CCore.h"

typedef AK_CLOSED_ENUM(int32_t, XlibEventButtonName) {
    XlibEventButtonNameOne = Button1,
    XlibEventButtonNameTwo = Button2,
    XlibEventButtonNameThree = Button3,
    XlibEventButtonNameFour = Button4,
    XlibEventButtonNameFive = Button5
};

#endif