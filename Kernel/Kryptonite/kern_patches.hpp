//
//  kern_patches.hpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/4/21.
//

#ifndef kern_patches_hpp
#define kern_patches_hpp

#include <Headers/kern_api.hpp>
#include "kern_nvramargs.hpp"

class Patches {
private:
    constexpr static const char* moduleName = "patches";
    
public:
    static void unblockLegacyThunderbolt(KernelPatcher &patcher, KernelPatcher::KextInfo *kext, NVRAMArgs* args);
};

#endif /* kern_patches_hpp */
