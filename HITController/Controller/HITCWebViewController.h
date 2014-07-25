//
//  HITCWebViewController.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/11/24.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <UIKit/UIKit.h>


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCWebViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate>

/// The WebView
@property (nonatomic, weak) IBOutlet UIWebView *webView;

/// The TextField for URL
@property (nonatomic, weak) IBOutlet UITextField *textField;

/// Forward web page button
@property (nonatomic, weak) IBOutlet UIBarButtonItem *forwardPageBarButtonItem;

/// Back web page button
@property (nonatomic, weak) IBOutlet UIBarButtonItem *backPageBarButtonItem;

/// Reload web page button
@property (nonatomic, weak) IBOutlet UIBarButtonItem *reloadPageBarButtonItem;

/// Forward web page
- (IBAction)forwardPage:(id)sender;

/// Back web page
- (IBAction)backPage:(id)sender;

/// Reload web page
- (IBAction)reload:(id)sender;

@end
