// Adapted from: https://github.com/coderobe/AzulPatcher4600

#include <Headers/kern_api.hpp>
#include <Headers/kern_iokit.hpp>

#include "kern_patchset.hpp"
#include "kern_targetkexts.hpp"
#include "kern_nvramargs.hpp"
#include "kern_patchapplicator.hpp"
#include "kern_hooks.hpp"
#include "kern_patches.hpp"
#include "kern_compatibility.hpp"

// For accessing NVRAM arguments
static NVRAMArgs args;

// Patching subsystem
static PatchApplicator patchApplicator;

void PatchSet::init() {
    args.init();
    LiluAPI::Error error = lilu.onKextLoad(kextList, kextListSize,
                                           [](void* user, KernelPatcher& patcher, size_t index, mach_vm_address_t address, size_t size) {
        PatchSet* patchset = static_cast<PatchSet*>(user);
        patchset->processKext(patcher, index, address, size);
    }, this);
    
    if (error != LiluAPI::Error::NoError) {
        SYSLOG(moduleName, "Failed to register onKextLoad method: %d", error);
    }
}

void PatchSet::processKext(KernelPatcher& patcher, size_t index, mach_vm_address_t address, size_t size) {
    for (size_t i = 0; i < kextListSize; i++) {
        if (kextList[i].loadIndex != index) {
            continue;
        }
        
        SYSLOG(moduleName, "Found %s...", kextList[i].id);
        
        if (!strcmp(kextList[i].id, kextList[0].id)) {
            if (args.isAMD() & !Compatibility::isOlderKernel()) {
                const uint8_t find[] = {0xf8, 0x03, 0x0f, 0x82, 0x78, 0xff, 0xff, 0xff, 0x49, 0x8b, 0x06, 0xc6, 0x80, 0x78, 0x01, 0x00};
                const uint8_t repl[] = {0xf8, 0x00, 0x0f, 0x82, 0x78, 0xff, 0xff, 0xff, 0x49, 0x8b, 0x06, 0xc6, 0x80, 0x78, 0x01, 0x00};
                KernelPatcher::LookupPatch patch = {&kextList[i], find, repl, sizeof(find), 1};
                patchApplicator.applyLookupPatch(patcher, &patch);
            }
            
            if (args.isNVDA()) {
                const uint8_t find[] = {0x49, 0x4f, 0x50, 0x43, 0x49, 0x54, 0x75, 0x6e, 0x6e, 0x65, 0x6c, 0x6c, 0x65, 0x64};
                const uint8_t repl[] = {0x49, 0x4f, 0x50, 0x43, 0x49, 0x54, 0x75, 0x6e, 0x6e, 0x65, 0x6c, 0x6c, 0x65, 0x71};
                KernelPatcher::LookupPatch patch = {&kextList[i], find, repl, sizeof(find), 1};
                patchApplicator.applyLookupPatch(patcher, &patch);
            }
        }
        
        if (!strcmp(kextList[i].id, kextList[1].id)) {
            if (args.isNVDA()) {
                const uint8_t find[] = {0x49, 0x4f, 0x50, 0x43, 0x49, 0x54, 0x75, 0x6e, 0x6e, 0x65, 0x6c, 0x6c, 0x65, 0x64};
                const uint8_t repl[] = {0x49, 0x4f, 0x50, 0x43, 0x49, 0x54, 0x75, 0x6e, 0x6e, 0x65, 0x6c, 0x6c, 0x65, 0x71};
                KernelPatcher::LookupPatch patch = {&kextList[i], find, repl, sizeof(find), 1};
                patchApplicator.applyLookupPatch(patcher, &patch);
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
            KernelPatcher::LookupPatch patch = {&kextList[i], find, repl, sizeof(find), 1};
            
            patchApplicator.applyLookupPatch(patcher, &patch);
        }
        
        if (!strcmp(kextList[i].id, kextList[3].id)) {
            KernelPatcher::RouteRequest request("__ZN24IOThunderboltSwitchType321shouldSkipEnumerationEv", FunctionHooks::thunderboltShouldSkipEnumeration, {PatchSet::orgSkipEnumerationCallback});
            patchApplicator.applyRoutingPatch(index, patcher, &request, address, size);
        }
    }
    
    patcher.clearError();
}

