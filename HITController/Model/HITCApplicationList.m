//
//  HITCApplicationList.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/13.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCApplicationList.h"
#import "HITCApplication.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCApplicationList ()
{
    __strong NSMutableArray *_applications;         ///< Array of HITCApplication
}
@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCApplicationList

MSF_SYNTHESIZE_SINGLETON_FOR_CLASS_IMPLEMENTATION(ApplicationList, HITC, HITCInitializeApplicationList);

#pragma mark -
#pragma mark Property

//-----------------------------------------------------------------------------------
- (NSArray *)applications
//-----------------------------------------------------------------------------------
{
    if (_applications == nil) {
        _applications = [NSMutableArray arrayWithCapacity:16];
    }
    
    return _applications;
}


#pragma mark -
#pragma mark Public

//-----------------------------------------------------------------------------------
- (void)clear
//-----------------------------------------------------------------------------------
{
    [self willChangeValueForKey:@"applications"];
    [_applications removeAllObjects];
    [self didChangeValueForKey:@"applications"];
}

//-----------------------------------------------------------------------------------
- (void)addWidget:(NSString *)name tag:(NSInteger)tag
//-----------------------------------------------------------------------------------
{
    if (_applications == nil) {
        _applications = [NSMutableArray arrayWithCapacity:16];
    }
    
    HITCApplication *application = [[HITCApplication alloc] initWithWidgetName:name tag:tag];
    [self willChangeValueForKey:@"applications"];
    [_applications addObject:application];
    [self didChangeValueForKey:@"applications"];
}

//-----------------------------------------------------------------------------------
- (void)addPlugin:(NSString *)name tag:(NSInteger)tag
//-----------------------------------------------------------------------------------
{
    if (_applications == nil) {
        _applications = [NSMutableArray arrayWithCapacity:16];
    }
    
    HITCApplication *application = [[HITCApplication alloc] initWithPluginName:name tag:tag];
    [self willChangeValueForKey:@"applications"];
    [_applications addObject:application];
    [self didChangeValueForKey:@"applications"];
}


#pragma mark -
#pragma mark Private

/// Initialize
//-----------------------------------------------------------------------------------
- (void)HITCInitializeApplicationList
//-----------------------------------------------------------------------------------
{
}

@end
