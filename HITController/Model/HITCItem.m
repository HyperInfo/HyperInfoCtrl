//
//  HITCItem.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/24.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCItem.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCItem ()
{
    __strong UIImage *_iconImage;       ///< Icon image cache
}
@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCItem

//-----------------------------------------------------------------------------------
- (id)initWithItemType:(HITCItemType)type name:(NSString *)name tag:(NSInteger)tag
//-----------------------------------------------------------------------------------
{
    self = [super init];
    if (self) {
        self.itemType = type;
        self.name = name;
        self.tag = tag;
    }
    
    return self;
}


#pragma mark -
#pragma mark Override

//-----------------------------------------------------------------------------------
- (NSString *)description
//-----------------------------------------------------------------------------------
{
    return [NSString stringWithFormat:@"%@: %@: tag=%d: %@: %@",
            [super description],
            self.name,
            self.tag,
            self.image,
            self.iconImage];
}


#pragma mark -
#pragma mark Property

//-----------------------------------------------------------------------------------
- (void)setImage:(UIImage *)image
//-----------------------------------------------------------------------------------
{
    [self willChangeValueForKey:@"image"];
    _iconImage = nil;
    _image = image;
    [self didChangeValueForKey:@"image"];
}

//-----------------------------------------------------------------------------------
- (UIImage *)iconImage
//-----------------------------------------------------------------------------------
{
    if (_iconImage == nil && self.image) {
        CGSize iconSize = CGSizeMake(43.0 * 2, 43.0 * 2);     // pixels
        CGRect iconRect = {0.0, 0.0, iconSize.width, iconSize.height};
        
        UIGraphicsBeginImageContext(iconSize);
        [self.image drawInRect:iconRect];
        _iconImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return _iconImage;
}

@end
