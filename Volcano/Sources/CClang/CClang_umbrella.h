//
//  CClang_umbrella.h
//  CClang
//
//  Created by Serhii Mumriak on 13.06.2021.
//

#ifndef CClang_umbrella_h
#define CClang_umbrella_h 1

#include "../../../CCore/include/CCore.h"

struct CXTranslationUnitImpl {};

AK_EXISTING_ENUM(CXCursorKind);
AK_EXISTING_ENUM(CXChildVisitResult);
AK_EXISTING_ENUM(CXTypeKind);
AK_EXISTING_OPTIONS(CXTranslationUnit_Flags);

#include <clang-c/Index.h>

#endif
