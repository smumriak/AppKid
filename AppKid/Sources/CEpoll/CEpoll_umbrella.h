//
//  CEpoll_umbrella.h
//  SwiftyFan
//
//  Created by Serhii Mumriak on 29.01.2020.
//

#ifndef CEpoll_umbrella_h
#define CEpoll_umbrella_h 1

#if defined(__linux__)
#include <sys/epoll.h>
#include <sys/eventfd.h>
#include <unistd.h>
#endif

#include "../../../Shared/CCore/CCore_umbrella.h"

#endif
