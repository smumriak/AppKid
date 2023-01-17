//
//  HijackingHacks.h
//  TinyFoundation
//  
//  Created by Serhii Mumriak on 11.01.2023
//

#ifndef HijackingHacks_h
#define HijackingHacks_h 1

#if TARGET_OS_OSX || TARGET_OS_IPHONE || TARGET_OS_TV || TARGET_OS_SIMULATOR || TARGET_OS_MACCATALYST
typedef mach_port_t port_t;
#elif defined(__linux__)
typedef int port_t;
#elif TARGET_OS_WIN32 || TARGET_OS_CYGWIN
typedef HANDLE port_t;
#else 
typedef void * port_t;
#endif

#include <stdbool.h>
#include <inttypes.h>

#if defined(__cplusplus)
    #define HJ_EXTERN extern "C"
#else
    #define HJ_EXTERN extern
#endif

typedef struct dispatch_queue_s {} *dispatch_queue_t;
typedef struct dispatch_source_s {} *dispatch_source_t;
typedef struct dispatch_time_s {} *dispatch_time_t;

HJ_EXTERN port_t _dispatch_get_main_queue_port_4CF(void);
HJ_EXTERN void _dispatch_main_queue_callback_4CF(void * _Null_unspecified);
HJ_EXTERN port_t _dispatch_runloop_root_queue_get_port_4CF(dispatch_queue_t _Nonnull queue);
HJ_EXTERN bool _dispatch_runloop_root_queue_perform_4CF(dispatch_queue_t _Nonnull queue);
HJ_EXTERN dispatch_queue_t _Nonnull _dispatch_runloop_root_queue_create_4CF(const char *_Nullable label, unsigned long flags);
HJ_EXTERN void _dispatch_source_set_runloop_timer_4CF(dispatch_source_t _Nonnull source, dispatch_time_t _Nonnull start, uint64_t interval, uint64_t leeway);

#endif