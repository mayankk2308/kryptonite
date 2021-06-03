// Adapted from: https://github.com/coderobe/AzulPatcher4600

#include <Headers/kern_api.hpp>
#include <Headers/kern_iokit.hpp>
#include "kern_patchset.hpp"

template <typename T,unsigned S>
inline unsigned arraysize(const T (&v)[S]) { return S; }

static const char* targetKexts[] = {
    "/System/Library/Extensions/AppleGraphicsControl.kext/Contents/PlugIns/AppleGPUWrangler.kext/Contents/MacOS/AppleGPUWrangler",
    "/System/Library/Extensions/IOGraphicsFamily.kext/IOGraphicsFamily",
    "/System/Library/Extensions/AppleGraphicsControl.kext/Contents/PlugIns/AppleMuxControl.kext/Contents/MacOS/AppleMuxControl",
    "/System/Library/Extensions/IOThunderboltFamily.kext/Contents/MacOS/IOThunderboltFamily"
};

static KernelPatcher::KextInfo kextList[] {
    {"com.apple.AppleGPUWrangler", &targetKexts[0], arraysize(targetKexts), {true}, {}, KernelPatcher::KextInfo::Unloaded},
    {"com.apple.iokit.IOGraphicsFamily", &targetKexts[1], arraysize(targetKexts), {true}, {}, KernelPatcher::KextInfo::Unloaded},
    {"com.apple.driver.AppleMuxControl", &targetKexts[2], arraysize(targetKexts), {true}, {}, KernelPatcher::KextInfo::Unloaded},
    {"com.apple.iokit.IOThunderboltFamily", &targetKexts[3], arraysize(targetKexts), {true}, {}, KernelPatcher::KextInfo::Unloaded}
};

static char gpuVendor[5];
static const char* vendorAmd = "AMD";
static const char* vendorNV = "NVDA";

static size_t kextListSize = arraysize(kextList);

void PatchSet::init() {
    if (!PE_parse_boot_argn("krygpu", &gpuVendor, sizeof(gpuVendor))) {
        *gpuVendor = '\0';
    }

    SYSLOG(PatchSet::moduleName, "Selected GPU vendor: %s", *gpuVendor ? gpuVendor : "None");
    
    LiluAPI::Error error = lilu.onKextLoad(kextList, kextListSize,
                                           [](void* user, KernelPatcher& patcher, size_t index, mach_vm_address_t address, size_t size) {
        PatchSet* patchset = static_cast<PatchSet*>(user);
        patchset->processKext(patcher, index, address, size);
    }, this);
    
    if (error != LiluAPI::Error::NoError) {
        SYSLOG(PatchSet::moduleName, "Failed to register onKextLoad method: %d", error);
    }
}

void PatchSet::processKext(KernelPatcher& patcher, size_t index, mach_vm_address_t address, size_t size) {
    for (size_t i = 0; i < kextListSize; i++) {
        if (kextList[i].loadIndex != index) {
            continue;
        }
        
        SYSLOG(PatchSet::moduleName, "Found %s...", kextList[i].id);
        
        if (!strcmp(kextList[i].id, kextList[0].id)) {
            if (!strcmp(gpuVendor, vendorAmd)) {
                const uint8_t find[] = {0xf8, 0x03, 0x0f, 0x82, 0x78, 0xff, 0xff, 0xff, 0x49, 0x8b, 0x06, 0xc6, 0x80, 0x78, 0x01, 0x00};
                const uint8_t repl[] = {0xf8, 0x00, 0x0f, 0x82, 0x78, 0xff, 0xff, 0xff, 0x49, 0x8b, 0x06, 0xc6, 0x80, 0x78, 0x01, 0x00};
                KextPatch patch {
                    {&kextList[i], find, repl, sizeof(find), 1},
                    KernelVersion::HighSierra, KernelVersion::BigSur
                };
                
                applyPatches(patcher, index, &patch, 1);
            }
            
            if (!strcmp(gpuVendor, vendorNV)) {
                const uint8_t find[] = {0x49, 0x4f, 0x50, 0x43, 0x49, 0x54, 0x75, 0x6e, 0x6e, 0x65, 0x6c, 0x6c, 0x65, 0x64};
                const uint8_t repl[] = {0x49, 0x4f, 0x50, 0x43, 0x49, 0x54, 0x75, 0x6e, 0x6e, 0x65, 0x6c, 0x6c, 0x65, 0x71};
                KextPatch patch {
                    {&kextList[i], find, repl, sizeof(find), 1},
                    KernelVersion::HighSierra, KernelVersion::BigSur
                };
                
                applyPatches(patcher, index, &patch, 1);
            }
        }
        
        if (!strcmp(kextList[i].id, kextList[1].id)) {
            if (!strcmp(gpuVendor, vendorNV)) {
                const uint8_t find[] = {0x49, 0x4f, 0x50, 0x43, 0x49, 0x54, 0x75, 0x6e, 0x6e, 0x65, 0x6c, 0x6c, 0x65, 0x64};
                const uint8_t repl[] = {0x49, 0x4f, 0x50, 0x43, 0x49, 0x54, 0x75, 0x6e, 0x6e, 0x65, 0x6c, 0x6c, 0x65, 0x71};
                KextPatch patch {
                    {&kextList[i], find, repl, sizeof(find), 1},
                    KernelVersion::HighSierra, KernelVersion::BigSur
                };
                
                applyPatches(patcher, index, &patch, 1);
            }
        }
        
        if (!strcmp(kextList[i].id, kextList[2].id)) {
            const uint8_t find[] = {0x46, 0x41, 0x34, 0x43, 0x45, 0x32, 0x38, 0x44, 0x2d, 0x42, 0x36, 0x32, 0x46, 0x2d,
                0x34, 0x43, 0x39, 0x39, 0x2d, 0x39, 0x43, 0x43, 0x33, 0x2d, 0x36, 0x38, 0x31,
                0x35, 0x36, 0x38, 0x36, 0x45, 0x33, 0x30, 0x46, 0x39, 0x3a, 0x67, 0x70, 0x75,
                0x2d, 0x70, 0x6f, 0x77, 0x65, 0x72, 0x2d, 0x70, 0x72, 0x65, 0x66, 0x73};
            const uint8_t repl[] = {0x46, 0x41, 0x34, 0x43, 0x45, 0x32, 0x38, 0x44, 0x2d, 0x42, 0x36, 0x32, 0x46, 0x2d,
                0x34, 0x43, 0x39, 0x39, 0x2d, 0x39, 0x43, 0x43, 0x33, 0x2d, 0x36, 0x38, 0x31,
                0x35, 0x36, 0x38, 0x36, 0x45, 0x33, 0x30, 0x46, 0x39, 0x3a, 0x67, 0x70, 0x75,
                0x2d, 0x70, 0x6f, 0x77, 0x65, 0x72, 0x2d, 0x70, 0x72, 0x65, 0x66, 0x71};
            KextPatch patch {
                {&kextList[i], find, repl, sizeof(find), 1},
                KernelVersion::HighSierra, KernelVersion::BigSur
            };
            
            applyPatches(patcher, index, &patch, 1);
        }
        
        if (!strcmp(kextList[i].id, kextList[3].id)) {
            KernelPatcher::RouteRequest request("__ZN24IOThunderboltSwitchType321shouldSkipEnumerationEv", hookedTBTSkipEnumeration, PatchSet::orgSkipEnumerationCallback);
            patcher.routeMultiple(index, &request, 1, address, size);
        }
    }
    
    patcher.clearError();
}

void PatchSet::applyPatches(KernelPatcher& patcher, size_t index, const KextPatch* patches, size_t patchNum) {
    for (size_t p = 0; p < patchNum; p++) {
        auto &patch = patches[p];
        if (patch.patch.kext->loadIndex == index) {
            if (patcher.compatibleKernel(patch.minKernel, patch.maxKernel)) {
                SYSLOG(PatchSet::moduleName, "Patching %s (%ld/%ld)...", patch.patch.kext->id, p+1, patchNum);
                patcher.applyLookupPatch(&patch.patch);
                patcher.clearError();
            }
        }
    }
}

int PatchSet::hookedTBTSkipEnumeration() {
    SYSLOG("IOThunderboltFamily", "Hooked TBT enumeration, skipping checks...");
    return 0;
}
