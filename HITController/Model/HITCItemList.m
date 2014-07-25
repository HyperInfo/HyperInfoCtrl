//
//  HITCItemList.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/24.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCItemList.h"
//#import "HITCItem.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
NSString *const HITCItemDidRemoveFromListNotification = @"HITCItemDidRemoveFromListNotification";
NSString *const HITCItemRemovedItemKey = @"HITCItemRemovedItemKey";
NSString *const HITCItemListDidAddLaunchedItemNotification = @"HITCItemListDidAddLaunchedItemNotification";
NSString *const HITCItemListLaunchedItemKey = @"HITCItemListLaunchedItemKey";


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCItemList ()
{
    __strong NSMutableArray *_items;        ///< Array of HITCItem
}
@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCItemList

MSF_SYNTHESIZE_SINGLETON_FOR_CLASS_IMPLEMENTATION(ItemList, HITC, HITCInitializeItemList);

#pragma mark -
#pragma mark Property

//-----------------------------------------------------------------------------------
- (NSArray *)items
//-----------------------------------------------------------------------------------
{
    if (_items == nil) {
        _items = [NSMutableArray arrayWithCapacity:16];
    }
    
    return _items;
}


#pragma mark -
#pragma mark Public

//-----------------------------------------------------------------------------------
- (void)clear
//-----------------------------------------------------------------------------------
{
    // Notification
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [_items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
        [defaultCenter postNotificationName:HITCItemDidRemoveFromListNotification object:self userInfo:@{HITCItemRemovedItemKey : item}];
    }];
    
    // Remove all items
    [self willChangeValueForKey:@"items"];
    [_items removeAllObjects];
    [self didChangeValueForKey:@"items"];
}

//-----------------------------------------------------------------------------------
- (void)addLaunchedItem:(HITCItem *)item
//-----------------------------------------------------------------------------------
{
    // Add item
    [self addItem:item];
    
    // Notification
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter postNotificationName:HITCItemListDidAddLaunchedItemNotification
                                 object:nil
                               userInfo:@{HITCItemListLaunchedItemKey : item}];
}

//-----------------------------------------------------------------------------------
- (void)addItem:(HITCItem *)item
//-----------------------------------------------------------------------------------
{
    if (item) {
        // Allocate item list
        if (_items == nil) {
            _items = [NSMutableArray arrayWithCapacity:16];
        }
        
        // Add item
        [self willChangeValueForKey:@"items"];
        [_items addObject:item];
        [self didChangeValueForKey:@"items"];
    }
}

//-----------------------------------------------------------------------------------
- (void)removeItem:(HITCItem *)item
//-----------------------------------------------------------------------------------
{
    if (item) {
        // Notification
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter postNotificationName:HITCItemDidRemoveFromListNotification object:self userInfo:@{HITCItemRemovedItemKey : item}];
        
        // Remove item
        [self willChangeValueForKey:@"items"];
        [_items removeObject:item];
        [self didChangeValueForKey:@"items"];
    }
}


#pragma mark -
#pragma mark Private

/// Initialize
//-----------------------------------------------------------------------------------
- (void)HITCInitializeItemList
//-----------------------------------------------------------------------------------
{
}

@end
