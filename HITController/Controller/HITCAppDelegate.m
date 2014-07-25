//
//  HITCAppDelegate.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/11/24.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCAppDelegate.h"
#import "HITCAlternativeZeroconf.h"
#import "HITCHTTPServer.h"
#import "HITCCommunicateWithTCP.h"
#import "HITCSearchingAlert.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCAppDelegate

#pragma mark -
#pragma mark Override

//-----------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//-----------------------------------------------------------------------------------
{
	DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] init];
	
	self.fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    
    // Configure our logging framework.
    // To keep things simple and fast, we're just going to log to the Xcode console.
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
	[DDLog addLogger:self.fileLogger];
    
    DDLogInfo(@"--------- S T A R T  A P P L I C A T I O N ---------");
    
    //
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(HITCDidConnectWithMaster:) name:HITCAlternativeZeroconfDidConnectWithMasterNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(HITCDidDisconnectWithMaster) name:HITCAlternativeZeroconfDidDisconnectWithMasterNotification object:nil];
    
    // Show searching alert
    [HITCSearchingAlert show];
    
    // Start HTTP server
    [self HITCStartHTTPServer];
    
    // Start Bonjour
    [self HITCStartBonjourForHyperInfoTerm];
    
    return YES;
}
							
//-----------------------------------------------------------------------------------
- (void)applicationWillResignActive:(UIApplication *)application
//-----------------------------------------------------------------------------------
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

//-----------------------------------------------------------------------------------
- (void)applicationDidEnterBackground:(UIApplication *)application
//-----------------------------------------------------------------------------------
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Disconnect
    HITCCommunicateWithTCP *sharedCommunicateWithTCP = [HITCCommunicateWithTCP sharedCommunicateWithTCP];
    [sharedCommunicateWithTCP disconnect];
    
    // Stop HTTP server
    [self HITCStopHTTPServer];
    
    // Stop Bonjour
    [self HITCStopBonjourForHyperInfoTerm];
}

//-----------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application
//-----------------------------------------------------------------------------------
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // Start HTTP server
    [self HITCStartHTTPServer];
    
    // Start Bonjour
    [self HITCStartBonjourForHyperInfoTerm];
}

//-----------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(UIApplication *)application
//-----------------------------------------------------------------------------------
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

//-----------------------------------------------------------------------------------
- (void)applicationWillTerminate:(UIApplication *)application
//-----------------------------------------------------------------------------------
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark -
#pragma mark Class Method

//-----------------------------------------------------------------------------------
+ (void)initialize
//-----------------------------------------------------------------------------------
{
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"UITabBarBackground.png"]];
    UIImage *image = [UIImage imageNamed:@"UITabBarActiveSegment.png"];
    [[UITabBar appearance] setSelectionIndicatorImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 4.0, 0.0, 4.0)]];
    
//    UIColor *tintColor = [UIColor colorWithRed:0.243 green:0.431 blue:0.553 alpha:1.000];     // Blue
    UIColor *tintColor = [UIColor colorWithRed:0.173 green:0.392 blue:0.196 alpha:1.000];       // Green
    [[UINavigationBar appearance] setTintColor:tintColor];
}


#pragma mark -
#pragma mark Private

/// Start HTTP server
//-----------------------------------------------------------------------------------
- (void)HITCStartHTTPServer
//-----------------------------------------------------------------------------------
{
    HITCHTTPServer *sharedHTTPServer = [HITCHTTPServer sharedHTTPServer];
    [sharedHTTPServer start];
}

/// Stop HTTP server
//-----------------------------------------------------------------------------------
- (void)HITCStopHTTPServer
//-----------------------------------------------------------------------------------
{
    HITCHTTPServer *sharedHTTPServer = [HITCHTTPServer sharedHTTPServer];
    [sharedHTTPServer stop];
}

/// Start bonjour for Hyper Info Term
//-----------------------------------------------------------------------------------
- (void)HITCStartBonjourForHyperInfoTerm
//-----------------------------------------------------------------------------------
{
    HITCAlternativeZeroconf *sharedAlternativeZeroconf = [HITCAlternativeZeroconf sharedAlternativeZeroconf];
    [sharedAlternativeZeroconf start];
}

/// Stop bonjour for Hyper Info Term
//-----------------------------------------------------------------------------------
- (void)HITCStopBonjourForHyperInfoTerm
//-----------------------------------------------------------------------------------
{
    HITCAlternativeZeroconf *sharedAlternativeZeroconf = [HITCAlternativeZeroconf sharedAlternativeZeroconf];
    [sharedAlternativeZeroconf stop];
}

//-----------------------------------------------------------------------------------
- (void)HITCDidConnectWithMaster:(NSNotification *)notification
//-----------------------------------------------------------------------------------
{
    // Connect to master
    NSString *hostName = [notification userInfo][HITCAlternativeZeroconfMasterHostNameKey];
    HITCCommunicateWithTCP *sharedCommunicateWithTCP = [HITCCommunicateWithTCP sharedCommunicateWithTCP];
    [sharedCommunicateWithTCP connectToAddressWithHostName:hostName];
    
    // Hide searching alert
    [HITCSearchingAlert hide];
}

//-----------------------------------------------------------------------------------
- (void)HITCDidDisconnectWithMaster
//-----------------------------------------------------------------------------------
{
    // Show searching alert
    [HITCSearchingAlert show];
}

@end
