//
//  HITCAlternativeZeroconf.h
//  HITController
//
//  Created by Masakazu Suetomo on 2013/08/12.
//  Copyright (c) 2013 Kyoto University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSFSingletonSynthesizer.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Class of alternative Zeroconf
@interface HITCAlternativeZeroconf : NSObject

MSF_SYSNTHESIZE_SINGLETON_FOR_CLASS_INTERFACE(AlternativeZeroconf, HITC);

/// Start alternative Zeroconf
- (void)start;

/// Stop alternative Zeroconf
- (void)stop;

@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Notification that it connected with master
extern NSString *const HITCAlternativeZeroconfDidConnectWithMasterNotification;
/// Master host name key
extern NSString *const HITCAlternativeZeroconfMasterHostNameKey;
/// Notification that it disconnected with master
extern NSString *const HITCAlternativeZeroconfDidDisconnectWithMasterNotification;
