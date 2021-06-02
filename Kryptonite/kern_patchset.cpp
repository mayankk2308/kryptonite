// Adapted from: https://github.com/coderobe/AzulPatcher4600

#include <Headers/kern_api.hpp>
#include <Headers/kern_iokit.hpp>
#include "kern_patchset.hpp"

// Computes array size
template <typename T,unsigned S>
inline unsigned arraysize(const T (&v)[S]) { return S; }

// Target kexts
static const char* targetKexts[] = {
    "/System/Library/Extensions/AppleGraphicsControl.kext/Contents/PlugIns/AppleGPUWrangler.kext/Contents/MacOS/AppleGPUWrangler",
    "/System/Library/Extensions/IOGraphicsFamily.kext/IOGraphicsFamily",
};

static KernelPatcher::KextInfo kextList[] {
    {"com.apple.AppleGPUWrangler", &targetKexts[0], arraysize(targetKexts), {true}, {}, KernelPatcher::KextInfo::Unloaded},
    {"com.apple.iokit.IOGraphicsFamily", &targetKexts[1], arraysize(targetKexts), {true}, {}, KernelPatcher::KextInfo::Unloaded}
};

static char gpuVendor[5];
static const char* vendorAmd = "AMD";
static const char* vendorNV = "NVDA";

static size_t kextListSize = arraysize(kextList);

void PatchSet::init() {
    if (!PE_parse_boot_argn("kryvendor", &gpuVendor, sizeof(gpuVendor))) {
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
