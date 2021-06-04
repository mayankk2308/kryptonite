#include <Headers/plugin_start.hpp>
#include <Headers/kern_api.hpp>

#include "kern_patchset.hpp"
#include "kern_compatibility.hpp"

static PatchSet patchSet;

static const char *bootargOff[] {
    "-krydisable"
};

static const char *bootargDbg[] {
    "-krydbg"
};

static const char *bootargBeta[] {
    "-krybeta"
};

void start() {
    if (Compatibility::isUnsupported()) {
        SYSLOG("startup", "System is not supported.");
        return;
    }
    
    patchSet.init();
}

PluginConfiguration ADDPR(config) {
    xStringify(PRODUCT_NAME),
    parseModuleVersion(xStringify(MODULE_VERSION)),
    LiluAPI::AllowNormal,
    bootargOff,
    arrsize(bootargOff),
    bootargDbg,
    arrsize(bootargDbg),
    bootargBeta,
    arrsize(bootargBeta),
    KernelVersion::HighSierra,
    KernelVersion::BigSur,
    start
};
