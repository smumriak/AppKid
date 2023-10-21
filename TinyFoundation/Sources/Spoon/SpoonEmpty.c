//
//  Spoon.c
//  Cuisine
//  
//  Created by Serhii Mumriak on 19.10.2023
//

#include "Spoon.h"
#include <unistd.h>

int spoon(int (*_Nonnull child)(void *_Nullable info), void *_Nullable info) {
    int result = vfork();

    if (result == 0) {
        // forked process
        int ret = child(info);
        // TODO: Handle the POSIX error here and propagate it to caller in future
    }

    return result;
}