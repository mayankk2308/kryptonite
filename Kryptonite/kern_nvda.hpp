//
//  nvda.hpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#ifndef kern_nvda_hpp
#define kern_nvda_hpp

#include <IOKit/ndrvsupport/IONDRVFramebuffer.h>

class NVDA : public IONDRVFramebuffer
{
    OSDeclareDefaultStructors(NVDA)
public:
    virtual IOReturn createNVDCNub(UInt32);
private:
    UInt64 data[50];
};

class NVDATesla : public IONDRVFramebuffer
{
    OSDeclareDefaultStructors(NVDATesla)
private:
    UInt64 data[46];
};

#endif /* kern_nvda_hpp */
