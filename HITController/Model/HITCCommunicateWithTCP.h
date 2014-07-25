//
//  HITCCommunicateWithTCP.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/14.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSFSingletonSynthesizer.h"

@class HITCItem;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Class of communicating with TCP
@interface HITCCommunicateWithTCP : NSObject

MSF_SYSNTHESIZE_SINGLETON_FOR_CLASS_INTERFACE(CommunicateWithTCP, HITC);

/// Connect to address with host name
- (void)connectToAddressWithHostName:(NSString *)hostName;

/// Disconnect
- (void)disconnect;

/// Read TCP data
- (void)readDataFromSocket;

/// create item
- (void)createItem:(HITCItem *)item;

/// Delete item
- (void)deleteItem:(HITCItem *)item;

/// Move item
- (void)moveItem:(HITCItem *)item deselected:(BOOL)deselected;

/// Resize item
- (void)resizeItem:(HITCItem *)item deselected:(BOOL)deselected;

/// Rise item to topmost
- (void)riseTopmost:(HITCItem *)item;

@end
