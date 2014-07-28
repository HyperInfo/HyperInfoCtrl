//
//  MSFSingletonSynthesizer.h
//  MSFCommonThings
//
//  Created by mxs on 2012/03/29.
//  Modified by mxs on 2012/06/29.

//
//  Copyright (c) 2012, moonxseed (http://www.moonxseed.com)
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//     * Redistributions of source code must retain the above copyright notice, this
//       list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright notice,
//       this list of conditions and the following disclaimer in the documentation
//       and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
//  OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
//  IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

//  for ARC singleton
//
//  Based on WWDC2012 Session 406/416 Adopting Automatic Reference Counting
//
//  for MRC singleton
//
//  Created by Matt Gallagher on 2011/08/23.
//  Copyright (c) 2011 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
//  Referenced: http://cocoawithlove.com/2008/11/singletons-appdelegates-and-top-level.html
//

#import <objc/runtime.h>
#import "MSFCommon.h"


// 
// Usage:
// 
// in your class header file...
// 
// #import "MSFSingletonSynthesizer.h"
// 
// @interface PFMySingleton : Superclass
// 
// MSF_SYSNTHESIZE_SINGLETON_FOR_CLASS_INTERFACE(MySingleton, PF);      // PF is class prefix. Optional.
// 
// @end
// 
// 
// in your class implementation file...
// 
// #import "PFMySingleton.h"
// 
// @implementation PFMySingleton
// 
// MSF_SYNTHESIZE_SINGLETON_FOR_CLASS_IMPLEMENTATION(MySingleton, PF, _initializeMySingleton);  // PF is class prefix. Optional.
// 
// - (void)_initializeMySingleton
// {
//      // initializing code here
// }
// 
// @end
// 
// 
// 
// and how to use synthesized singleton...
// 
// #import "PFMySingleton.h"
// 
// @implementation PFClient
// 
// - (void)_foo
// {
//      PFMySingleton *sharedMySingleton = [PFMySingleton sharedMySingleton];
// }
// 
// @end
// 

//-----------------------------------------------------------------------------------
#define MSF_SYSNTHESIZE_SINGLETON_FOR_CLASS_INTERFACE(classname, prefix) \
+ (prefix##classname *)shared##classname;


//-----------------------------------------------------------------------------------
#if __has_feature(objc_arc)

// ARC definition
#define MSF_SYNTHESIZE_SINGLETON_FOR_CLASS_IMPLEMENTATION(classname, prefix, initializeSingleton) \
\
static BOOL shared##classname##Inside = NO; \
\
+ (prefix##classname *)shared##classname \
{ \
    static prefix##classname *shared##classname##Instance_ = nil; \
    static dispatch_once_t done; \
    dispatch_once(&done, ^{ \
        shared##classname##Inside = YES; \
        shared##classname##Instance_ = [self new]; \
        \
        if ([shared##classname##Instance_ respondsToSelector:@selector(initializeSingleton)]) { \
            [shared##classname##Instance_ initializeSingleton]; \
        } \
        shared##classname##Inside = NO; \
    }); \
    \
    return shared##classname##Instance_; \
} \
\
+ (id)allocWithZone:(NSZone *)zone \
{ \
    if (shared##classname##Inside) { \
        return [super allocWithZone:zone]; \
    } \
    else { \
        NSString *reason = [NSString stringWithFormat:@"Use +shared%s instead.", #classname]; \
        NSException *exception = [NSException exceptionWithName:MSFGenericException reason:reason userInfo:nil]; \
        @throw exception; \
    } \
}

#else

// MRC definition
#define MSF_SYNTHESIZE_SINGLETON_FOR_CLASS_IMPLEMENTATION(classname, prefix, initializeSingleton) \
\
static prefix##classname *shared##classname##Instance_ = nil; \
\
+ (prefix##classname *)shared##classname \
{ \
    @synchronized(self) { \
        if (shared##classname##Instance_ == nil) { \
            shared##classname##Instance_ = [[self allocWithZone:nil] init]; \
        } \
    } \
    \
    return shared##classname##Instance_; \
} \
\
+ (id)allocWithZone:(NSZone *)zone \
{ \
    id shared##classname##Instance = nil; \
    \
    @synchronized(self) { \
        if (shared##classname##Instance_ == nil) { \
            shared##classname##Instance = [super allocWithZone:zone]; \
            method_exchangeImplementations( \
                class_getClassMethod([shared##classname##Instance class], @selector(shared##classname)), \
                class_getClassMethod([shared##classname##Instance class], @selector(_lockless##Shared##classname))); \
        } \
        else { \
            shared##classname##Instance = shared##classname##Instance_; \
        } \
    } \
    \
    return shared##classname##Instance; \
} \
\
- (id)init \
{ \
    @synchronized([self class]) { \
        if (shared##classname##Instance_ == nil) { \
            if ((self = [super init])) { \
                shared##classname##Instance_ = self; \
                method_exchangeImplementations( \
                    class_getInstanceMethod([shared##classname##Instance_ class], @selector(init)), \
                    class_getInstanceMethod([shared##classname##Instance_ class], @selector(_return##Shared##classname))); \
                if ([shared##classname##Instance_ respondsToSelector:@selector(initializeSingleton)]) { \
                    [shared##classname##Instance_ initializeSingleton]; \
                } \
            } \
        } \
    } \
    \
    return shared##classname##Instance_; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
    return self; \
} \
\
+ (prefix##classname *)_lockless##Shared##classname \
{ \
    return shared##classname##Instance_; \
} \
\
- (id)_return##Shared##classname \
{ \
    return self; \
} \
\
- (id)retain \
{ \
    return self; \
} \
\
- (NSUInteger)retainCount \
{ \
    return NSUIntegerMax; \
} \
\
- (oneway void)release \
{ \
} \
\
- (id)autorelease \
{ \
    return self; \
}

#endif
