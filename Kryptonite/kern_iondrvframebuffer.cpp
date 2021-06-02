//
//  kern_iondrvframebuffer.cpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#include "kern_iondrvframebuffer.hpp"
#include <Headers/kern_api.hpp>

OSDefineMetaClassAndStructors(IONDRVFramebufferPatched, IONDRVFramebuffer)

#define super IONDRVFramebuffer

bool IONDRVFramebufferPatched::attach(IOService *provider) {
    SYSLOG(IONDRVFramebufferPatched::moduleName, "Overriding attach(...) behavior...");
    bool ret = super::attach(provider);
    SYSLOG(IONDRVFramebufferPatched::moduleName, "Attach: %d", ret);
    if (!ret) {
        ret = IOGraphicsDevice::attach(provider);
        SYSLOG(IONDRVFramebufferPatched::moduleName, "Attach (new): %d", ret);
    }
    return ret;
}
