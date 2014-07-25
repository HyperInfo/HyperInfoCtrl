//
//  HITCLocalhost.m
//  HITController
//
//  Created by Masakazu Suetomo on 2013/01/15.
//  Copyright (c) 2013 Kyoto University. All rights reserved.
//

#import "HITCLocalhost.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Localhost IP address
static __strong NSString *HITCLocalhostIPAddress = @"";


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCLocalhost

#pragma mark -
#pragma mark Class Method

//-----------------------------------------------------------------------------------
+ (void)setIPAddress:(NSString *)IPAddress
//-----------------------------------------------------------------------------------
{
    HITCLocalhostIPAddress = IPAddress;
}

//-----------------------------------------------------------------------------------
+ (NSString *)IPAddress
//-----------------------------------------------------------------------------------
{
    return HITCLocalhostIPAddress;
}

@end
