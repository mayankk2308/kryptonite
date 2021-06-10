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
    constexpr static const char* moduleName = "patchset";
    
    void init();
    
private:
    mach_vm_address_t orgSkipEnumerationCallback {0};
    
    void processKext(KernelPatcher& patcher, size_t index, mach_vm_address_t address, size_t size);
};

#endif /* kern_patchset */
