// Adapted from: https://github.com/coderobe/AzulPatcher4600

#ifndef kern_patchset_hpp
#define kern_patchset_hpp

#include <Headers/kern_patcher.hpp>

struct KextPatch {
    KernelPatcher::LookupPatch patch;
    uint32_t minKernel;
    uint32_t maxKernel;
};

class PatchSet {
public:
    const char* moduleName = "patchSet";
    void init();
    
private:
    void processKext(KernelPatcher& patcher, size_t index, mach_vm_address_t address, size_t size);
    
    void applyPatches(KernelPatcher& patcher, size_t index, const KextPatch *patches, size_t patchesNum);
};

#endif /* kern_patchset */
