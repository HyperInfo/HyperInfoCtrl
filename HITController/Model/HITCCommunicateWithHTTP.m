//
//  HITCCommunicateWithHTTP.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/30.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCCommunicateWithHTTP.h"
#import "HITCCommunicateWithTCP.h"
#import "HITCApplicationList.h"
#import "HITCApplication.h"
#import "HITCItem.h"
#import "HITCUtility.h"
#import "AFNetworking.h"
#import "DDLog.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCCommunicateWithHTTP

MSF_SYNTHESIZE_SINGLETON_FOR_CLASS_IMPLEMENTATION(CommunicateWithHTTP, HITC, HITCInitializeCommunicateWithHTTP);

#pragma mark -
#pragma mark Public

//-----------------------------------------------------------------------------------
- (void)loadDataUsingHTTPWithIPAddress:(NSString *)IPAddress
//-----------------------------------------------------------------------------------
{
    // Download widget info and plugin info
    [self HITCRequestNumberOfWidgetWithIPAddress:IPAddress];
}

//-----------------------------------------------------------------------------------
- (void)downloadImageFromIPAddress:(NSString *)IPAddress filename:(NSString *)filename item:(HITCItem *)item
//-----------------------------------------------------------------------------------
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:8080/cache/%@",
                           IPAddress,
                           filename];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    AFImageRequestOperation *requestOperation = [AFImageRequestOperation imageRequestOperationWithRequest:urlRequest
                                                                                     imageProcessingBlock:NULL
                                                                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                                      DDLogInfo(@"image = %@", image);
                                                                                                      
                                                                                                      item.image = image;
                                                                                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                                      DDLogWarn(@"error = %@", error);
                                                                                                      
                                                                                                      item.image = nil;
                                                                                                  }];
    
    [requestOperation start];
    DDLogVerbose(@"Attempting connection to %@", urlRequest);
}

//-----------------------------------------------------------------------------------
- (void)downloadTextFromIPAddress:(NSString *)IPAddress filename:(NSString *)filename item:(HITCItem *)item
//-----------------------------------------------------------------------------------
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:8080/cache/%@",
                           IPAddress,
                           filename];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSData *data = (NSData *)responseObject;
            NSString *text = [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
            DDLogInfo(@"text = %@", text);
            item.text = text;
        }
        else {
            DDLogWarn(@"responseObject class was %@", [responseObject class]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogWarn(@"error = %@", error);
    }];
    
    [requestOperation start];
    DDLogVerbose(@"Attempting connection to %@", urlRequest);
}


#pragma mark -
#pragma mark Class Method

//-----------------------------------------------------------------------------------
+ (NSString *)cacheFolderPath
//-----------------------------------------------------------------------------------
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *cachePath = paths[0];
    cachePath = [cachePath stringByAppendingPathComponent:[HITCUtility bundleName]];
//    cachePath = [imagePath stringByAppendingPathComponent:@"Web/cache"];
    cachePath = [cachePath stringByAppendingPathComponent:@"Web/Applications/cache"];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    
    return cachePath;
}


#pragma mark -
#pragma mark Private

/// Initialize
//-----------------------------------------------------------------------------------
- (void)HITCInitializeCommunicateWithHTTP
//-----------------------------------------------------------------------------------
{
}

/// Request number of widgets
//-----------------------------------------------------------------------------------
- (void)HITCRequestNumberOfWidgetWithIPAddress:(NSString *)IPAddress
//-----------------------------------------------------------------------------------
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:8080/NUMBER_OF_WIDGET", IPAddress];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSData *data = (NSData *)responseObject;
            NSString *dataString = [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
            NSInteger numberOfWidget = [dataString integerValue];
            DDLogInfo(@"numberOfWidget = %d", numberOfWidget);
        }
        else {
            DDLogWarn(@"responseObject class was %@", [responseObject class]);
        }
        
        [self HITCRequestWidgetNameListWithIPAddress:IPAddress];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogWarn(@"error = %@", error);
    }];
    
    [requestOperation start];
    DDLogVerbose(@"Attempting connection to %@", urlRequest);
}

/// Request widget names
//-----------------------------------------------------------------------------------
- (void)HITCRequestWidgetNameListWithIPAddress:(NSString *)IPAddress
//-----------------------------------------------------------------------------------
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:8080/WIDGET_NAME_LIST", IPAddress];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSData *data = (NSData *)responseObject;
            NSString *dataString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
            DDLogInfo(@"dataString = %@", dataString);
            
            NSInteger tag = 0;
            HITCApplicationList *sharedApplicationList = [HITCApplicationList sharedApplicationList];
            NSScanner *scanner = [NSScanner scannerWithString:dataString];
            NSString *scannedString = nil;
            while ([scanner scanUpToString:@";" intoString:&scannedString]) {
                [sharedApplicationList addWidget:scannedString tag:tag++];
                [scanner scanString:@";" intoString:NULL];
            }
            
            DDLogInfo(@"Application list = %@", sharedApplicationList.applications);
        }
        else {
            DDLogWarn(@"responseObject class was %@", [responseObject class]);
        }
        
        [self HITCRequestNumberOfPluginWithIPAddress:IPAddress];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogWarn(@"error = %@", error);
    }];
    
    [requestOperation start];
    DDLogVerbose(@"Attempting connection to %@", urlRequest);
}

/// Request number of plugins
//-----------------------------------------------------------------------------------
- (void)HITCRequestNumberOfPluginWithIPAddress:(NSString *)IPAddress
//-----------------------------------------------------------------------------------
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:8080/NUMBER_OF_PLUGIN", IPAddress];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSData *data = (NSData *)responseObject;
            NSString *dataString = [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
            NSInteger numberOfPlugin = [dataString integerValue];
            DDLogInfo(@"numberOfPlugin = %d", numberOfPlugin);
        }
        else {
            DDLogWarn(@"responseObject class was %@", [responseObject class]);
        }
        
        [self HITCRequestPluginNameListWithIPAddress:IPAddress];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogWarn(@"error = %@", error);
    }];
    
    [requestOperation start];
    DDLogVerbose(@"Attempting connection to %@", urlRequest);
}

/// Request plugin names
//-----------------------------------------------------------------------------------
- (void)HITCRequestPluginNameListWithIPAddress:(NSString *)IPAddress
//-----------------------------------------------------------------------------------
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:8080/PLUGIN_NAME_LIST", IPAddress];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSData class]]) {
            NSData *data = (NSData *)responseObject;
            NSString *dataString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
            DDLogInfo(@"dataString = %@", dataString);
            
            NSInteger tag = 0;
            HITCApplicationList *sharedApplicationList = [HITCApplicationList sharedApplicationList];
            NSScanner *scanner = [NSScanner scannerWithString:dataString];
            NSString *scannedString = nil;
            while ([scanner scanUpToString:@";" intoString:&scannedString]) {
                [sharedApplicationList addPlugin:scannedString tag:tag++];
                [scanner scanString:@";" intoString:NULL];
            }
            
            DDLogInfo(@"Application list = %@", sharedApplicationList.applications);
        }
        else {
            DDLogWarn(@"responseObject class was %@", [responseObject class]);
        }
        
        [self HITCRequestIconImageWithIPAddress:IPAddress];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogWarn(@"error = %@", error);
    }];
    
    [requestOperation start];
    DDLogVerbose(@"Attempting connection to %@", urlRequest);
}

/// Request icon images
//-----------------------------------------------------------------------------------
- (void)HITCRequestIconImageWithIPAddress:(NSString *)IPAddress
//-----------------------------------------------------------------------------------
{
    HITCApplicationList *sharedApplicationList = [HITCApplicationList sharedApplicationList];
    if ([sharedApplicationList.applications count] == 0) {
        return;
    }
    
    // Download icon image
    [self HITCDownloadIconImageWithIPAddress:IPAddress index:0];
}

/// Download icon image
//-----------------------------------------------------------------------------------
- (void)HITCDownloadIconImageWithIPAddress:(NSString *)IPAddress index:(NSInteger)index
//-----------------------------------------------------------------------------------
{
    HITCApplicationList *sharedApplicationList = [HITCApplicationList sharedApplicationList];
    if (index >= [sharedApplicationList.applications count]) {
        DDLogInfo(@"Application list = %@", sharedApplicationList.applications);
        
        // Read TCP data
        HITCCommunicateWithTCP *sharedCommunicateWithTCP = [HITCCommunicateWithTCP sharedCommunicateWithTCP];
        [sharedCommunicateWithTCP readDataFromSocket];
        
        return;
    }
    
    HITCApplication *application = sharedApplicationList.applications[index];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@:8080/%@_ICON_IMAGE?%d",
                           IPAddress,
                           application.applicationType == HITCApplicationTypeWidget ? @"WIDGET" : @"PLUGIN",
                           application.tag];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    AFImageRequestOperation *requestOperation = [AFImageRequestOperation imageRequestOperationWithRequest:urlRequest
                                                                                     imageProcessingBlock:NULL
                                                                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                                      DDLogInfo(@"image = %@", image);
                                                                                                      
                                                                                                      application.image = image;
                                                                                                      
                                                                                                      // Download icon image
                                                                                                      [self HITCDownloadIconImageWithIPAddress:IPAddress index:index + 1];
                                                                                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                                      DDLogWarn(@"error = %@", error);
                                                                                                      
                                                                                                      application.image = nil;
                                                                                                      
                                                                                                      // Download icon image
                                                                                                      [self HITCDownloadIconImageWithIPAddress:IPAddress index:index + 1];
                                                                                                  }];
    
    [requestOperation start];
    DDLogVerbose(@"Attempting connection to %@", urlRequest);
}

@end
