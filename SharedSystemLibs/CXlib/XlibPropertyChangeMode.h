//
//  XlibPropertyChangeMode.h
//  CXlib
//
//  Created by Serhii Mumriak on 13.02.2021.
//

#ifndef XlibPropertyChangeMode_h
#define XlibPropertyChangeMode_h 1

#include <X11/X.h>

#include "../CCore/include/CCore.h"

typedef AK_ENUM(int32_t, XlibPropertyChangeMode) {
    XlibPropertyChangeModeReplace = PropModeReplace,
    XlibPropertyChangeModePrepend = PropModePrepend,
    XlibPropertyChangeModeAppend = PropModeAppend,
};

#endif