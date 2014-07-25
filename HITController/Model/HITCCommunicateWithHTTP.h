//
//  HITCCommunicateWithHTTP.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/30.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSFSingletonSynthesizer.h"

@class HITCItem;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Class of communicating with HTTP
@interface HITCCommunicateWithHTTP : NSObject

MSF_SYSNTHESIZE_SINGLETON_FOR_CLASS_INTERFACE(CommunicateWithHTTP, HITC);

/// Load data using HTTP
- (void)loadDataUsingHTTPWithIPAddress:(NSString *)IPAddress;

/// Download image using HTTP
- (void)downloadImageFromIPAddress:(NSString *)IPAddress filename:(NSString *)filename item:(HITCItem *)item;

/// Download text using HTTP
- (void)downloadTextFromIPAddress:(NSString *)IPAddress filename:(NSString *)filename item:(HITCItem *)item;

/// Returns cache foler path
+ (NSString *)cacheFolderPath;

@end
