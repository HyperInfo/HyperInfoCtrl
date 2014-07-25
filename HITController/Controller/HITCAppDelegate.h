//
//  HITCAppDelegate.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/11/24.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDFileLogger.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCAppDelegate : UIResponder <UIApplicationDelegate>

/// The window
@property (strong, nonatomic) UIWindow *window;

/// File Logger
@property (nonatomic, strong) DDFileLogger *fileLogger;

@end
