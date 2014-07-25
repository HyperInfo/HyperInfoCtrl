//
//  HITCMaster.h
//  HITController
//
//  Created by Masakazu Suetomo on 2013/01/15.
//  Copyright (c) 2013 Kyoto University. All rights reserved.
//

#import <Foundation/Foundation.h>


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Class of Master
@interface HITCMaster : NSObject

/// Set IP address (e.g. @"10.0.1.1")
+ (void)setIPAddress:(NSString *)IPAddress;

/// Returns IP addres (e.g. @"10.0.1.1")
+ (NSString *)IPAddress;

/// Set master screen size
+ (void)setScreenSize:(CGSize)screenSize;

/// Returns master screen size
+ (CGSize)screenSize;

@end
