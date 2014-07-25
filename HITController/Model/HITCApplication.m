//
//  HITCApplication.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/14.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCApplication.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCApplication

//-----------------------------------------------------------------------------------
- (id)initWithWidgetName:(NSString *)name tag:(NSInteger)tag
//-----------------------------------------------------------------------------------
{
    self = [super init];
    if (self) {
        self.itemType = HITCItemTypeApplicaton;
        self.name = name;
        self.applicationType = HITCApplicationTypeWidget;
        self.tag = tag;
    }
    
    return self;
}

//-----------------------------------------------------------------------------------
- (id)initWithPluginName:(NSString *)name tag:(NSInteger)tag
//-----------------------------------------------------------------------------------
{
    self = [super init];
    if (self) {
        self.itemType = HITCItemTypeApplicaton;
        self.name = name;
        self.applicationType = HITCApplicationTypePlugin;
        self.tag = tag;
    }
    
    return self;
}


#pragma mark -
#pragma mark Override

//-----------------------------------------------------------------------------------
- (NSString *)description
//-----------------------------------------------------------------------------------
{
    return [NSString stringWithFormat:@"%@: [%@]",
            [super description],
            self.applicationType == HITCApplicationTypeWidget ? @"Widget" : @"Plugin"];
}

@end
