//
//  kern_hooks.hpp
//  Kryptonite
//
//  Created by Mayank Kumar on 6/2/21.
//

#ifndef kern_hooks_hpp
#define kern_hooks_hpp

class FunctionHooks {
    
private:
    constexpr static const char* moduleName = "hooks";
    
public:
    static int thunderboltShouldSkipEnumeration();
    
};

#endif /* kern_hooks_hpp */
