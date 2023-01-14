//
//  module.modulemap
//  SwiftyGLib
//
//  Created by Serhii Mumriak on 20.11.2021.
//

#ifndef CGlib_umbrella_h
#define CGlib_umbrella_h 1

#include "../../../CCore/include/CCore.h"

#ifndef __cplusplus

struct _GMainContext {};
struct _GMainLoop {};

#endif

#include <glib.h>

#endif /* CGlib_umbrella_h */