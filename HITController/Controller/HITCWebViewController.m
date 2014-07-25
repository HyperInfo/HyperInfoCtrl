//
//  HITCWebViewController.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/11/24.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCWebViewController.h"
#import "HITCCommunicateWithTCP.h"
#import "HITCItemList.h"
#import "HITCItem.h"
#import "HITCMaster.h"
#import "HITCLocalhost.h"
#import "AFNetworking.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCWebViewController ()

@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCWebViewController

#pragma mark -
#pragma mark Override

//-----------------------------------------------------------------------------------
- (void)viewDidLoad
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super viewDidLoad];
    
    // Prepare transmit button
    [self HITCPrepareTransmitButton];
    
	// Setup WebView
    self.webView.scalesPageToFit = YES;
    
    // Update UI
    [self HITCUpdateUI];
    self.textField.placeholder = @"Open this address";
}

//-----------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

//-----------------------------------------------------------------------------------
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//-----------------------------------------------------------------------------------
{
    UIScreen *screen = [UIScreen mainScreen];
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        MSFCGRectAssignSize(self.textField.frame, CGSizeMake(CGRectGetHeight(screen.bounds), 20.0));
    }
    else {
        MSFCGRectAssignSize(self.textField.frame, CGSizeMake(CGRectGetHeight(screen.bounds), 30.0));
    }
}


#pragma mark -
#pragma mark UIWebViewDelegate

//-----------------------------------------------------------------------------------
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//-----------------------------------------------------------------------------------
{
    self.textField.text = [[request URL] absoluteString];
    
    return YES;
}

//-----------------------------------------------------------------------------------
- (void)webViewDidFinishLoad:(UIWebView *)webView
//-----------------------------------------------------------------------------------
{
    self.navigationItem.prompt = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.textField.text = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    
    if ([self.navigationItem.prompt length] < 1) {
        NSURL *url = [NSURL URLWithString:self.textField.text];
        self.navigationItem.prompt = [url lastPathComponent];
    }
    
    // Update UI
    [self HITCUpdateUI];
}


#pragma mark -
#pragma mark UITextFieldDelegate

//-----------------------------------------------------------------------------------
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//-----------------------------------------------------------------------------------
{
    self.navigationItem.rightBarButtonItem = nil;
    
    UIScreen *screen = [UIScreen mainScreen];
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        MSFCGRectAssignSize(self.textField.frame, CGSizeMake(CGRectGetHeight(screen.bounds), 20.0));
    }
    else {
        MSFCGRectAssignSize(self.textField.frame, CGSizeMake(CGRectGetWidth(screen.bounds), 30.0));
    }
    
    return YES;
}

//-----------------------------------------------------------------------------------
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//-----------------------------------------------------------------------------------
{
    // Prepare transmit button
    [self HITCPrepareTransmitButton];
    
    UIScreen *screen = [UIScreen mainScreen];
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        MSFCGRectAssignSize(self.textField.frame, CGSizeMake(CGRectGetHeight(screen.bounds) - 38.0, 20.0));
    }
    else {
        MSFCGRectAssignSize(self.textField.frame, CGSizeMake(CGRectGetWidth(screen.bounds) - 38.0, 30.0));
    }
    
    return YES;
}

//-----------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
//-----------------------------------------------------------------------------------
{
    // Hide keyboard
    [textField resignFirstResponder];
    
    if ([textField.text length]) {
        // Load web page
        [self HITCLoadWebPage:self.textField.text];
    }
    else {
        if (self.webView.request) {
            self.navigationItem.prompt = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
            self.textField.text = [self.webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
            
            if ([self.navigationItem.prompt length] < 1) {
                NSURL *url = [NSURL URLWithString:self.textField.text];
                self.navigationItem.prompt = [url lastPathComponent];
            }
        }
    }
    
    return YES;
}


#pragma mark -
#pragma mark Action

//-----------------------------------------------------------------------------------
- (IBAction)forwardPage:(id)sender
//-----------------------------------------------------------------------------------
{
    [self.webView goForward];
}

//-----------------------------------------------------------------------------------
- (IBAction)backPage:(id)sender
//-----------------------------------------------------------------------------------
{
    [self.webView goBack];
}

//-----------------------------------------------------------------------------------
- (IBAction)reload:(id)sender
//-----------------------------------------------------------------------------------
{
    // Reload web page
    [self HITCReloadWebPage];
}


#pragma mark -
#pragma mark Private

/// Prepare transmit button
//-----------------------------------------------------------------------------------
- (void)HITCPrepareTransmitButton
//-----------------------------------------------------------------------------------
{
    UIImage *image = [UIImage imageNamed:@"transmit.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(HITCTransmitURL:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button sizeToFit];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

/// Transmit URL
//-----------------------------------------------------------------------------------
- (void)HITCTransmitURL:(id)sender
//-----------------------------------------------------------------------------------
{
    // Adjust text position and size
    CGSize urlSize = CGSizeMake(600.0, 500.0);
    CGSize masterScreenSize = [HITCMaster screenSize];
    CGRect urlFrame = CGRectMake(floor((masterScreenSize.width - urlSize.width) * 0.5),
                                 floor((masterScreenSize.height - urlSize.height) * 0.5),
                                 urlSize.width,
                                 urlSize.height);
    
    // Get URL and title
    NSString *urlString = self.textField.text;
    NSString *title = self.navigationItem.prompt;
    
    // Add item
    HITCItem *item = [[HITCItem alloc] initWithItemType:HITCItemTypeWeb name:title tag:0];
    item.file = urlString;
    item.owner = [HITCLocalhost IPAddress];
    item.position = urlFrame.origin;
    item.size = urlFrame.size;
    item.focus = NO;
    item.date = [NSDate date];
    item.signature = [HITCLocalhost IPAddress];
    item.componentID = [[NSUUID UUID] UUIDString];
    item.contentSource = urlString;
    item.displayState = HITCItemDisplayStateNormal;
    item.normalPosition = urlFrame.origin;
    item.normalSize = urlFrame.size;
    item.selected = NO;
    item.image = nil;
    HITCItemList *sharedItemList = [HITCItemList sharedItemList];
    [sharedItemList addLaunchedItem:item];
    
    // Get favicon
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *faviconURLString = [NSString stringWithFormat:@"%@://%@/favicon.ico", [url scheme], [url host]];
    url = [NSURL URLWithString:faviconURLString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    AFImageRequestOperation *requestOperation = [AFImageRequestOperation imageRequestOperationWithRequest:urlRequest success:^(UIImage *image) {
        item.image = image;
    }];
    [requestOperation start];
    
    // Communicate with master
    HITCCommunicateWithTCP *sharedCommunicateWithTCP = [HITCCommunicateWithTCP sharedCommunicateWithTCP];
    [sharedCommunicateWithTCP createItem:item];
}

/// Load web page
//-----------------------------------------------------------------------------------
- (void)HITCLoadWebPage:(NSString *)pageURL
//-----------------------------------------------------------------------------------
{
    // Adjust URL string
    NSString *urlString = [self HITCURLStringWithString:pageURL];
    
    // Load web page
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

/// Reload web page
//-----------------------------------------------------------------------------------
- (void)HITCReloadWebPage
//-----------------------------------------------------------------------------------
{
    // Reload web page
    [self.webView reload];
}

/// Adds scheme if necessary
//-----------------------------------------------------------------------------------
- (NSString *)HITCURLStringWithString:(NSString *)string
//-----------------------------------------------------------------------------------
{
    // Returns string if length is zero.
    if ([string length] == 0) {
        return string;
    }
    
    // Get lowercase string
    NSString *lowercaseString = [string lowercaseString];
    
    // Returns string if string is "about:blank"
    if ([lowercaseString isEqualToString:@"about:blank"]) {
        return string;
    }
    
    // Returns string if string begins "http://"
    NSString *httpPrefix = @"http://";
    const NSUInteger httpPrefixLength = [httpPrefix length];
    if ([lowercaseString length] >= httpPrefixLength && [[lowercaseString substringToIndex:httpPrefixLength] isEqualToString:httpPrefix]) {
        return string;
    }
    
    // Returns string if string begins "https://"
    NSString *httpsPrefix = @"https://";
    const NSUInteger httpsPrefixLength = [httpsPrefix length];
    if ([lowercaseString length] >= httpsPrefixLength && [[lowercaseString substringToIndex:httpsPrefixLength] isEqualToString:httpsPrefix]) {
        return string;
    }
    
    // Returns string that "http://" is added
    string = [@"http://" stringByAppendingString:string];
    
    return string;
}

/// Updates UI state, appearance and so on
//-----------------------------------------------------------------------------------
- (void)HITCUpdateUI
//-----------------------------------------------------------------------------------
{
    // Update UI
    self.navigationItem.rightBarButtonItem.enabled = self.webView.request ? YES : NO;
    self.forwardPageBarButtonItem.enabled = self.webView.canGoForward;
    self.backPageBarButtonItem.enabled = self.webView.canGoBack;
    self.reloadPageBarButtonItem.enabled = self.webView.request ? YES : NO;
}

@end
