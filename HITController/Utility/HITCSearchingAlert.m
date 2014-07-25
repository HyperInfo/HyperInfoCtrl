//
//  HITCSearchingAlert.m
//  HITController
//
//  Created by Masakazu Suetomo on 2013/02/01.
//  Copyright (c) 2013 Kyoto University. All rights reserved.
//

#import "HITCSearchingAlert.h"
#import "MSFCommon.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCSearchingAlert

static __strong UIAlertView *alertView = nil;

//-----------------------------------------------------------------------------------
+ (void)show
//-----------------------------------------------------------------------------------
{
    alertView = [[UIAlertView alloc] initWithTitle:@""
                                           message:@"Searching Master..."
                                          delegate:nil
                                 cancelButtonTitle:nil
                                 otherButtonTitles:nil];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    MSFCGRectAssignOrigin(activityIndicator.frame, CGPointMake(132.0, 64.0));
    [activityIndicator startAnimating];
    
    [alertView addSubview:activityIndicator];
    [alertView show];
}

//-----------------------------------------------------------------------------------
+ (void)hide
//-----------------------------------------------------------------------------------
{
    if (alertView) {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        alertView = nil;
    }
}

@end
