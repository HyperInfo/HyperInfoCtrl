//
//  HITCImageViewController.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/11/24.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCImageViewController.h"
#import "HITCCommunicateWithTCP.h"
#import "HITCCommunicateWithHTTP.h"
#import "HITCItemList.h"
#import "HITCItem.h"
#import "HITCMaster.h"
#import "HITCLocalhost.h"
#import "DDLog.h"
#import <math.h>


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCImageViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>
/// Image name
@property (nonatomic, strong) NSString *imageName;
/// Original Y position for imageView
@property (nonatomic, assign) CGFloat imageViewOriginalY;
/// Previous touch location
@property (nonatomic, assign) CGPoint previousLocation;
@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCImageViewController

#pragma mark -
#pragma mark Override

//-----------------------------------------------------------------------------------
- (void)viewDidLoad
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super viewDidLoad];
    
    // Adjust navigation bar's translucent
    self.navigationController.navigationBar.translucent = YES;
    
    // Prepare right BarbuttonItem
    UIImage *image = [UIImage imageNamed:@"transmit.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(HITCTransmitImage:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button sizeToFit];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // Add pan gesture recognizer
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(HITCImagePanned:)];
    gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // Store original Y position
    self.imageViewOriginalY = CGRectGetMinY(self.imageView.frame);
    
    // Clear image
    self.imageView.image = nil;
}

//-----------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super viewWillAppear:animated];
    
    // Adjusts buttons Hidden
    if (self.imageView.image) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    // Show photo library
    if (self.imageView.image == nil) {
        [self HITCShowPhotoLibraryAnimated:NO];
    }
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
#pragma mark Action

//-----------------------------------------------------------------------------------
- (IBAction)showPhotoLibrary:(id)sender
//-----------------------------------------------------------------------------------
{
    // Show photo library
    [self HITCShowPhotoLibraryAnimated:YES];
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate

//-----------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-----------------------------------------------------------------------------------
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    NSURL *imageURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    self.imageName = [self HITCImageNameWithURL:imageURL];
    
    // Hide photo library
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    // Update UI
    self.navigationItem.rightBarButtonItem.enabled = YES;
}


#pragma mark -
#pragma mark UIGestureRecognizerDelegate

//-----------------------------------------------------------------------------------
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//-----------------------------------------------------------------------------------
{
    self.previousLocation = [gestureRecognizer locationInView:self.view];
    
    return YES;
}


#pragma mark -
#pragma mark Private

/// Transmit image
//-----------------------------------------------------------------------------------
- (void)HITCTransmitImage:(id)sender
//-----------------------------------------------------------------------------------
{
    // Rotate image if necessary
    UIImage *image = self.imageView.image;
    
    if (image.imageOrientation == UIImageOrientationDown) {
        UIGraphicsBeginImageContext(image.size);
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(contextRef, image.size.width * 0.5, image.size.height * 0.5);
        CGContextRotateCTM(contextRef, M_PI / 180.0 * 180.0);
        CGContextScaleCTM(contextRef, 1.0, -1.0);
        CGRect rect = CGRectMake(-image.size.width * 0.5, -image.size.height * 0.5, image.size.width, image.size.height);
        CGContextDrawImage(contextRef, rect, [image CGImage]);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else if (image.imageOrientation == UIImageOrientationLeft) {
        UIGraphicsBeginImageContext(image.size);
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(contextRef, image.size.width * 0.5, image.size.height * 0.5);
        CGContextRotateCTM(contextRef, M_PI / 180.0 * -90.0);
        CGContextScaleCTM(contextRef, 1.0, -1.0);
        CGRect rect = CGRectMake(-image.size.height * 0.5, -image.size.width * 0.5, image.size.height, image.size.width);
        CGContextDrawImage(contextRef, rect, [image CGImage]);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else if (image.imageOrientation == UIImageOrientationRight) {
        UIGraphicsBeginImageContext(image.size);
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(contextRef, image.size.width * 0.5, image.size.height * 0.5);
        CGContextRotateCTM(contextRef, M_PI / 180.0 * 90.0);
        CGContextScaleCTM(contextRef, 1.0, -1.0);
        CGRect rect = CGRectMake(-image.size.height * 0.5, -image.size.width * 0.5, image.size.height, image.size.width);
        CGContextDrawImage(contextRef, rect, [image CGImage]);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Adjust image position and size
    CGSize imageSize = image.size;
    CGSize masterScreenSize = [HITCMaster screenSize];
    CGSize reducedMasterScreenSize = CGSizeMake(masterScreenSize.width * 0.8, masterScreenSize.height * 0.8);       // Reduce 80% the screen size
    if (image.size.width > reducedMasterScreenSize.width || image.size.width > reducedMasterScreenSize.width) {
        CGFloat widthRatio = image.size.width / reducedMasterScreenSize.width;
        CGFloat heightRatio = image.size.height / reducedMasterScreenSize.height;
        
        if (widthRatio >= heightRatio) {
            imageSize = CGSizeMake(floor(image.size.width / widthRatio),
                                   floor(image.size.height / widthRatio));
        }
        else {
            imageSize = CGSizeMake(floor(image.size.width / heightRatio),
                                   floor(image.size.height / heightRatio));
        }
    }
    
    CGRect imageFrame = CGRectMake(floor((masterScreenSize.width - imageSize.width) * 0.5),
                                   floor((masterScreenSize.height - imageSize.height) * 0.5),
                                   imageSize.width,
                                   imageSize.height);
    
    // Make image name
    NSString *imageName = [self HITCUniqueImageNameWithName:self.imageName];
    
    // Get cache folder path
    NSString *cachePath = [HITCCommunicateWithHTTP cacheFolderPath];
    
    // Write image into cache folder
    NSString *imageFilename = imageName;
    NSString *imagePath = [cachePath stringByAppendingPathComponent:imageFilename];
    NSData *jpegData = UIImageJPEGRepresentation(image, 1.0);
    NSError *error = nil;
    if ([jpegData writeToFile:imagePath options:NSDataWritingAtomic error:&error] == NO) {
        DDLogError(@"%@", error);
    }

    // Add new item
    HITCItem *item = [[HITCItem alloc] initWithItemType:HITCItemTypeImage name:[imageFilename stringByDeletingPathExtension] tag:0];
    item.file = imageFilename;
    item.owner = [HITCLocalhost IPAddress];
    item.position = imageFrame.origin;
    item.size = imageFrame.size;
    item.focus = NO;
    item.date = [NSDate date];
    item.signature = [HITCLocalhost IPAddress];
    item.componentID = [[NSUUID UUID] UUIDString];
    item.contentSource = @"";
    item.displayState = HITCItemDisplayStateNormal;
    item.normalPosition = imageFrame.origin;
    item.normalSize = imageFrame.size;
    item.selected = NO;
    item.image = image;
    HITCItemList *sharedItemList = [HITCItemList sharedItemList];
    [sharedItemList addLaunchedItem:item];
    
    // Communicate with master
    HITCCommunicateWithTCP *sharedCommunicateWithTCP = [HITCCommunicateWithTCP sharedCommunicateWithTCP];
    [sharedCommunicateWithTCP createItem:item];
    
    // Clear image
    self.imageView.image = nil;
    self.imageName = nil;
    
    // Update UI
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

///
//-----------------------------------------------------------------------------------
- (void)HITCImagePanned:(UIPanGestureRecognizer *)gestureRecognizer
//-----------------------------------------------------------------------------------
{
    // Request delta Y
    CGPoint location = [gestureRecognizer locationInView:self.view];
    CGFloat deltaY = self.previousLocation.y - location.y;
    self.previousLocation = location;
    
    // Request new Y position
    CGRect imageViewFrame = self.imageView.frame;
    imageViewFrame.origin.y -= deltaY;
    
    // 下方向への移動は元位置を超えないようにする
    if (CGRectGetMinY(imageViewFrame) > self.imageViewOriginalY) {
        imageViewFrame.origin.y = self.imageViewOriginalY;
        self.imageView.frame = imageViewFrame;
    }
    
    // Update Y position
    self.imageView.frame = imageViewFrame;
    
    // ジェスチャー終了時の処理
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat currentY = CGRectGetMinY(self.imageView.frame);
        CGFloat borderY = self.imageViewOriginalY - CGRectGetHeight(self.imageView.frame) * 0.5;
        borderY += CGRectGetHeight(self.navigationController.navigationBar.frame);
        
        if (currentY > borderY) {
            // Revert imageView position
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = self.imageView.frame;
                frame.origin.y = self.imageViewOriginalY;
                self.imageView.frame = frame;
            }];
        }
        else {
            // Push imageView
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = self.imageView.frame;
                frame.origin.y = self.imageViewOriginalY - CGRectGetHeight(self.imageView.frame);
                self.imageView.frame = frame;
            } completion:^(BOOL finished) {
                // Transmit image
                [self HITCTransmitImage:self];
                
                // Revert imageView position
                CGRect frame = self.imageView.frame;
                frame.origin.y = self.imageViewOriginalY;
                self.imageView.frame = frame;
            }];
        }
    }
}

/// Show photo library
//-----------------------------------------------------------------------------------
- (void)HITCShowPhotoLibraryAnimated:(BOOL)animated
//-----------------------------------------------------------------------------------
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *viewController = [[UIImagePickerController alloc] init];
        viewController.delegate = self;
        [self presentViewController:viewController animated:animated completion:NULL];
    }
}

/// Make image name with URL
//-----------------------------------------------------------------------------------
- (NSString *)HITCImageNameWithURL:(NSURL *)url
//-----------------------------------------------------------------------------------
{
    NSString *querry = [url query];     // like id=E25E0D25-D1EE-4C94-B7FC-FAB46CE19C42&ext=JPG
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:querry];
    [scanner scanString:@"id=" intoString:NULL];
    NSString *idString = nil;
    [scanner scanUpToString:@"&ext=" intoString:&idString];
    NSString *extString = nil;
    [scanner scanString:@"&ext=" intoString:NULL];
    [scanner scanUpToString:@"" intoString:&extString];
    
    return [NSString stringWithFormat:@"%@.%@", idString, extString];
}

/// Returns unique image name
//-----------------------------------------------------------------------------------
- (NSString *)HITCUniqueImageNameWithName:(NSString *)name
//-----------------------------------------------------------------------------------
{
    return [NSString stringWithFormat:@"%@_%@.jpg", [HITCLocalhost IPAddress], [name stringByDeletingPathExtension]];
}

@end
