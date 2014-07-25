//
//  HITCItem.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/24.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <Foundation/Foundation.h>


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Item types
typedef enum {
    HITCItemTypeApplicaton  = -1,       ///< Application
    HITCItemTypeUnknown     = 0,        ///< Unknown
    HITCItemTypeImage       = 1,        ///< Image
    HITCItemTypeText        = 2,        ///< Text
    HITCItemTypeWeb         = 3,        ///< Web
    HITCItemTypePDF         = 4,        ///< PDF
    HITCItemTypeMovie       = 5,        ///< Movie
} HITCItemType;

/// Display states
typedef enum {
    HITCItemDisplayStateNormal      = 0,    ///< Normal
    HITCItemDisplayStateMinimized   = 1,    ///< Minimized
    HITCItemDisplayStateMaximized   = 2,    ///< Maximized
} HITCItemDisplayState;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Class of item
@interface HITCItem : NSObject

/// Item type
@property (nonatomic, assign) HITCItemType itemType;

/// Name
@property (nonatomic, copy) NSString *name;

/// File (Filename)
@property (nonatomic, copy) NSString *file;

/// Owner (IP Address)
@property (nonatomic, copy) NSString *owner;

/// Position
@property (nonatomic, assign) CGPoint position;

/// Size
@property (nonatomic, assign) CGSize size;

/// YES if focused
@property (nonatomic, assign) BOOL focus;

/// Date
@property (nonatomic, copy) NSDate *date;

/// Signature (IP Address)
@property (nonatomic, copy) NSString *signature;

/// Component ID
@property (nonatomic, copy) NSString *componentID;

/// Component source
@property (nonatomic, copy) NSString *contentSource;

/// Display state
@property (nonatomic, assign) HITCItemDisplayState displayState;

/// Normal position
@property (nonatomic, assign) CGPoint normalPosition;

/// Normal size
@property (nonatomic, assign) CGSize normalSize;

/// YES if selected
@property (nonatomic, assign, getter = isSelected) BOOL selected;

/// Tag
@property (nonatomic, assign) NSInteger tag;

/// Image
@property (nonatomic, strong) UIImage *image;

/// Text
@property (nonatomic, strong) NSString *text;

/// Icon image
@property (nonatomic, readonly) UIImage *iconImage;

/// Initializer
- (id)initWithItemType:(HITCItemType)type name:(NSString *)name tag:(NSInteger)tag;

@end
