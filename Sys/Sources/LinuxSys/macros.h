//
//  macros.h
//  LinuxSys
//  
//  Created by Serhii Mumriak on 04.07.2023
//

#include <stdbool.h> 

static inline bool wExitStatus(int status) {return WEXITSTATUS(status); }
static inline bool wTerminationSiggnal(int status) {return WTERMINATIONSIGGNAL(status); }
static inline bool wStopSignal(int status) {return WSTOPSIGNAL(status); }
static inline bool wIfExited(int status) {return WIFEXITED(status); }
static inline bool wIfSignaled(int status) {return WIFSIGNALED(status); }
static inline bool wIfStopped(int status) {return WIFSTOPPED(status); }
