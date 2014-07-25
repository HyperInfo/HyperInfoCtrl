//
//  HITCContentViewController.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/09.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HITCItem;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCContentViewController : UIViewController

/// WebView for content
@property (nonatomic, weak) IBOutlet UIWebView *webView;

/// The item
@property (nonatomic, strong) HITCItem *item;

@end
