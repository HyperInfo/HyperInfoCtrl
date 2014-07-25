//
//  HITCContentViewController.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/09.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCContentViewController.h"
#import "HITCItemList.h"
#import "HITCItem.h"
#import "HITCMaster.h"
#import "DDLog.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCContentViewController ()

@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCContentViewController

#pragma mark -
#pragma mark Override


//-----------------------------------------------------------------------------------
- (void)viewDidLoad
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super viewDidLoad];
    
    // Adjust title
    self.title = self.item.name;
    
	// Load web content
    NSString *urlString = [NSString stringWithFormat:@"http://%@:8080/%@/", [HITCMaster IPAddress], self.item.name];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:urlRequest];
    DDLogVerbose(@"Attempting connection to %@", urlRequest);
    
    // Add Observer
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(HITCDidRemoveItemFromList:) name:HITCItemDidRemoveFromListNotification object:nil];
}

//-----------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Private

/// Invoke if item was removed from list
//-----------------------------------------------------------------------------------
- (void)HITCDidRemoveItemFromList:(NSNotification *)notification
//-----------------------------------------------------------------------------------
{
    id item = [notification userInfo][HITCItemRemovedItemKey];
    if (item == self.item) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
