//
//  HITCHTTPServer.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/14.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCHTTPServer.h"
#import "HITCUtility.h"
#import "HTTPServer.h"
#import "DDLog.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCHTTPServer ()
/// The HTTP server
@property (nonatomic, strong) HTTPServer *httpServer;
@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCHTTPServer

MSF_SYNTHESIZE_SINGLETON_FOR_CLASS_IMPLEMENTATION(HTTPServer, HITC, HITCInitializeHTTPServer);

#pragma mark -
#pragma mark Public

//-----------------------------------------------------------------------------------
- (void)start
//-----------------------------------------------------------------------------------
{
    // Create server using our custom MyHTTPServer class
    self.httpServer = [[HTTPServer alloc] init];
    
    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [self.httpServer setType:@"_http._tcp."];
    
    // Normally there's no need to run our server on any specific port.
    // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
    // However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [self.httpServer setPort:8080];
    
    // Prepares document root path and index.html
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = paths[0];
    NSString *bundleName = [HITCUtility bundleName];
    documentRootPath = [documentRootPath stringByAppendingPathComponent:bundleName];
    documentRootPath = [documentRootPath stringByAppendingPathComponent:@"Web"];
    
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager createDirectoryAtPath:documentRootPath withIntermediateDirectories:YES attributes:nil error:NULL];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *applicationsPath = [bundle pathForResource:@"Applications" ofType:@""];
    documentRootPath = [documentRootPath stringByAppendingPathComponent:@"Applications"];
    
    if ([defaultManager fileExistsAtPath:documentRootPath] == NO) {
        [defaultManager copyItemAtPath:applicationsPath toPath:documentRootPath error:NULL];
    }
    
    // Serve files from our embedded Web folder
    [self.httpServer setDocumentRoot:documentRootPath];
    DDLogInfo(@"Setting document root: %@", documentRootPath);
    
    // Start the server (and check for problems)
    NSError *error = nil;
    if([self.httpServer start:&error]) {
        DDLogInfo(@"Started HTTP Server on port %hu", [self.httpServer listeningPort]);
    }
    else {
        DDLogError(@"Error starting HTTP Server: %@", error);
    }
}

//-----------------------------------------------------------------------------------
- (void)stop
//-----------------------------------------------------------------------------------
{
    [self.httpServer stop];
    self.httpServer = nil;
    DDLogInfo(@"Stoped HTTP Server");
}


#pragma mark -
#pragma mark Private

/// Initialize
//-----------------------------------------------------------------------------------
- (void)HITCInitializeHTTPServer
//-----------------------------------------------------------------------------------
{
}

@end
