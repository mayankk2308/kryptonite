//
//  kern_patches.cpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//
#include "kern_patches.hpp"
#include "kern_patchapplicator.hpp"
#include "kern_targetkexts.hpp"

static PatchApplicator patchApplicator;

void Patches::patch(KernelPatcher &patcher, KernelPatcher::KextInfo *kextInfo, const uint8_t* find, const uint8_t* repl) {
    SYSLOG(moduleName, "Attempting lookup patch...");
    KernelPatcher::LookupPatch patch = {kextInfo, find, repl, sizeof(find), 1};
    patchApplicator.applyLookupPatch(patcher, &patch);
    SYSLOG(moduleName, "Lookup patch attempted.");
}

void Patches::unlockThunderboltLimiterGPUWrangler(KernelPatcher& patcher, KernelPatcher::KextInfo* kextInfo) {
    const uint8_t find[] = {0xf8, 0x03, 0x0f, 0x82, 0x78, 0xff, 0xff, 0xff, 0x49, 0x8b, 0x06, 0xc6, 0x80, 0x78, 0x01, 0x00};
    const uint8_t repl[] = {0xf8, 0x00, 0x0f, 0x82, 0x78, 0xff, 0xff, 0xff, 0x49, 0x8b, 0x06, 0xc6, 0x80, 0x78, 0x01, 0x00};
    
    patch(patcher, kextInfo, find, repl);
}
