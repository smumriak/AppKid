//
//  CEpoll_umbrella.h
//  SwiftyFan
//
//  Created by Serhii Mumriak on 29.01.2020.
//

#ifndef CEpoll_umbrella_h
#define CEpoll_umbrella_h 1

#include "../CCore/CCore_umbrella.h"

#if defined(__linux__)

AK_EXISTING_ENUM(POSIXErrorCode);
AK_EXISTING_OPTIONS(EPOLL_EVENTS);

#include <sys/epoll.h>
#include <sys/eventfd.h>
#include <unistd.h>

#endif


#endif
