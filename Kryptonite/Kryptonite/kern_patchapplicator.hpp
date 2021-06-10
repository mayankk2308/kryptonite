//
//  kern_patchapplicator.hpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#ifndef kern_patchapplicator_hpp
#define kern_patchapplicator_hpp

#include <Headers/kern_api.hpp>
#include <Headers/kern_patcher.hpp>

class PatchApplicator {
private:
    constexpr static const char* moduleName = "patchapp";
    
public:
    void applyLookupPatch(KernelPatcher& patcher, KernelPatcher::LookupPatch* patch);
    void applyRoutingPatch(size_t index, KernelPatcher &patcher, KernelPatcher::RouteRequest *patch, mach_vm_address_t address, size_t size);
};

#endif /* kern_patchapplicator_hpp */
