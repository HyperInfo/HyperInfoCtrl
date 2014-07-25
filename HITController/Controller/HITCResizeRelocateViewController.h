//
//  HITCResizeRelocateViewController.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/07.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HITCItem;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCResizeRelocateViewController : UIViewController

/// Content BarButtonItem
@property (nonatomic, weak) IBOutlet UIBarButtonItem *contentBarButtonItem;

/// The item
@property (nonatomic, strong) HITCItem *item;

@end
