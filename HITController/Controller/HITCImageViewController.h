//
//  HITCImageViewController.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/11/24.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <UIKit/UIKit.h>


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCImageViewController : UIViewController

/// The ImageView
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

/// Show photo library
- (IBAction)showPhotoLibrary:(id)sender;

@end
