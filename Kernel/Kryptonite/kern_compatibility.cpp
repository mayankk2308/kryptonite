//
//  kern_compat.cpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#include "kern_compatibility.hpp"

void Compatibility::init() {
    version = getKernelVersion();
    minorVersion = getKernelMinorVersion();
    
    SYSLOG(moduleName, "Kernel: %d.%d", version, minorVersion);
}

bool Compatibility::isUnsupported() {
    bool c = (version < minVersion) | (version == minVersion & minorVersion < minMinorVersion);
    
    SYSLOG(moduleName, "System supported: %d", !c);
    
    return c;
}
