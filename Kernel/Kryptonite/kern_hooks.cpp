//
//  kern_hooks.cpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#include "kern_hooks.hpp"
#include <Headers/kern_api.hpp>

int FunctionHooks::thunderboltShouldSkipEnumeration() {
    SYSLOG(moduleName, "Skipping thunderbolt enumeration...");
    return 0;
}
