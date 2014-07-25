//
//  HITCItemList.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/24.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSFSingletonSynthesizer.h"

@class HITCItem;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Class of item list
@interface HITCItemList : NSObject

MSF_SYSNTHESIZE_SINGLETON_FOR_CLASS_INTERFACE(ItemList, HITC);

/// Array of item
@property (nonatomic, readonly) NSArray *items;

/// Clear item list
- (void)clear;

/// Add launched item
- (void)addLaunchedItem:(HITCItem *)item;

/// Add item
- (void)addItem:(HITCItem *)item;

/// Remove item
- (void)removeItem:(HITCItem *)item;

@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Notification that the item was removed from list
extern NSString *const HITCItemDidRemoveFromListNotification;
/// Key for removed item
extern NSString *const HITCItemRemovedItemKey;
/// Notification that the launched item was added
extern NSString *const HITCItemListDidAddLaunchedItemNotification;
/// Key for launched item
extern NSString *const HITCItemListLaunchedItemKey;
