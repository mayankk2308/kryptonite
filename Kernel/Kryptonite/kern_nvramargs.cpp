//
//  kern_nvramargs.cpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#include "kern_nvramargs.hpp"
#include <Headers/kern_iokit.hpp>
#include <Headers/kern_api.hpp>

void NVRAMArgs::getGPU() {
    if (!PE_parse_boot_argn(gpuArg, &gpu, sizeof(gpu))) {
        SYSLOG(moduleName, "GPU vendor args not found.");
        return;
    }
    
    SYSLOG(moduleName, "GPU vendor: %s", gpu);
}

void NVRAMArgs::init() {
    getGPU();
}

bool NVRAMArgs::isAMD() {
    return !strcmp(gpu, amd);
}

bool NVRAMArgs::isNVDA() {
    return !strcmp(gpu, nvda);
}
