//
//  HITCAlternativeZeroconf.m
//  HITController
//
//  Created by Masakazu Suetomo on 2013/08/12.
//  Copyright (c) 2013 Kyoto University. All rights reserved.
//

#import "HITCAlternativeZeroconf.h"
#import "GCDAsyncUdpSocket.h"
#import "DDLog.h"
#import "MSFCommon.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
NSString *const HITCAlternativeZeroconfDidConnectWithMasterNotification = @"HITCAlternativeZeroconfDidConnectWithMasterNotification";
NSString *const HITCAlternativeZeroconfMasterHostNameKey = @"HITCAlternativeZeroconfMasterHostNameKey";
NSString *const HITCAlternativeZeroconfDidDisconnectWithMasterNotification = @"HITCAlternativeZeroconfDidDisconnectWithMasterNotification";


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCAlternativeZeroconf ()
{
    GCDAsyncUdpSocket *_udpSocket;      ///< UDP socket
    NSString *_connectedHost;           ///< Connected host name
    BOOL _isServerResponsible;          ///< YES if the server is responsible
    NSTimer *_timer;                    ///< The timer
    long _tag;                          ///< Tag for sending data
}
@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCAlternativeZeroconf

MSF_SYNTHESIZE_SINGLETON_FOR_CLASS_IMPLEMENTATION(AlternativeZeroconf, HITC, HITCInitializeAlternativeZeroconf);

#pragma mark -
#pragma mark Public

//-----------------------------------------------------------------------------------
- (void)start
//-----------------------------------------------------------------------------------
{
    _connectedHost = nil;
    _isServerResponsible = NO;
    MSFInvalidateTimerSafely(_timer);
    
    // Stop if restart
    if (_udpSocket) {
        [self stop];
    }
    
    // Start browsing for bonjour services
    _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    
    if (![_udpSocket bindToPort:5051 error:&error]) {
        [self stop];
        DDLogError(@"Error bindToPort:error: %@", error);
        return;
    }
    
    if (![_udpSocket beginReceiving:&error]) {
        [self stop];
        DDLogError(@"Error beginReceiving: %@", error);
        return;
    }
    
    // Broadcast data
    [self _broadcastData];
    
    DDLogInfo(@"Started alternative Zeroconf.");
}

//-----------------------------------------------------------------------------------
- (void)stop
//-----------------------------------------------------------------------------------
{
    MSFInvalidateTimerSafely(_timer);
    _connectedHost = nil;
    _isServerResponsible = NO;
    
    if (_udpSocket) {
        [_udpSocket close];
    }
    
    DDLogInfo(@"Stoped alternative Zeroconf.");
}


#pragma mark -
#pragma mark GCDAsyncUdpSocketDelegate

//-----------------------------------------------------------------------------------
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
//-----------------------------------------------------------------------------------
{
    // You could add checks here
    DDLogInfo(@"We have sent data.");
    
    //
    if (_connectedHost == nil) {
        DDLogInfo(@"Searching server...");
        // Search server
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(_broadcastData)
                                                userInfo:nil
                                                 repeats:NO];
    }
    else {
        DDLogInfo(@"Is the server responsible?");
        // Prepare to conform whether server is responsible
        _timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(_confirmServerIsResposible)
                                                userInfo:nil
                                                 repeats:NO];
    }
}

//-----------------------------------------------------------------------------------
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
//-----------------------------------------------------------------------------------
{
    // You could add checks here
    DDLogError(@"Error udpSocket:didNotSendDataWithTag:dueToError: %@", error);
    
    // Broadcast data
    [self _broadcastData];
}

//-----------------------------------------------------------------------------------
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address withFilterContext:(id)filterContext
//-----------------------------------------------------------------------------------
{
    //
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (message) {
        MSFInvalidateTimerSafely(_timer);
        _isServerResponsible = YES;
        
        if (_connectedHost == nil) {
            DDLogInfo(@"The server has found.");
            
            // Server has found
            _connectedHost = message;
            
            // Post notification
            NSDictionary *userInfo = @{HITCAlternativeZeroconfMasterHostNameKey : _connectedHost};
            NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
            [defaultCenter postNotificationName:HITCAlternativeZeroconfDidConnectWithMasterNotification
                                         object:nil
                                       userInfo:userInfo];
        }
        else {
            DDLogInfo(@"The server is responsible.");
        }
        
        // Prepare to conform whether server is responsible
        _timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(_confirmServerIsResposible)
                                                userInfo:nil
                                                 repeats:NO];
    }
    else {
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        DDLogInfo(@"Unknown message received from: %@:%hu", host, port);
        
        // Broadcast data
        [self _broadcastData];
    }
}

//-----------------------------------------------------------------------------------
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
//-----------------------------------------------------------------------------------
{
    if (error) {
        DDLogError(@"udpSocketDidClose:withError: %@", error);
    }
    
    _udpSocket = nil;
}


#pragma mark -
#pragma mark Private

/// Initializer
//-----------------------------------------------------------------------------------
- (void)HITCInitializeAlternativeZeroconf
//-----------------------------------------------------------------------------------
{
}

/// Broadcast data
//-----------------------------------------------------------------------------------
- (void)_broadcastData
//-----------------------------------------------------------------------------------
{
    _timer = nil;
    
    [_udpSocket enableBroadcast:YES error:nil];
    
    NSString *message = @"_HyperInfo";
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [_udpSocket sendData:data toHost:@"255.255.255.255" port:5050 withTimeout:0.0 tag:_tag];
    
    DDLogInfo(@"Data sent (%i): %@", (int)_tag, message);
    
    _tag++;
}

/// Send data
//-----------------------------------------------------------------------------------
- (void)_sendData
//-----------------------------------------------------------------------------------
{
    _timer = nil;
    
    [_udpSocket enableBroadcast:NO error:nil];
    
    NSString *message = @"_HyperInfo";
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [_udpSocket sendData:data toHost:_connectedHost port:5050 withTimeout:0.0 tag:_tag];
    
    DDLogInfo(@"Data sent (%i): %@", (int)_tag, message);
    
    _tag++;
}

// Prepare to conform whether server is responsible
//-----------------------------------------------------------------------------------
- (void)_confirmServerIsResposible
//-----------------------------------------------------------------------------------
{
    if (_isServerResponsible) {
        _isServerResponsible = NO;
        
        // Send data
        [self _sendData];
    }
    else {
        DDLogInfo(@"The server is NOT responsible. Retry...");
        
        _connectedHost = nil;
        
        // Post notification
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter postNotificationName:HITCAlternativeZeroconfDidDisconnectWithMasterNotification
                                     object:nil];
        
        // Broadcast data
        [self _broadcastData];
    }
}

@end
