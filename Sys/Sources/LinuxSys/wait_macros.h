//
//  macros.h
//  LinuxSys
//  
//  Created by Serhii Mumriak on 04.07.2023
//

#include <stdbool.h> 
#include <sys/wait.h>

static inline int wExitStatus(int status) { return WEXITSTATUS(status); }
static inline int wTerminationSiggnal(int status) { return WTERMSIG(status); }
static inline int wStopSignal(int status) { return WSTOPSIG(status); }
static inline bool wIfExited(int status) { return WIFEXITED(status); }
static inline bool wIfSignaled(int status) { return WIFSIGNALED(status); }
static inline bool wIfStopped(int status) { return WIFSTOPPED(status); }
#if defined(WIFCONTINUED)
    static inline bool wIfContinued(int status) { return WIFCONTINUED(status); }
#endif