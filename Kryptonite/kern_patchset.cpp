// Adapted from: https://github.com/coderobe/AzulPatcher4600

#include <Headers/kern_api.hpp>
#include <Headers/kern_util.hpp>

#include <mach/vm_map.h>
#include <IOKit/IORegistryEntry.h>

#include "kern_patchset.hpp"

// Computes array size
template <typename T,unsigned S>
inline unsigned arraysize(const T (&v)[S]) { return S; }

// Log module name
static const char* moduleSuffix = "egfxp";

// Target kexts
static const char* targetKexts[] = {
    "/System/Library/Extensions/AppleGraphicsControl.kext/Contents/PlugIns/AppleGPUWrangler.kext/Contents/MacOS/AppleGPUWrangler"
};

static KernelPatcher::KextInfo kextList[] {
    {"com.apple.AppleGPUWrangler", &targetKexts[0], arraysize(targetKexts), {true}, {}, KernelPatcher::KextInfo::Unloaded},
};

static size_t kextListSize = arraysize(kextList);

bool PatchSet::init() {
    LiluAPI::Error error = lilu.onKextLoad(kextList, kextListSize,
    [](void* user, KernelPatcher& patcher, size_t index, mach_vm_address_t address, size_t size) {
        PatchSet* patchset = static_cast<PatchSet*>(user);
        patchset->processKext(patcher, index, address, size);
    }, this);
    
    if(error != LiluAPI::Error::NoError) {
        SYSLOG(moduleSuffix, "Failed to register onPatcherLoad method %d", error);
        return false;
    }
    
    return true;
}

void PatchSet::deinit() {
    // Nothing to de-allocate
}

void PatchSet::processKext(KernelPatcher& patcher, size_t index, mach_vm_address_t address, size_t size) {
    if(progressState != ProcessingState::EverythingDone) {
        for(size_t i = 0; i < kextListSize; i++) {
            if(kextList[i].loadIndex == index) {
                if(!(progressState & ProcessingState::EverythingDone) && !strcmp(kextList[i].id, kextList[0].id)) {
                    SYSLOG(moduleSuffix, "Found %s", kextList[i].id);

                    // Patch Thunderbolt blocks
                    const uint8_t find[] = {0xf8, 0x03, 0x0f, 0x82, 0x78, 0xff,
                        0xff, 0xff, 0x49, 0x8b, 0x06, 0xc6, 0x80, 0x78, 0x01, 0x00};
                    const uint8_t repl[] = {0xf8, 0x00, 0x0f, 0x82, 0x78, 0xff,
                        0xff, 0xff, 0x49, 0x8b, 0x06, 0xc6, 0x80, 0x78, 0x01, 0x00};
                    KextPatch kext_patch {
                        {&kextList[i], find, repl, sizeof(find), 1},
                        KernelVersion::Catalina, KernelVersion::BigSur
                    };
                    
                    
                    applyPatches(patcher, index, &kext_patch, 1);
                    
                    SYSLOG(moduleSuffix, "Patched thunderbolt blocks");

                    progressState |= ProcessingState::EverythingDone;
                }
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
                SYSLOG(moduleSuffix, "Patching %s (%ld/%ld)...", patch.patch.kext->id, p+1, patchNum);
                patcher.applyLookupPatch(&patch.patch);
                patcher.clearError();
            }
        }
    }
}
