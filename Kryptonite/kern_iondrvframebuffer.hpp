//
//  kern_iondrvframebuffer.hpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#ifndef kern_iondrvframebuffer_hpp
#define kern_iondrvframebuffer_hpp

#include <IOKit/ndrvsupport/IONDRVFramebuffer.h>

class IONDRVFramebufferPatched : public IONDRVFramebuffer
{
    OSDeclareDefaultStructors(IONDRVFramebufferPatched)
public:
    const char* moduleName = "IONDRVFramebufferPatched";
    virtual bool attach(IOService *provider) override;
};

#endif /* kern_iondrvframebuffer_hpp */
