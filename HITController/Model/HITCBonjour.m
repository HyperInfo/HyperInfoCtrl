//
//  HITCBonjour.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/14.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCBonjour.h"
#import "DDLog.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
NSString *const HITCBonjourDidConnectWithMasterNotification = @"HITCBonjourDidConnectWithMasterNotification";
NSString *const HITCBonjourMasterHostNameKey = @"HITCBonjourMasterHostNameKey";
NSString *const HITCBonjourDidDisconnectWithMasterNotification = @"HITCBonjourDidDisconnectWithMasterNotification";


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCBonjour () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
/// The NetServiceBrowser
@property (nonatomic, strong) NSNetServiceBrowser *netServiceBrowser;
/// Server service
@property (nonatomic, strong) NSNetService *serverService;
@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCBonjour

MSF_SYNTHESIZE_SINGLETON_FOR_CLASS_IMPLEMENTATION(Bonjour, HITC, HITCInitializeBonjour);

#pragma mark -
#pragma mark NSNetServiceBrowserDelegate

//-----------------------------------------------------------------------------------
- (void)netServiceBrowser:(NSNetServiceBrowser *)sender didNotSearch:(NSDictionary *)errorInfo
//-----------------------------------------------------------------------------------
{
    DDLogError(@"DidNotSearch: %@", errorInfo);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bonjour server not found"
                                                        message:@"Connection could not established"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

//-----------------------------------------------------------------------------------
- (void)netServiceBrowser:(NSNetServiceBrowser *)sender
           didFindService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
//-----------------------------------------------------------------------------------
{
    DDLogVerbose(@"DidFindService: domain(%@) type(%@) name(%@)", [netService domain], [netService type], [netService name]);
    
    // Connect to the first service we find
    
    if (self.serverService == nil) {
        DDLogVerbose(@"Resolving...");
        
        self.serverService = netService;
//        self.serverService = [[NSNetService alloc] initWithDomain:[netService domain] type:[netService type] name:[netService hostName] port:50001];
        
        [self.serverService setDelegate:self];
        [self.serverService resolveWithTimeout:5.0];
    }
}

//-----------------------------------------------------------------------------------
- (void)netServiceBrowser:(NSNetServiceBrowser *)sender
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
//-----------------------------------------------------------------------------------
{
    DDLogVerbose(@"DidRemoveService: %@", [netService name]);
    
    self.serverService = nil;
    
    // Notification
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter postNotificationName:HITCBonjourDidDisconnectWithMasterNotification object:nil];
}

//-----------------------------------------------------------------------------------
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)sender
//-----------------------------------------------------------------------------------
{
    DDLogInfo(@"DidStopSearch");
}


#pragma mark -
#pragma mark NSNetServiceDelegate

//-----------------------------------------------------------------------------------
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
//-----------------------------------------------------------------------------------
{
    DDLogError(@"DidNotResolve: %@", errorDict);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bonjour server not found"
                                                        message:@"Connection could not established"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    [alertView show];
}

//-----------------------------------------------------------------------------------
- (void)netServiceDidResolveAddress:(NSNetService *)sender
//-----------------------------------------------------------------------------------
{
    DDLogInfo(@"DidResolve: %@", [sender addresses]);
    
    // Notification
    NSDictionary *userInfo = @{HITCBonjourMasterHostNameKey : [self.serverService hostName]};
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter postNotificationName:HITCBonjourDidConnectWithMasterNotification object:nil userInfo:userInfo];
}


#pragma mark -
#pragma mark Public

//-----------------------------------------------------------------------------------
- (void)start
//-----------------------------------------------------------------------------------
{
    // Stop if restart
    if (self.netServiceBrowser) {
        [self stop];
    }
    
    // Start browsing for bonjour services
    self.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    self.netServiceBrowser.delegate = self;
    [self.netServiceBrowser searchForServicesOfType:@"_hyperinfoterm._tcp." inDomain:@""];
    DDLogInfo(@"Started Bonjour");
}

//-----------------------------------------------------------------------------------
- (void)stop
//-----------------------------------------------------------------------------------
{
    if (self.netServiceBrowser) {
        [self.netServiceBrowser stop];
        self.netServiceBrowser = nil;
        self.serverService = nil;
    }
    DDLogInfo(@"Stoped Bonjour");
}


#pragma mark -
#pragma mark Private

/// Initialize
//-----------------------------------------------------------------------------------
- (void)HITCInitializeBonjour
//-----------------------------------------------------------------------------------
{
}

@end
