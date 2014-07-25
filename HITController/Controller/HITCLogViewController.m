//
//  HITCLogViewController.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/24.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCLogViewController.h"
#import "HITCAppDelegate.h"
#import <MessageUI/MessageUI.h>


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCLogViewController () <MFMailComposeViewControllerDelegate>

@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCLogViewController

#pragma mark -
#pragma mark Override

//-----------------------------------------------------------------------------------
- (void)viewDidLoad
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super viewDidLoad];
    
    //
    self.textView.text = nil;
    
    //
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(HITCRollLogFile:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    // Gesture for sending mail
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HITCSendLogMailWithGestureRecognizer:)];
    tapGestureRecognizer.numberOfTapsRequired = 3;
    tapGestureRecognizer.numberOfTouchesRequired = 3;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

//-----------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super viewDidAppear:animated];
    
    //
    HITCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    DDLogFileInfo *logFileInfo = [appDelegate.fileLogger valueForKey:@"currentLogFileInfo"];
    NSString *text = [NSString stringWithContentsOfFile:logFileInfo.filePath encoding:NSUTF8StringEncoding error:NULL];
    self.textView.text = text;
    [self.textView scrollRangeToVisible:NSMakeRange([text length] - 1, 1)];
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
#pragma mark MFMailComposeViewControllerDelegate

//-----------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
//-----------------------------------------------------------------------------------
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark -
#pragma mark Private

/// Roll log file forcedly
//-----------------------------------------------------------------------------------
- (IBAction)HITCRollLogFile:(id)sender
//-----------------------------------------------------------------------------------
{
    // Roll log file
    HITCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.fileLogger rollLogFile];
    
    // Update TextView
    DDLogFileInfo *logFileInfo = [appDelegate.fileLogger valueForKey:@"currentLogFileInfo"];
    NSString *text = [NSString stringWithContentsOfFile:logFileInfo.filePath encoding:NSUTF8StringEncoding error:NULL];
    self.textView.text = text;
    [self.textView scrollRangeToVisible:NSMakeRange([text length] - 1, 1)];
}

/// Send log mail
//-----------------------------------------------------------------------------------
- (void)HITCSendLogMailWithGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
//-----------------------------------------------------------------------------------
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        if ([MFMailComposeViewController canSendMail]) {
            // Current date
            NSDate *now = [NSDate date];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
            NSDateComponents *dateComponents = [gregorian components:unitFlags fromDate:now];
            
            // Log text
            HITCAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            DDLogFileInfo *logFileInfo = [appDelegate.fileLogger valueForKey:@"currentLogFileInfo"];
            NSString *text = [NSString stringWithContentsOfFile:logFileInfo.filePath encoding:NSUTF8StringEncoding error:NULL];
            
            // Prepare mail
            MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
            NSString *subject = [NSString stringWithFormat:@"HITController Log at %@", [now descriptionWithLocale:[NSLocale currentLocale]]];
            [mailComposeViewController setSubject:subject];
            NSString *fileName = [NSString stringWithFormat:@"HITControllerLog%04d%02d%02d%02d%02d.txt",
                                  [dateComponents year],
                                  [dateComponents month],
                                  [dateComponents day],
                                  [dateComponents hour],
                                  [dateComponents minute]];
            [mailComposeViewController addAttachmentData:[text dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/plain" fileName:fileName];
            mailComposeViewController.mailComposeDelegate = self;
            [self.navigationController presentViewController:mailComposeViewController animated:YES completion:NULL];
        }
    }
}

@end
