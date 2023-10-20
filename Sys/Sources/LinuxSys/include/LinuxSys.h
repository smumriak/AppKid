//
//  LinuxSys_umbrella.h
//  LinuxSys
//  
//  Created by Serhii Mumriak on 11.01.2023
//

#ifndef LinuxSys_umbrella_h
#define LinuxSys_umbrella_h 1

#include "../../../../CCore/include/CCore.h"

#ifdef __linux__

AK_EXISTING_OPTIONS(EPOLL_EVENTS);

#include <sys/cdefs.h>
#include <sys/epoll.h>
#include <sys/eventfd.h>
#include <sys/param.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/sysinfo.h>
#include <sys/sysmacros.h>
#include <sys/timerfd.h>
#include <sys/types.h>
#include <sys/uio.h>

#include <dlfcn.h>
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <pthread.h>
#include <sched.h>
#include <unistd.h>

#include "wait_macros.h"

extern __pid_t gettid (void) __THROW;
extern int ppoll (struct pollfd *__fds, nfds_t __nfds,
		  const struct timespec *__timeout,
		  const __sigset_t *__ss)
    __fortified_attr_access (__write_only__, 1, 2);

#endif

#endif
