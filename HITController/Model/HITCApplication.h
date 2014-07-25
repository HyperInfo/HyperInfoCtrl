//
//  HITCApplication.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/14.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HITCItem.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Application types
typedef enum {
    HITCApplicationTypeWidget       = 0,        ///< Widget
    HITCApplicationTypePlugin       = 1,        ///< Plugin
} HITCApplicationType;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Class of application (widget and plugin)
@interface HITCApplication : HITCItem

/// Application type
@property (nonatomic, assign) HITCApplicationType applicationType;

/// Initializer
- (id)initWithWidgetName:(NSString *)name tag:(NSInteger)tag;

/// Initializer
- (id)initWithPluginName:(NSString *)name tag:(NSInteger)tag;

@end
