//
//  HITCMaster.m
//  HITController
//
//  Created by Masakazu Suetomo on 2013/01/15.
//  Copyright (c) 2013 Kyoto University. All rights reserved.
//

#import "HITCMaster.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Localhost IP address
static __strong NSString *HITCMasterIPAddress = @"";
/// Master screen size
static CGSize HITCMasterScreenSize = {0.0, 0.0};


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCMaster

#pragma mark -
#pragma mark Class Method

//-----------------------------------------------------------------------------------
+ (void)setIPAddress:(NSString *)IPAddress
//-----------------------------------------------------------------------------------
{
    HITCMasterIPAddress = IPAddress;
}

//-----------------------------------------------------------------------------------
+ (NSString *)IPAddress
//-----------------------------------------------------------------------------------
{
    return HITCMasterIPAddress;
}

//-----------------------------------------------------------------------------------
+ (void)setScreenSize:(CGSize)screenSize
//-----------------------------------------------------------------------------------
{
    HITCMasterScreenSize = screenSize;
}

//-----------------------------------------------------------------------------------
+ (CGSize)screenSize
//-----------------------------------------------------------------------------------
{
    return HITCMasterScreenSize;
}

@end
