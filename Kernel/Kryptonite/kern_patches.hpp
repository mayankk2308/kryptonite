//
//  kern_patches.hpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#ifndef kern_patches_hpp
#define kern_patches_hpp

#include <Headers/kern_api.hpp>

class Patches {
    
private:
    constexpr static const char* moduleName = "patches";
    static void patch(KernelPatcher& patcher, KernelPatcher::KextInfo* kextInfo, const uint8_t* find, const uint8_t* repl);
    
public:
    static void unlockThunderboltLimiterGPUWrangler(KernelPatcher& patcher, KernelPatcher::KextInfo* kextInfo);
    static void iopcitunnelledRename(KernelPatcher& patcher, KernelPatcher::KextInfo* kextInfo);
    static void muxPowerPrefsVariableRename(KernelPatcher& patcher, KernelPatcher::KextInfo* kextInfo);
};

#endif /* kern_patches_hpp */
