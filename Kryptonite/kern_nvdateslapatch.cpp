//
//  kern_nvdateslapatch.cpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#include "kern_nvdateslapatch.hpp"
#include <Headers/kern_api.hpp>

OSDefineMetaClassAndStructors(NVDATeslaPatched, NVDATesla)

#define super NVDATesla

bool NVDATeslaPatched::attach(IOService *provider) {
    SYSLOG(NVDATeslaPatched::moduleName, "Overriding attach(...) behavior...");
    bool ret = super::attach(provider);
    SYSLOG(NVDATeslaPatched::moduleName, "Attach: %d", ret);
    if (!ret) {
        ret = IOGraphicsDevice::attach(provider);
        SYSLOG(NVDATeslaPatched::moduleName, "Attach (new): %d", ret);
    }
    return ret;
}
