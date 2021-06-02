//
//  kern_nvdateslapatch.hpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#ifndef kern_nvdateslapatch_hpp
#define kern_nvdateslapatch_hpp

#include <kern_nvda.hpp>

class NVDATeslaPatched : public NVDATesla
{
    OSDeclareDefaultStructors(NVDATeslaPatched)
public:
    const char* moduleName = "NVDATeslaPatched";
    virtual bool attach(IOService *provider) override;
};

#endif /* kern_nvdateslapatch_hpp */
