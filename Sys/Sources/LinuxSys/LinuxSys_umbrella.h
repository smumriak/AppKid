//
//  LinuxSys_umbrella.h
//  LinuxSys
//  
//  Created by Serhii Mumriak on 11.01.2023
//

#ifndef LinuxSys_umbrella_h
#define LinuxSys_umbrella_h 1

#include "../../../CCore/include/CCore.h"

#ifdef __linux__

#define _GNU_SOURCE

AK_EXISTING_OPTIONS(EPOLL_EVENTS);

#include <sys/epoll.h>
#include <sys/eventfd.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/sysinfo.h>
#include <sys/timerfd.h>
#include <sys/types.h>

#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <pthread.h>
#include <sched.h>
#include <unistd.h>

#endif

#endif
