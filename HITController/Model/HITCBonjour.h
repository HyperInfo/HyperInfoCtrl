//
//  HITCBonjour.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/14.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSFSingletonSynthesizer.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Class of Bonjour
@interface HITCBonjour : NSObject

MSF_SYSNTHESIZE_SINGLETON_FOR_CLASS_INTERFACE(Bonjour, HITC);

/// Start Bonjour
- (void)start;

/// Stop Bonjour
- (void)stop;

@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Notification that it connected with master
extern NSString *const HITCBonjourDidConnectWithMasterNotification;
/// Master host name key
extern NSString *const HITCBonjourMasterHostNameKey;
/// Notification that it disconnected with master
extern NSString *const HITCBonjourDidDisconnectWithMasterNotification;
