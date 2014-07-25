//
//  HITCApplicationList.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/13.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSFSingletonSynthesizer.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Class of application (widget and plugin) list
@interface HITCApplicationList : NSObject

MSF_SYSNTHESIZE_SINGLETON_FOR_CLASS_INTERFACE(ApplicationList, HITC);

/// Array of application (widgets and plugins)
@property (nonatomic, readonly) NSArray *applications;

/// Clear application list
- (void)clear;

/// Add widget
- (void)addWidget:(NSString *)name tag:(NSInteger)tag;

/// Add plugin
- (void)addPlugin:(NSString *)name tag:(NSInteger)tag;

@end
