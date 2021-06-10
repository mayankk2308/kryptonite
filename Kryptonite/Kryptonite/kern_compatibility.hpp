//
//  kern_compatibility.hpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#ifndef kern_compatibility_hpp
#define kern_compatibility_hpp

#include <Headers/kern_api.hpp>

class Compatibility {
private:
    constexpr static const char* moduleName = "compat";
    static const KernelVersion minVersion = KernelVersion::HighSierra;
    static const KernelMinorVersion minMinorVersion = 5;
    static const KernelVersion oldVersion = KernelVersion::Catalina;
    static const KernelMinorVersion oldMinorVersion = 1;
    
public:
    static bool isUnsupported();
    static bool isOlderKernel();
};

#endif /* kern_compatibility_hpp */
