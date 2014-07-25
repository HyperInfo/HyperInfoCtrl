//
//  HITCApplicationCell.m
//  HITController
//
//  Created by Masakazu Suetomo on 2013/07/12.
//  Copyright (c) 2013 Kyoto University. All rights reserved.
//

#import "HITCApplicationCell.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCApplicationCell

//-----------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
//-----------------------------------------------------------------------------------
{
    if (self = [super initWithFrame:frame]) {
        // UILabel
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.textColor = [UIColor blackColor];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
        
        // UIImageView
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.imageView];
    }
    
    return self;
}


#pragma mark -
#pragma mark Override

//-----------------------------------------------------------------------------------
- (void)layoutSubviews
//-----------------------------------------------------------------------------------
{
    if (CGRectGetWidth(self.bounds) <= CGRectGetHeight(self.bounds)) {
        // UILabel
        CGFloat labelHeight = 18.0;
        CGFloat x = 5.0;
        CGFloat y = CGRectGetMaxY(self.bounds) - labelHeight;
        CGFloat width = CGRectGetWidth(self.bounds) - x * 2;
        CGFloat height = labelHeight;
        CGRect frame = CGRectMake(x, y, width, height);
        self.label.font = [UIFont boldSystemFontOfSize:12.0];
        self.label.frame = frame;
        
        // UIImageView
        x = 10.0;
        y = 10.0;
        width = CGRectGetWidth(self.bounds) - x * 2;
        height = width;
        frame = CGRectMake(x, y, width, height);
        self.imageView.frame = frame;
    }
    else {
        // UILabel
        CGFloat labelHeight = 10.0;
        CGFloat x = 5.0;
        CGFloat y = CGRectGetMaxY(self.bounds) - labelHeight;
        CGFloat width = CGRectGetWidth(self.bounds) - x * 2;
        CGFloat height = labelHeight;
        CGRect frame = CGRectMake(x, y, width, height);
        self.label.font = [UIFont boldSystemFontOfSize:10.0];
        self.label.frame = frame;
        
        // UIImageView
        x = 0.0;
        y = 0.0;
        width = (CGRectGetHeight(self.bounds) - x * 2) * 0.9 - CGRectGetHeight(self.label.frame);
        height = width;
        
        frame = CGRectMake(x, y, width, height);
        self.imageView.frame = frame;
        
        // Adjust UIImageView position
        CGFloat gap = CGRectGetWidth(self.bounds) - CGRectGetWidth(self.imageView.frame);
        if (gap > 0.0) {
            x = gap * 0.5;
        }
        MSFCGRectAssignX(self.imageView.frame, x);
        
        gap = CGRectGetMinY(self.label.frame) - CGRectGetHeight(self.imageView.frame);
        if (gap > 0.0) {
            y = gap * 0.5;
        }
        MSFCGRectAssignY(self.imageView.frame, y);
    }
}

//-----------------------------------------------------------------------------------
- (void)prepareForReuse
//-----------------------------------------------------------------------------------
{
    // Clean up
    self.label.text = @"";
    self.imageView.image = nil;
}

//-----------------------------------------------------------------------------------
- (void)setHighlighted:(BOOL)highlighted
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super setHighlighted:highlighted];
    
    // Adjust alpha
    self.alpha = highlighted ? 0.7 : 1.0;
}

@end
