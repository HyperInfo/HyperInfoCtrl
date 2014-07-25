//
//  HITCPseudoTrackpadView.m
//  HITController
//
//  Created by Masakazu Suetomo on 2013/01/25.
//  Copyright (c) 2013 Kyoto University. All rights reserved.
//

#import "HITCPseudoTrackpadView.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCPseudoTrackpadView

//-----------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame
//-----------------------------------------------------------------------------------
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialize view
        [self HITCInitializeView];
    }
    
    return self;
}


#pragma mark -
#pragma mark Override

//-----------------------------------------------------------------------------------
- (void)awakeFromNib
//-----------------------------------------------------------------------------------
{
    // Initialize view
    [self HITCInitializeView];
}

//-----------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
//-----------------------------------------------------------------------------------
{
}


#pragma mark -
#pragma mark Private

/// Initialize view
//-----------------------------------------------------------------------------------
- (void)HITCInitializeView
//-----------------------------------------------------------------------------------
{
    self.padView.frame = CGRectInset(self.padView.frame, 16.0, 16.0);
    self.padView.userInteractionEnabled = NO;
    self.padView.layer.cornerRadius = 16.0;
    self.padView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.padView.layer.borderWidth = 1.0;
    self.padView.layer.shadowOpacity = 0.5;
    self.padView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
}

@end
