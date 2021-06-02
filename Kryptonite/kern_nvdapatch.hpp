//
//  kern_nvdapatch.hpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#ifndef kern_nvdapatch_hpp
#define kern_nvdapatch_hpp

#include "kern_nvda.hpp"

class NVDAPatched : public NVDA
{
    OSDeclareDefaultStructors(NVDAPatched)
public:
    const char* moduleName = "NVDAPatched";
    virtual bool attach(IOService *provider) override;
};

#endif /* kern_nvdapatch_hpp */
