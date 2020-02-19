//
//  CCairo_umbrella.h
//  SwiftyFan
//
//  Created by Serhii Mumriak on 3/2/20.
//

#ifndef CCairo_umbrella_h
#define CCairo_umbrella_h 1

struct _cairo {};
struct _cairo_surface {};
struct _cairo_pattern {};
struct _cairo_font_options {};

#include <cairo.h>
#if defined(__linux__)
#include <cairo-xlib.h>
#endif

#endif
