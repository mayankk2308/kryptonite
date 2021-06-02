//
//  kern_nvdapatch.cpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#include "kern_nvdapatch.hpp"
#include <Headers/kern_api.hpp>

OSDefineMetaClassAndStructors(NVDAPatched, NVDA)

#define super NVDA

bool NVDAPatched::attach(IOService *provider) {
    SYSLOG(NVDAPatched::moduleName, "Overriding attach(...) behavior...");
    bool ret = super::attach(provider);
    SYSLOG(NVDAPatched::moduleName, "Attach: %d", ret);
    if (!ret) {
        ret = IOGraphicsDevice::attach(provider);
        SYSLOG(NVDAPatched::moduleName, "Attach (new): %d", ret);
    }
    return ret;
}
