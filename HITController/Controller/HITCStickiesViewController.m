//
//  HITCStickiesViewController.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/11/24.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCStickiesViewController.h"
#import "HITCCommunicateWithTCP.h"
#import "HITCCommunicateWithHTTP.h"
#import "HITCItemList.h"
#import "HITCItem.h"
#import "HITCMaster.h"
#import "HITCLocalhost.h"
#import "DDLog.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCStickiesViewController ()
@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, assign) BOOL showsKeyboardWithAnimation;
@property (nonatomic, assign) CGFloat initialTextViewHeight;
@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCStickiesViewController

#pragma mark -
#pragma mark Override

//-----------------------------------------------------------------------------------
- (void)viewDidLoad
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super viewDidLoad];
    
    // Prepare right BarbuttonItem
    UIImage *image = [UIImage imageNamed:@"transmit.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(HITCTransmitText:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button sizeToFit];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // Clear text
    self.textView.text = @"";
    
    // Update UI
    self.closeBarButtonItem.enabled = YES;
    
    // Observe notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(HITCWillShowKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(HITCDidShowKeyboard:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(HITCWillHideKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //
    self.showsKeyboardWithAnimation = NO;
}

//-----------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super viewWillAppear:animated];
    
    // Show keyboard
    [self.textView becomeFirstResponder];
}

//-----------------------------------------------------------------------------------
- (void)viewDidLayoutSubviews
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super viewDidLayoutSubviews];
    
    // Adjusts subviews layout
    if ([self.textView isFirstResponder]) {
        self.initialTextViewHeight = CGRectGetHeight(self.textView.frame);
        
        //
        CGFloat adjustedHeight = -CGRectGetHeight(self.keyboardFrame) + CGRectGetHeight(self.tabBarController.tabBar.frame);
        MSFCGRectAddHeight(self.textView.frame, adjustedHeight);
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
- (IBAction)hideKeyboard:(id)sender
//-----------------------------------------------------------------------------------
{
    // Update UI
    self.closeBarButtonItem.enabled = NO;
    
    //
    self.showsKeyboardWithAnimation = YES;
    [self.textView resignFirstResponder];
}


#pragma mark -
#pragma mark UITextViewDelegate

//-----------------------------------------------------------------------------------
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
//-----------------------------------------------------------------------------------
{
    // Update UI
    self.closeBarButtonItem.enabled = YES;
    
    return YES;
}

//-----------------------------------------------------------------------------------
- (void)textViewDidEndEditing:(UITextView *)textView
//-----------------------------------------------------------------------------------
{
    [self.textView resignFirstResponder];
}

//-----------------------------------------------------------------------------------
- (void)textViewDidChange:(UITextView *)textView
//-----------------------------------------------------------------------------------
{
    // Update UI
    self.navigationItem.rightBarButtonItem.enabled = [textView.text length] ? YES : NO;
}


#pragma mark -
#pragma mark Private

/// Transmit text
//-----------------------------------------------------------------------------------
- (void)HITCTransmitText:(id)sender
//-----------------------------------------------------------------------------------
{
    // Adjust text position and size
    CGSize textSize = CGSizeMake(300.0, 250.0);
    CGSize masterScreenSize = [HITCMaster screenSize];
    CGRect textFrame = CGRectMake(floor((masterScreenSize.width - textSize.width) * 0.5),
                                  floor((masterScreenSize.height - textSize.height) * 0.5),
                                  textSize.width,
                                  textSize.height);
    
    // Make text name
    NSString *textName = [self HITCUniqueTextName];
    
    // Get cache folder path
    NSString *cachePath = [HITCCommunicateWithHTTP cacheFolderPath];
    
    // Write text into cache folder
    NSString *textFilename = textName;
    NSString *textPath = [cachePath stringByAppendingPathComponent:textFilename];
    NSError *error = nil;
#if 0   // for old version
    if ([self.textView.text writeToFile:textPath atomically:YES encoding:NSShiftJISStringEncoding error:&error] == NO) {
        DDLogError(@"%@", error);
    }
#else
    if ([self.textView.text writeToFile:textPath atomically:YES encoding:NSUTF8StringEncoding error:&error] == NO) {
        DDLogError(@"%@", error);
    }
#endif
    
    // Add item
    HITCItem *item = [[HITCItem alloc] initWithItemType:HITCItemTypeText name:[textFilename stringByDeletingPathExtension] tag:0];
    item.file = textFilename;
    item.owner = [HITCLocalhost IPAddress];
    item.position = textFrame.origin;
    item.size = textFrame.size;
    item.focus = NO;
    item.date = [NSDate date];
    item.signature = [HITCLocalhost IPAddress];
    item.componentID = [[NSUUID UUID] UUIDString];
    item.contentSource = @"";
    item.displayState = HITCItemDisplayStateNormal;
    item.normalPosition = textFrame.origin;
    item.normalSize = textFrame.size;
    item.selected = NO;
    item.image = nil;
    HITCItemList *sharedItemList = [HITCItemList sharedItemList];
    [sharedItemList addLaunchedItem:item];
    
    // Communicate with master
    HITCCommunicateWithTCP *sharedCommunicateWithTCP = [HITCCommunicateWithTCP sharedCommunicateWithTCP];
    [sharedCommunicateWithTCP createItem:item];
    
    // Clear text
    self.textView.text = @"";
    
    // Update UI
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

/// Adjust TextView when the keyboard appears
//-----------------------------------------------------------------------------------
- (void)HITCWillShowKeyboard:(NSNotification *)notification
//-----------------------------------------------------------------------------------
{
    [UIView setAnimationsEnabled:self.showsKeyboardWithAnimation == NO ? NO : YES];
    
    NSDictionary *userInfo = [notification userInfo];
    self.keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    //
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:animationCurve];
    CGFloat adjustedHeight = -CGRectGetHeight(self.keyboardFrame) + CGRectGetHeight(self.tabBarController.tabBar.frame);
    MSFCGRectAssignHeight(self.textView.frame, self.initialTextViewHeight + adjustedHeight);
    [UIView commitAnimations];
}

///
//-----------------------------------------------------------------------------------
- (void)HITCDidShowKeyboard:(NSNotification *)notification
//-----------------------------------------------------------------------------------
{
    [UIView setAnimationsEnabled:YES];
}

/// Adjust TextView when the keyboard hides
//-----------------------------------------------------------------------------------
- (void)HITCWillHideKeyboard:(NSNotification *)notification
//-----------------------------------------------------------------------------------
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    //
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:animationCurve];
    MSFCGRectAssignHeight(self.textView.frame, self.initialTextViewHeight);
    [UIView commitAnimations];
}

/// Returns unique text name
//-----------------------------------------------------------------------------------
- (NSString *)HITCUniqueTextName
//-----------------------------------------------------------------------------------
{
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:now];
    
    return [NSString stringWithFormat:@"%@_%@.txt", [HITCLocalhost IPAddress], dateString];
}

@end
