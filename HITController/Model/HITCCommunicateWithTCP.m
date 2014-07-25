//
//  HITCCommunicateWithTCP.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/14.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCCommunicateWithTCP.h"
#import "HITCCommunicateWithHTTP.h"
#import "HITCControlMessage.h"
#import "HITCApplicationList.h"
#import "HITCApplication.h"
#import "HITCItemList.h"
#import "HITCItem.h"
#import "HITCLocalhost.h"
#import "HITCMaster.h"
#import "GCDAsyncSocket.h"
#import "AFNetworking.h"
#import "DDLog.h"
#import <arpa/inet.h>


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
/// Timeout time for reading
#define HITCTimeoutForReading   -1
/// Timeout time for writing
#define HITCTimeoutForWriting   -1


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCCommunicateWithTCP () <GCDAsyncSocketDelegate>
/// The AsyncSocket
@property (nonatomic, strong) GCDAsyncSocket *asyncSocket;
/// The AsyncSocket for current socket
@property (nonatomic, strong) GCDAsyncSocket *currentSocket;
/// Host name
@property (nonatomic, copy) NSString *hostName;
/// Yes if connected
@property (nonatomic, assign) BOOL connected;
@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCCommunicateWithTCP

MSF_SYNTHESIZE_SINGLETON_FOR_CLASS_IMPLEMENTATION(CommunicateWithTCP, HITC, HITCInitializeCommunicateWithTCP);

#pragma mark -
#pragma mark Public

//-----------------------------------------------------------------------------------
- (void)connectToAddressWithHostName:(NSString *)hostName
//-----------------------------------------------------------------------------------
{
    // Disconnect socket
    [self.asyncSocket disconnect];
    self.asyncSocket = nil;
    [self.currentSocket disconnect];
    self.currentSocket = nil;
    
    // Create and connect socket
    if (self.asyncSocket == nil) {
        self.hostName = hostName;
        
        self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        DDLogInfo(@"created socket:%p(%@:%hu)", self.asyncSocket, [self.asyncSocket localHost], [self.asyncSocket localPort]);
        
        [self HITCConnectToAddressWithSocket:self.asyncSocket];
    }
}

#if 0
//-----------------------------------------------------------------------------------
- (void)connectToNextAddress
//-----------------------------------------------------------------------------------
{
    BOOL done = NO;
    
    while (!done && ([self.serverAddresses count] > 0)) {
        NSData *addr = nil;
        
        // Note: The serverAddresses array probably contains both IPv4 and IPv6 addresses.
        //
        // If your server is also using GCDAsyncSocket then you don't have to worry about it,
        // as the socket automatically handles both protocols for you transparently.
        
        if (YES) { // Iterate forwards
            addr = [self.serverAddresses objectAtIndex:0];
            [self.serverAddresses removeObjectAtIndex:0];
        }
        else { // Iterate backwards
            addr = [self.serverAddresses lastObject];
            [self.serverAddresses removeLastObject];
        }
        
        DDLogVerbose(@"Attempting connection to %@", addr);
        
        NSError *err = nil;
        if ([self.asyncSocket connectToAddress:addr error:&err]) {
            done = YES;
        }
        else {
            DDLogWarn(@"Unable to connect: %@", err);
        }
    }
    
    if (!done) {
        DDLogWarn(@"Unable to connect to any resolved address");
    }
}
#endif

//-----------------------------------------------------------------------------------
- (void)disconnect
//-----------------------------------------------------------------------------------
{
    // Disconnect socket
    if (self.asyncSocket) {
        [self.asyncSocket disconnect];
        self.asyncSocket = nil;
        DDLogVerbose(@"Disconnected socket");
    }
}

//-----------------------------------------------------------------------------------
- (void)readDataFromSocket
//-----------------------------------------------------------------------------------
{
    // Read TCP data
    DDLogInfo(@"Waiting for reading data...");
    [self.currentSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:HITCTimeoutForReading tag:0];
}

//-----------------------------------------------------------------------------------
- (void)createItem:(HITCItem *)item
//-----------------------------------------------------------------------------------
{
    if (item == nil) {
        return;
    }
    
    // Make ControlMessage
    HITCControlMessage *controlMessage = [[HITCControlMessage alloc] init];
    controlMessage.type = [self HITCControlMessageTypeForItem:item];
    controlMessage.command = HITCControlMessageCommandCreate;
    controlMessage.name = item.name;
    controlMessage.file = item.file;
    controlMessage.owner = item.owner;
    controlMessage.position = item.position;
    controlMessage.size = item.size;
    controlMessage.focus = item.focus;
    controlMessage.date = item.date;
    controlMessage.signature = item.signature;
    controlMessage.componentID = item.componentID;
    controlMessage.contentSource = item.contentSource;
    controlMessage.displayState = [self HITCControlMessageDisplayStateForItem:item];
    controlMessage.normalPosition = item.normalPosition;
    controlMessage.normalSize = item.normalSize;
    controlMessage.selected = item.isSelected;
    
    NSData *XMLData = [controlMessage XMLData];
    
    // Transmit XML data
    [self.currentSocket writeData:XMLData withTimeout:HITCTimeoutForWriting tag:0];
//    DDLogInfo(@"Transmit XML:\n%@\n%@", XMLData, [controlMessage prettyXMLString]);
    DDLogInfo(@"Transmit XML:\n%@", [controlMessage prettyXMLString]);
}

//-----------------------------------------------------------------------------------
- (void)deleteItem:(HITCItem *)item
//-----------------------------------------------------------------------------------
{
    if (item == nil) {
        return;
    }
    
    // Make ControlMessage
    HITCControlMessage *controlMessage = [[HITCControlMessage alloc] init];
    controlMessage.type = [self HITCControlMessageTypeForItem:item];
    controlMessage.command = HITCControlMessageCommandDelete;
    controlMessage.name = item.name;
    controlMessage.owner = item.owner;
    controlMessage.position = item.position;
    controlMessage.size = item.size;
    controlMessage.focus = item.focus;
    controlMessage.date = [NSDate date];
    controlMessage.signature = item.signature;
    controlMessage.componentID = item.componentID;
    controlMessage.contentSource = item.contentSource;
    controlMessage.displayState = [self HITCControlMessageDisplayStateForItem:item];
    controlMessage.normalPosition = item.normalPosition;
    controlMessage.normalSize = item.normalSize;
    controlMessage.selected = item.isSelected;
    
    NSData *XMLData = [controlMessage XMLData];
    
    // Transmit XML data
    [self.currentSocket writeData:XMLData withTimeout:HITCTimeoutForWriting tag:0];
//    DDLogInfo(@"Transmit XML:\n%@\n%@", XMLData, [controlMessage prettyXMLString]);
    DDLogInfo(@"Transmit XML:\n%@", [controlMessage prettyXMLString]);
}

//-----------------------------------------------------------------------------------
- (void)moveItem:(HITCItem *)item deselected:(BOOL)deselected
//-----------------------------------------------------------------------------------
{
    if (item == nil) {
        return;
    }
    
    // Make ControlMessage
    HITCControlMessage *controlMessage = [[HITCControlMessage alloc] init];
    controlMessage.type = [self HITCControlMessageTypeForItem:item];
    controlMessage.command = HITCControlMessageCommandMove;
    controlMessage.name = item.name;
    controlMessage.owner = item.owner;
    controlMessage.position = item.position;
    controlMessage.size = item.size;
    controlMessage.focus = item.focus;
    controlMessage.date = [NSDate date];
    controlMessage.signature = item.signature;
    controlMessage.componentID = item.componentID;
    controlMessage.contentSource = item.contentSource;
    controlMessage.displayState = [self HITCControlMessageDisplayStateForItem:item];
    controlMessage.normalPosition = item.normalPosition;
    controlMessage.normalSize = item.normalSize;
    controlMessage.selected = deselected ? NO : YES;
    
    NSData *XMLData = [controlMessage XMLData];
    
    // Transmit XML data
    [self.currentSocket writeData:XMLData withTimeout:HITCTimeoutForWriting tag:0];
//    DDLogInfo(@"Transmit XML:\n%@\n%@", XMLData, [controlMessage prettyXMLString]);
    DDLogInfo(@"Transmit XML:\n%@", [controlMessage prettyXMLString]);
}

//-----------------------------------------------------------------------------------
- (void)resizeItem:(HITCItem *)item deselected:(BOOL)deselected
//-----------------------------------------------------------------------------------
{
    if (item == nil) {
        return;
    }
    
    // Make ControlMessage
    HITCControlMessage *controlMessage = [[HITCControlMessage alloc] init];
    controlMessage.type = [self HITCControlMessageTypeForItem:item];
    controlMessage.command = HITCControlMessageCommandSize;
    controlMessage.name = item.name;
    controlMessage.owner = item.owner;
    controlMessage.position = item.position;
    controlMessage.size = item.size;
    controlMessage.focus = item.focus;
    controlMessage.date = [NSDate date];
    controlMessage.signature = item.signature;
    controlMessage.componentID = item.componentID;
    controlMessage.contentSource = item.contentSource;
    controlMessage.displayState = [self HITCControlMessageDisplayStateForItem:item];
    controlMessage.normalPosition = item.normalPosition;
    controlMessage.normalSize = item.normalSize;
    controlMessage.selected = deselected ? NO : YES;
    
    NSData *XMLData = [controlMessage XMLData];
    
    // Transmit XML data
    [self.currentSocket writeData:XMLData withTimeout:HITCTimeoutForWriting tag:0];
//    DDLogInfo(@"Transmit XML:\n%@\n%@", XMLData, [controlMessage prettyXMLString]);
    DDLogInfo(@"Transmit XML:\n%@", [controlMessage prettyXMLString]);
}

//-----------------------------------------------------------------------------------
- (void)riseTopmost:(HITCItem *)item
//-----------------------------------------------------------------------------------
{
    if (item == nil) {
        return;
    }
    
    // Make ControlMessage
    HITCControlMessage *controlMessage = [[HITCControlMessage alloc] init];
    controlMessage.type = [self HITCControlMessageTypeForItem:item];
    controlMessage.command = HITCControlMessageCommandTopmost;
    controlMessage.name = item.name;
    controlMessage.owner = item.owner;
    controlMessage.position = item.position;
    controlMessage.size = item.size;
    controlMessage.focus = item.focus;
    controlMessage.date = [NSDate date];
    controlMessage.signature = item.signature;
    controlMessage.componentID = item.componentID;
    controlMessage.contentSource = item.contentSource;
    controlMessage.displayState = [self HITCControlMessageDisplayStateForItem:item];
    controlMessage.normalPosition = item.normalPosition;
    controlMessage.normalSize = item.normalSize;
    controlMessage.selected = YES;
    
    NSData *XMLData = [controlMessage XMLData];
    
    // Transmit XML data
    [self.currentSocket writeData:XMLData withTimeout:HITCTimeoutForWriting tag:0];
//    DDLogInfo(@"Transmit XML:\n%@\n%@", XMLData, [controlMessage prettyXMLString]);
    DDLogInfo(@"Transmit XML:\n%@", [controlMessage prettyXMLString]);
}


#pragma mark -
#pragma mark GCDAsyncSocketDelegate

//-----------------------------------------------------------------------------------
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
//-----------------------------------------------------------------------------------
{
    DDLogInfo(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    
    self.connected = YES;
    self.currentSocket = sock;
    
    // Read TCP data
    DDLogInfo(@"Waiting for reading data...");
	[sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:HITCTimeoutForReading tag:0];
}

//-----------------------------------------------------------------------------------
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
//-----------------------------------------------------------------------------------
{
	DDLogInfo(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

//-----------------------------------------------------------------------------------
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
//-----------------------------------------------------------------------------------
{
//	DDLogInfo(@"socket:%p didReadData:%@ withTag:%ld", sock, data, tag);
	DDLogInfo(@"socket:%p didReadData:... withTag:%ld", sock, tag);
	
    //
    HITCControlMessage *controlMessage = [[HITCControlMessage alloc] initWithXMLData:data];
    DDLogInfo(@"Received XML:\n%@", [controlMessage prettyXMLString]);
    
    // System
    if (controlMessage.type == HITCControlMessageTypeSystem) {
        if (controlMessage.command == HITCControlMessageCommandAccept) {
            if ([controlMessage.name isEqualToString:@"CONNECT_OK"]) {
                // Get self IP address
                struct sockaddr_in *sockaddr = (struct sockaddr_in *)[[sock localAddress] bytes];
                NSString *IPAddress = [NSString stringWithCString:inet_ntoa(sockaddr->sin_addr) encoding:NSUTF8StringEncoding];
                [HITCLocalhost setIPAddress:IPAddress];
                
                // Set master IP address and screen size
                [HITCMaster setIPAddress:controlMessage.owner];
                [HITCMaster setScreenSize:controlMessage.size];
                
                // Clear application list
                HITCApplicationList *sharedApplicationList = [HITCApplicationList sharedApplicationList];
                [sharedApplicationList clear];
                
                // Clear item list
                HITCItemList *sharedItemList = [HITCItemList sharedItemList];
                [sharedItemList clear];
                
                /// Start loading data using HTTP
                HITCCommunicateWithHTTP *sharedCommunicateWithHTTP = [HITCCommunicateWithHTTP sharedCommunicateWithHTTP];
                [sharedCommunicateWithHTTP loadDataUsingHTTPWithIPAddress:controlMessage.owner];
            }
            else {
                // Read TCP data
                DDLogInfo(@"Waiting for reading data...");
                [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:HITCTimeoutForReading tag:0];
            }
        }
        else {
            // Read TCP data
            DDLogInfo(@"Waiting for reading data...");
            [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:HITCTimeoutForReading tag:0];
        }
    }
    
    // Widget
    else if (controlMessage.type == HITCControlMessageTypeWidget) {
        if (controlMessage.command == HITCControlMessageCommandCreate) {
            // Search application image
            __block UIImage *image = nil;
            HITCApplicationList *sharedApplicationList = [HITCApplicationList sharedApplicationList];
            [sharedApplicationList.applications enumerateObjectsUsingBlock:^(HITCApplication *application, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.name isEqualToString:application.name]) {
                    image = application.image;
                    *stop = YES;
                }
            }];
            
            // Check whether same item exists
            __block BOOL sameItemExists = NO;
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    sameItemExists = YES;
                    *stop = YES;
                }
            }];
            
            if (sameItemExists == NO) {
                // Make application item
                HITCApplication *application = [[HITCApplication alloc] initWithWidgetName:controlMessage.name tag:0];
                application.applicationType = HITCApplicationTypeWidget;
                application.file = controlMessage.file;
                application.owner = controlMessage.owner;
                application.position = controlMessage.position;
                application.size = controlMessage.size;
                application.focus = controlMessage.focus;
                application.date = controlMessage.date;
                application.signature = controlMessage.signature;
                application.componentID = controlMessage.componentID;
                application.contentSource = controlMessage.contentSource;
                application.displayState = controlMessage.displayState;
                application.normalPosition = controlMessage.normalPosition;
                application.normalSize = controlMessage.normalSize;
                application.selected = controlMessage.isSelected;
                application.image = image;
                HITCItemList *sharedItemList = [HITCItemList sharedItemList];
                [sharedItemList addItem:application];
            }
        }
        else if (controlMessage.command == HITCControlMessageCommandDelete) {
            // Remove application item
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    [sharedItemList removeItem:item];
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandMove) {
            // Update position and size
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.position = controlMessage.position;
                    item.size = controlMessage.size;
                    item.normalPosition = controlMessage.normalPosition;
                    item.normalSize = controlMessage.normalSize;
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandSize) {
            // Update position and size
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.position = controlMessage.position;
                    item.size = controlMessage.size;
                    item.normalPosition = controlMessage.normalPosition;
                    item.normalSize = controlMessage.normalSize;
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandTopmost) {
            // Update focus
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.focus = controlMessage.focus;
                }
                else {
                    item.focus = NO;
                }
            }];
        }
        
        // Read TCP data
        DDLogInfo(@"Waiting for reading data...");
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:HITCTimeoutForReading tag:0];
    }
    
    // Plugin
    else if (controlMessage.type == HITCControlMessageTypePlugin) {
        if (controlMessage.command == HITCControlMessageCommandCreate) {
            // Search application image
            __block UIImage *image = nil;
            HITCApplicationList *sharedApplicationList = [HITCApplicationList sharedApplicationList];
            [sharedApplicationList.applications enumerateObjectsUsingBlock:^(HITCApplication *application, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.name isEqualToString:application.name]) {
                    image = application.image;
                    *stop = YES;
                }
            }];
            
            // Check whether same item exists
            __block BOOL sameItemExists = NO;
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    sameItemExists = YES;
                    *stop = YES;
                }
            }];
            
            if (sameItemExists == NO) {
                // Make application item
                HITCApplication *application = [[HITCApplication alloc] initWithWidgetName:controlMessage.name tag:0];
                application.applicationType = HITCApplicationTypePlugin;
                application.file = controlMessage.file;
                application.owner = controlMessage.owner;
                application.position = controlMessage.position;
                application.size = controlMessage.size;
                application.focus = controlMessage.focus;
                application.date = controlMessage.date;
                application.signature = controlMessage.signature;
                application.componentID = controlMessage.componentID;
                application.contentSource = controlMessage.contentSource;
                application.displayState = controlMessage.displayState;
                application.normalPosition = controlMessage.normalPosition;
                application.normalSize = controlMessage.normalSize;
                application.selected = controlMessage.isSelected;
                application.image = image;
                HITCItemList *sharedItemList = [HITCItemList sharedItemList];
                [sharedItemList addItem:application];
            }
        }
        else if (controlMessage.command == HITCControlMessageCommandDelete) {
            // Remove application item
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    [sharedItemList removeItem:item];
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandMove) {
            // Update position and size
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.position = controlMessage.position;
                    item.size = controlMessage.size;
                    item.normalPosition = controlMessage.normalPosition;
                    item.normalSize = controlMessage.normalSize;
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandSize) {
            // Update position and size
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.position = controlMessage.position;
                    item.size = controlMessage.size;
                    item.normalPosition = controlMessage.normalPosition;
                    item.normalSize = controlMessage.normalSize;
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandTopmost) {
            // Update focus
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.focus = controlMessage.focus;
                }
                else {
                    item.focus = NO;
                }
            }];
        }
        
        // Read TCP data
        DDLogInfo(@"Waiting for reading data...");
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:HITCTimeoutForReading tag:0];
    }
    
    // image
    else if (controlMessage.type == HITCControlMessageTypeImage) {
        if (controlMessage.command == HITCControlMessageCommandCreate) {
            // Check whether same item exists
            __block BOOL sameItemExists = NO;
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    sameItemExists = YES;
                    *stop = YES;
                }
            }];
            
            if (sameItemExists == NO) {
                // Make item
                HITCItem *item = [[HITCItem alloc] initWithItemType:HITCItemTypeImage name:controlMessage.name tag:0];
                item.file = controlMessage.file;
                item.owner = controlMessage.owner;
                item.position = controlMessage.position;
                item.size = controlMessage.size;
                item.focus = controlMessage.focus;
                item.date = controlMessage.date;
                item.signature = controlMessage.signature;
                item.componentID = controlMessage.componentID;
                item.contentSource = controlMessage.contentSource;
                item.displayState = controlMessage.displayState;
                item.normalPosition = controlMessage.normalPosition;
                item.normalSize = controlMessage.normalSize;
                item.selected = controlMessage.isSelected;
                HITCItemList *sharedItemList = [HITCItemList sharedItemList];
                [sharedItemList addItem:item];
                
                // Download image using HTTP
                HITCCommunicateWithHTTP *sharedCommunicateWithHTTP = [HITCCommunicateWithHTTP sharedCommunicateWithHTTP];
                [sharedCommunicateWithHTTP downloadImageFromIPAddress:controlMessage.owner filename:controlMessage.file item:item];
            }
        }
        else if (controlMessage.command == HITCControlMessageCommandDelete) {
            // Remove item
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    [sharedItemList removeItem:item];
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandMove) {
            // Update position and size
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.position = controlMessage.position;
                    item.size = controlMessage.size;
                    item.normalPosition = controlMessage.normalPosition;
                    item.normalSize = controlMessage.normalSize;
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandSize) {
            // Update position and size
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.position = controlMessage.position;
                    item.size = controlMessage.size;
                    item.normalPosition = controlMessage.normalPosition;
                    item.normalSize = controlMessage.normalSize;
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandTopmost) {
            // Update focus
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.focus = controlMessage.focus;
                }
                else {
                    item.focus = NO;
                }
            }];
        }
        
        // Read TCP data
        DDLogInfo(@"Waiting for reading data...");
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:HITCTimeoutForReading tag:0];
    }
    
    // text
    else if (controlMessage.type == HITCControlMessageTypeText) {
        if (controlMessage.command == HITCControlMessageCommandCreate) {
            // Check whether same item exists
            __block BOOL sameItemExists = NO;
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    sameItemExists = YES;
                    *stop = YES;
                }
            }];
            
            if (sameItemExists == NO) {
                // Make item
                HITCItem *item = [[HITCItem alloc] initWithItemType:HITCItemTypeText name:controlMessage.name tag:0];
                item.file = controlMessage.file;
                item.owner = controlMessage.owner;
                item.position = controlMessage.position;
                item.size = controlMessage.size;
                item.focus = controlMessage.focus;
                item.date = controlMessage.date;
                item.signature = controlMessage.signature;
                item.componentID = controlMessage.componentID;
                item.contentSource = controlMessage.contentSource;
                item.displayState = controlMessage.displayState;
                item.normalPosition = controlMessage.normalPosition;
                item.normalSize = controlMessage.normalSize;
                item.selected = controlMessage.isSelected;
                HITCItemList *sharedItemList = [HITCItemList sharedItemList];
                [sharedItemList addItem:item];
                
                // Download text using HTTP
                HITCCommunicateWithHTTP *sharedCommunicateWithHTTP = [HITCCommunicateWithHTTP sharedCommunicateWithHTTP];
                [sharedCommunicateWithHTTP downloadTextFromIPAddress:controlMessage.owner filename:controlMessage.file item:item];
            }
        }
        else if (controlMessage.command == HITCControlMessageCommandDelete) {
            // Remove item
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    [sharedItemList removeItem:item];
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandMove) {
            // Update position and size
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.position = controlMessage.position;
                    item.size = controlMessage.size;
                    item.normalPosition = controlMessage.normalPosition;
                    item.normalSize = controlMessage.normalSize;
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandSize) {
            // Update position and size
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.position = controlMessage.position;
                    item.size = controlMessage.size;
                    item.normalPosition = controlMessage.normalPosition;
                    item.normalSize = controlMessage.normalSize;
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandTopmost) {
            // Update focus
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.focus = controlMessage.focus;
                }
                else {
                    item.focus = NO;
                }
            }];
        }
        
        // Read TCP data
        DDLogInfo(@"Waiting for reading data...");
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:HITCTimeoutForReading tag:0];
    }
    
    // Web
    else if (controlMessage.type == HITCControlMessageTypeWeb) {
        if (controlMessage.command == HITCControlMessageCommandCreate) {
            // Check whether same item exists
            __block BOOL sameItemExists = NO;
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    sameItemExists = YES;
                    *stop = YES;
                }
            }];
            
            if (sameItemExists == NO) {
                // Make item
                HITCItem *item = [[HITCItem alloc] initWithItemType:HITCItemTypeText name:controlMessage.name tag:0];
                item.file = controlMessage.file;
                item.owner = controlMessage.owner;
                item.position = controlMessage.position;
                item.size = controlMessage.size;
                item.focus = controlMessage.focus;
                item.date = controlMessage.date;
                item.signature = controlMessage.signature;
                item.componentID = controlMessage.componentID;
                item.contentSource = controlMessage.contentSource;
                item.displayState = controlMessage.displayState;
                item.normalPosition = controlMessage.normalPosition;
                item.normalSize = controlMessage.normalSize;
                item.selected = controlMessage.isSelected;
                HITCItemList *sharedItemList = [HITCItemList sharedItemList];
                [sharedItemList addItem:item];
                
                // Download favicon
                NSURL *url = [NSURL URLWithString:item.file];
                NSString *faviconURLString = [NSString stringWithFormat:@"%@://%@/favicon.ico", [url scheme], [url host]];
                url = [NSURL URLWithString:faviconURLString];
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
                AFImageRequestOperation *requestOperation = [AFImageRequestOperation imageRequestOperationWithRequest:urlRequest success:^(UIImage *image) {
                    item.image = image;
                }];
                [requestOperation start];
            }
        }
        else if (controlMessage.command == HITCControlMessageCommandDelete) {
            // Remove item
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    [sharedItemList removeItem:item];
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandMove) {
            // Update position and size
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.position = controlMessage.position;
                    item.size = controlMessage.size;
                    item.normalPosition = controlMessage.normalPosition;
                    item.normalSize = controlMessage.normalSize;
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandSize) {
            // Update position and size
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.position = controlMessage.position;
                    item.size = controlMessage.size;
                    item.normalPosition = controlMessage.normalPosition;
                    item.normalSize = controlMessage.normalSize;
                    *stop = YES;
                }
            }];
        }
        else if (controlMessage.command == HITCControlMessageCommandTopmost) {
            // Update focus
            HITCItemList *sharedItemList = [HITCItemList sharedItemList];
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                if ([controlMessage.componentID isEqualToString:item.componentID]) {
                    item.focus = controlMessage.focus;
                }
                else {
                    item.focus = NO;
                }
            }];
        }
        
        // Read TCP data
        DDLogInfo(@"Waiting for reading data...");
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:HITCTimeoutForReading tag:0];
    }
    
    // pdf
    else if (controlMessage.type == HITCControlMessageTypePDF) {
        if (controlMessage.command == HITCControlMessageCommandCreate) {
        }
        else if (controlMessage.command == HITCControlMessageCommandDelete) {
        }
        else if (controlMessage.command == HITCControlMessageCommandMove) {
        }
        else if (controlMessage.command == HITCControlMessageCommandSize) {
        }
        else if (controlMessage.command == HITCControlMessageCommandTopmost) {
        }
        
        // Read TCP data
        DDLogInfo(@"Waiting for reading data...");
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:HITCTimeoutForReading tag:0];
    }
    
    // movie
    else if (controlMessage.type == HITCControlMessageTypeMovie) {
        if (controlMessage.command == HITCControlMessageCommandCreate) {
        }
        else if (controlMessage.command == HITCControlMessageCommandDelete) {
        }
        else if (controlMessage.command == HITCControlMessageCommandMove) {
        }
        else if (controlMessage.command == HITCControlMessageCommandSize) {
        }
        else if (controlMessage.command == HITCControlMessageCommandTopmost) {
        }
        
        // Read TCP data
        DDLogInfo(@"Waiting for reading data...");
        [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:HITCTimeoutForReading tag:0];
    }
}

//-----------------------------------------------------------------------------------
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
//-----------------------------------------------------------------------------------
{
    DDLogWarn(@"socketDidDisconnect:%p withError:%@", sock, err);
    
    if (!self.connected) {
        self.currentSocket = nil;
        [self HITCConnectToAddressWithSocket:self.asyncSocket];
    }
}


#pragma mark -
#pragma mark Private

/// Initialize
//-----------------------------------------------------------------------------------
- (void)HITCInitializeCommunicateWithTCP
//-----------------------------------------------------------------------------------
{
}

/// Connect to address with socket
//-----------------------------------------------------------------------------------
- (void)HITCConnectToAddressWithSocket:(GCDAsyncSocket *)sock
//-----------------------------------------------------------------------------------
{
    BOOL done = NO;
    
    DDLogVerbose(@"Attempting connection to %@", self.hostName);
    
    NSError *err = nil;
    if ([sock connectToHost:self.hostName onPort:50001 error:&err]) {
        done = YES;
    }
    else {
        DDLogWarn(@"Unable to connect: %@", err);
    }
    
    if (!done) {
        DDLogWarn(@"Unable to connect to any resolved address");
    }
}

//-----------------------------------------------------------------------------------
- (HITCControlMessageType)HITCControlMessageTypeForItem:(HITCItem *)item
//-----------------------------------------------------------------------------------
{
    HITCControlMessageType type = HITCControlMessageTypeSystem;
    if ([item isMemberOfClass:[HITCApplication class]]) {
        HITCApplication *application = (HITCApplication *)item;
        type = application.applicationType == HITCApplicationTypeWidget ? HITCControlMessageTypeWidget : HITCControlMessageTypePlugin;
    }
    else {
        switch (item.itemType) {
            case HITCItemTypeApplicaton:
                break;
                
            case HITCItemTypeUnknown:
                break;
                
            case HITCItemTypeImage:
                type = HITCControlMessageTypeImage;
                break;
                
            case HITCItemTypeText:
                type = HITCControlMessageTypeText;
                break;
                
            case HITCItemTypeWeb:
                type = HITCControlMessageTypeWeb;
                break;
                
            case HITCItemTypePDF:
                type = HITCControlMessageTypePDF;
                break;
                
            case HITCItemTypeMovie:
                type = HITCControlMessageTypeMovie;
                break;
        }
    }
    
    return type;
}

//-----------------------------------------------------------------------------------
- (HITCControlMessageDisplayState)HITCControlMessageDisplayStateForItem:(HITCItem *)item
//-----------------------------------------------------------------------------------
{
    HITCControlMessageDisplayState displayState = HITCControlMessageDisplayStateNormal;
    switch (item.displayState) {
        case HITCItemDisplayStateNormal:
            displayState = HITCControlMessageDisplayStateNormal;
            break;
            
        case HITCItemDisplayStateMinimized:
            displayState = HITCControlMessageDisplayStateMinimized;
            break;
            
        case HITCItemDisplayStateMaximized:
            displayState = HITCControlMessageDisplayStateMaximized;
            break;
    }
    
    return displayState;
}

@end
