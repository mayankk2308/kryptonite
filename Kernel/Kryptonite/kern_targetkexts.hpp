//
//  kern_targetkexts.hpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#ifndef kern_targetkexts_hpp
#define kern_targetkexts_hpp

template <typename T,unsigned S>
inline unsigned arraysize(const T (&v)[S]) { return S; }

static const char* targetKexts[] = {
    "/System/Library/Extensions/AppleGraphicsControl.kext/Contents/PlugIns/AppleGPUWrangler.kext/Contents/MacOS/AppleGPUWrangler",
    "/System/Library/Extensions/IOGraphicsFamily.kext/IOGraphicsFamily",
    "/System/Library/Extensions/AppleGraphicsControl.kext/Contents/PlugIns/AppleMuxControl.kext/Contents/MacOS/AppleMuxControl",
    "/System/Library/Extensions/IOThunderboltFamily.kext/Contents/MacOS/IOThunderboltFamily",
    "/System/Library/Extensions/IOPCIFamily.kext/IOPCIFamily"
};

static KernelPatcher::KextInfo kextList[] {
    {"com.apple.AppleGPUWrangler", &targetKexts[0], arraysize(targetKexts), {true}, {}, KernelPatcher::KextInfo::Unloaded},
    {"com.apple.iokit.IOGraphicsFamily", &targetKexts[1], arraysize(targetKexts), {true}, {}, KernelPatcher::KextInfo::Unloaded},
    {"com.apple.driver.AppleMuxControl", &targetKexts[2], arraysize(targetKexts), {true}, {}, KernelPatcher::KextInfo::Unloaded},
    {"com.apple.iokit.IOThunderboltFamily", &targetKexts[3], arraysize(targetKexts), {true}, {}, KernelPatcher::KextInfo::Unloaded},
    {"com.apple.iokit.IOPCIFamily", &targetKexts[4], arraysize(targetKexts), {true}, {}, KernelPatcher::KextInfo::Unloaded}
};

static size_t kextListSize = arraysize(kextList);

#endif /* kern_targetkexts_hpp */
