//
//  kern_patches.hpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/4/21.
//

#ifndef kern_patches_hpp
#define kern_patches_hpp

#include <Headers/kern_api.hpp>

class Patches {
private:
    constexpr static const char* moduleName = "patches";
    
public:
    static void init();
    static void unblockLegacyThunderbolt(KernelPatcher &patcher, KernelPatcher::KextInfo *kext);
    static void bypassPCITunnelled(KernelPatcher &patcher, KernelPatcher::KextInfo *kext);
    static void bypassIOPCITunnelCompatible(KernelPatcher &patcher, KernelPatcher::KextInfo *kext);
    static void updateMuxControlNVRAMVar(KernelPatcher &patcher, KernelPatcher::KextInfo *kext);
    static void routeThunderboltEnumeration(KernelPatcher &patcher, size_t *index, mach_vm_address_t *address, size_t *size);
};

#endif /* kern_patches_hpp */
