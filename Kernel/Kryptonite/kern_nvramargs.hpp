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
    
    static void getGPU();
    static void getTBTVersion();

public:
    static void init();
    static bool isAMD();
    static bool isNVDA();
    static bool isThunderbolt1();
    static bool isThunderbolt2();
};

#endif /* kern_nvramargs_hpp */
