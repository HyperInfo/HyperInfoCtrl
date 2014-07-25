//
//  HITCResizeRelocateViewController.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/12/07.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCResizeRelocateViewController.h"
#import "HITCContentViewController.h"
#import "HITCCommunicateWithTCP.h"
#import "HITCMaster.h"
#import "HITCItemList.h"
#import "HITCItem.h"
#import "HITCApplication.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCResizeRelocateViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGPoint previousLocation;
@property (nonatomic, assign) CGSize previousSize;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, weak) UIImageView *glowImageView0;
@property (nonatomic, weak) UIImageView *glowImageView1;
@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCResizeRelocateViewController

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
    
	// Add gesture recognizer
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(HITCPan:)];
    panGestureRecognizer.delegate = self;
    panGestureRecognizer.maximumNumberOfTouches = 2;
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(HITCPinch:)];
    pinchGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    // Adjust UI
    if (self.item.itemType == HITCItemTypeApplicaton) {
        HITCApplication *application = (HITCApplication *)self.item;
        if (application.applicationType != HITCApplicationTypeWidget) {
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    // Add Observer
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(HITCDidRemoveItemFromList:) name:HITCItemDidRemoveFromListNotification object:nil];
    
    // Add ImageView
    UIImage *image = [UIImage imageNamed:@"glow.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    self.glowImageView0 = imageView;
    self.glowImageView0.alpha = 0.0;
    imageView = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview:imageView];
    self.glowImageView1 = imageView;
    self.glowImageView1.alpha = 0.0;
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//-----------------------------------------------------------------------------------
{
    if ([[segue identifier] isEqualToString:@"ShowContent"]) {
        ((HITCContentViewController *)[segue destinationViewController]).item = self.item;
    }
}

//-----------------------------------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//-----------------------------------------------------------------------------------
{
}

//-----------------------------------------------------------------------------------
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//-----------------------------------------------------------------------------------
{
}

//-----------------------------------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//-----------------------------------------------------------------------------------
{
    // Hide glow
    [UIView animateWithDuration:0.3 animations:^{
        self.glowImageView0.alpha = 0.0;
        self.glowImageView1.alpha = 0.0;
    }];
}

//-----------------------------------------------------------------------------------
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//-----------------------------------------------------------------------------------
{
}


#pragma mark -
#pragma mark UIGestureRecognizerDelegate

//-----------------------------------------------------------------------------------
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//-----------------------------------------------------------------------------------
{
    if ([gestureRecognizer isMemberOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        self.previousLocation = [panGestureRecognizer translationInView:self.view];
    }
    
    return YES;
}

//-----------------------------------------------------------------------------------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//-----------------------------------------------------------------------------------
{
    self.previousSize = self.item.size;
    
    // Show glow
    if ([gestureRecognizer numberOfTouches] == 0 && self.glowImageView0.alpha == 0.0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.glowImageView0.alpha = 1.0;
        }];
        self.glowImageView0.center = [touch locationInView:self.view];
    }
    else if ([gestureRecognizer numberOfTouches] == 1 && self.glowImageView1.alpha == 0.0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.glowImageView1.alpha = 1.0;
        }];
        self.glowImageView1.center = [touch locationInView:self.view];
    }
    
    return YES;
}


#pragma mark -
#pragma mark Private

/// Pan gesture handler
//-----------------------------------------------------------------------------------
- (void)HITCPan:(UIPanGestureRecognizer *)panGestureRecognizer
//-----------------------------------------------------------------------------------
{
    BOOL deselected = NO;
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded || panGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        deselected = YES;
    }
    
    // Trackpad method
    const CGFloat translationRatio = 2.0;
    CGPoint currentLocation = [panGestureRecognizer translationInView:self.view];
    CGPoint itemPosition = self.item.position;
    itemPosition.x += (currentLocation.x - self.previousLocation.x) * translationRatio;
    itemPosition.y += (currentLocation.y - self.previousLocation.y) * translationRatio;
    self.previousLocation = currentLocation;
    
    // Stops at the edge of the screen, leaving a gap
    const CGFloat remainingGap = 64.0f;    // Remaining gap on the master screen
    const CGFloat leftmostX = -(self.item.size.width - remainingGap);
    const CGFloat rightmostX = [HITCMaster screenSize].width - remainingGap;
    const CGFloat topmostY = -(self.item.size.height - remainingGap);
    const CGFloat bottommostY = [HITCMaster screenSize].height - remainingGap;
    
    if (itemPosition.x < leftmostX) {
        itemPosition.x = leftmostX;
    }
    else if (itemPosition.x > rightmostX) {
        itemPosition.x = rightmostX;
    }
    
    if (itemPosition.y < topmostY) {
        itemPosition.y = topmostY;
    }
    else if (itemPosition.y > bottommostY) {
        itemPosition.y = bottommostY;
    }
    
    // Update position
    self.item.position = itemPosition;
    self.item.normalPosition = self.item.position;
    
    // Communicate with master
    HITCCommunicateWithTCP *sharedCommunicateWithTCP = [HITCCommunicateWithTCP sharedCommunicateWithTCP];
    [sharedCommunicateWithTCP riseTopmost:self.item];
    [sharedCommunicateWithTCP moveItem:self.item deselected:deselected];
    
    // Adjust glow
    if ([panGestureRecognizer numberOfTouches] < 2) {
        self.glowImageView1.alpha = 0.0;
    }
    
    if (self.glowImageView0.alpha != 0.0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.glowImageView0.alpha = deselected ? 0.0 : 1.0;
        }];
        if (deselected == NO) {
            self.glowImageView0.center = [panGestureRecognizer locationOfTouch:0 inView:self.view];
        }
    }
    if (self.glowImageView1.alpha != 0.0 && [panGestureRecognizer numberOfTouches] > 1) {
        [UIView animateWithDuration:0.3 animations:^{
            self.glowImageView1.alpha = deselected ? 0.0 : 1.0;
        }];
        if (deselected == NO) {
            self.glowImageView1.center = [panGestureRecognizer locationOfTouch:1 inView:self.view];
        }
    }
}

/// Pinch gesture handler
//-----------------------------------------------------------------------------------
- (void)HITCPinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer
//-----------------------------------------------------------------------------------
{
    BOOL deselected = NO;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded || pinchGestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        deselected = YES;
    }
    
    CGFloat scale = pinchGestureRecognizer.scale;
    
    // Update size
    const CGFloat remainingSize = 64.0f;    // Remaining size on the master screen
    CGSize candidateSize = CGSizeMake(self.previousSize.width * scale, self.previousSize.height * scale);
    if (candidateSize.width <= remainingSize || candidateSize.height <= remainingSize) {
        if (candidateSize.width < candidateSize.height) {
            CGFloat ratio = candidateSize.height / candidateSize.width;
            candidateSize.width = remainingSize;
            candidateSize.height = remainingSize * ratio;
        }
        else {
            CGFloat ratio = candidateSize.width / candidateSize.height;
            candidateSize.width = remainingSize * ratio;
            candidateSize.height = remainingSize;
        }
    }
    
    self.item.size = candidateSize;
    self.item.normalSize = self.item.size;
    
    // Communicate with master
    HITCCommunicateWithTCP *sharedCommunicateWithTCP = [HITCCommunicateWithTCP sharedCommunicateWithTCP];
    [sharedCommunicateWithTCP riseTopmost:self.item];
#warning TEMPORARY IMPLEMENTATION
#if 0
    [sharedCommunicateWithTCP resizeItem:self.item deselected:deselected];
#else   // Interim use
    [sharedCommunicateWithTCP moveItem:self.item deselected:deselected];
#endif
    
    // Adjust glow
    if ([pinchGestureRecognizer numberOfTouches] < 2) {
        self.glowImageView1.alpha = 0.0;
    }
    
    if (self.glowImageView0.alpha != 0.0) {
        [UIView animateWithDuration:0.3 animations:^{
            self.glowImageView0.alpha = deselected ? 0.0 : 1.0;
        }];
        self.glowImageView0.center = [pinchGestureRecognizer locationOfTouch:0 inView:self.view];
    }
    if (self.glowImageView1.alpha != 0.0 && [pinchGestureRecognizer numberOfTouches] > 1) {
        [UIView animateWithDuration:0.3 animations:^{
            self.glowImageView1.alpha = deselected ? 0.0 : 1.0;
        }];
        self.glowImageView1.center = [pinchGestureRecognizer locationOfTouch:1 inView:self.view];
    }
}

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
