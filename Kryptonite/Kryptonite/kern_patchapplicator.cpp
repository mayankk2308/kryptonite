//
//  kern_patchapplicator.cpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#include "kern_patchapplicator.hpp"

void PatchApplicator::applyLookupPatch(KernelPatcher& patcher, KernelPatcher::LookupPatch* patch) {
    SYSLOG(moduleName, "Patching %s...", patch->kext->id);
    patcher.applyLookupPatch(patch);
    SYSLOG(moduleName, "Patch attempted on %s.", patch->kext->id);
}

void PatchApplicator::applyRoutingPatch(size_t index, KernelPatcher &patcher, KernelPatcher::RouteRequest *patch, mach_vm_address_t address, size_t size) {
    SYSLOG(moduleName, "Routing from %lu to %lu...", patch->from, patch->to);
    patcher.routeMultiple(index, patch, 1, address, size);
    SYSLOG(moduleName, "Routing from %lu to %lu attempted.", patch->from, patch->to);
}
