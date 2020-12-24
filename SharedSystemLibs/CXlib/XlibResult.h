//
//  XlibResult.h
//  CXlib
//
//  Created by Serhii Mumriak on 20.12.2020.
//

#ifndef XlibResult_h
#define XlibResult_h 1

#include <X11/X.h>

#include "../CCore/CCore_umbrella.h"

typedef AK_ENUM(int32_t, XlibResult) {
    XlibResultBadAccess = BadAccess,
    XlibResultBadAlloc = BadAlloc,
    XlibResultBadAtom = BadAtom,
    XlibResultBadColor = BadColor,
    XlibResultBadCursor = BadCursor,
    XlibResultBadDrawable = BadDrawable,
    XlibResultBadFont = BadFont,
    XlibResultBadGC = BadGC,
    XlibResultBadIDChoice = BadIDChoice,
    XlibResultBadImplementation = BadImplementation,
    XlibResultBadLength = BadLength,
    XlibResultBadMatch = BadMatch,
    XlibResultBadName = BadName,
    XlibResultBadPixmap = BadPixmap,
    XlibResultBadRequest = BadRequest,
    XlibResultBadValue = BadValue,
    XlibResultBadWindow = BadWindow,
};

#endif