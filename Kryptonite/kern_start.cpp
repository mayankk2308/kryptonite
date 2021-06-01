#include <Headers/plugin_start.hpp>
#include <Headers/kern_api.hpp>

#include "kern_patchset.hpp"

static PatchSet patchSet;

// Boot-args to disable TB1/2 eGFX support
static const char *bootargOff[] {
    "-egfxdisable"
};

// Boot-args to enable eGFX support on beta versions of macOS
static const char *bootargBeta[] {
    "-egfxbeta"
};

PluginConfiguration ADDPR(config) {
    xStringify(PRODUCT_NAME),
    parseModuleVersion(xStringify(MODULE_VERSION)),
    LiluAPI::AllowNormal,
    bootargOff,
    arrsize(bootargOff),
    nullptr,
    0,
    bootargBeta,
    arrsize(bootargBeta),
    KernelVersion::Catalina,
    KernelVersion::BigSur,
    []() {
        patchSet.init();
        patchSet.deinit();
    }
};
