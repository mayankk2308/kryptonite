//
//  kern_compat.cpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#include "kern_compatibility.hpp"

bool Compatibility::isUnsupported() {
    SYSLOG(moduleName, "Kernel: %d.%d", version_major, version_minor);
    
    bool c = (version_major < minVersion) | (version_major == minVersion & version_minor < minMinorVersion);
    
    SYSLOG(moduleName, "System supported: %d", !c);
    
    return c;
}

bool Compatibility::isOlderKernel() {
    bool c = (version_major < oldVersion) | (version_major == oldVersion & version_minor < oldMinorVersion);
    
    SYSLOG(moduleName, "Is older kernel: %d", c);
    
    return c;
}
