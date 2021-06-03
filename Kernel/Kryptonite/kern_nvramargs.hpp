//
//  kern_nvramargs.hpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#ifndef kern_nvramargs_hpp
#define kern_nvramargs_hpp

static char gpu[5];
static int tbtVersion;

class NVRAMArgs {
private:
    constexpr static const char* moduleName = "nvram";
    
    constexpr static const char* gpuArg = "krygpu";
    constexpr static const char* amd = "AMD";
    constexpr static const char* nvda = "NVDA";
    
    constexpr static const char* tbtVersionArg = "krytbtv";
    
    void getGPU();
    void getTBTVersion();

public:
    void init();
    bool isAMD();
    bool isNVDA();
};

#endif /* kern_nvramargs_hpp */
