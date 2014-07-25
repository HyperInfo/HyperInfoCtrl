//
//  HITCStickiesViewController.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/11/24.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <UIKit/UIKit.h>


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCStickiesViewController : UIViewController <UITextViewDelegate>

/// The TextView
@property (nonatomic, weak) IBOutlet UITextView *textView;

/// Close button
@property (nonatomic, weak) IBOutlet UIBarButtonItem *closeBarButtonItem;

/// Hide keyboard
- (IBAction)hideKeyboard:(id)sender;

@end
