//
//  HITCApplicationCollectionViewController.m
//  HITController
//
//  Created by Masakazu Suetomo on 2013/07/12.
//  Copyright (c) 2013 Kyoto University. All rights reserved.
//

#import "HITCApplicationCollectionViewController.h"
#import "HITCApplicationCell.h"
#import "HITCApplicationLayout.h"
#import "HITCApplicationList.h"
#import "HITCApplication.h"
#import "HITCItemList.h"
#import "HITCLocalhost.h"
#import "HITCMaster.h"
#import "HITCCommunicateWithTCP.h"

#define NUMBER_OF_COLUMNS_PER_PAGE  3
#define NUMBER_OF_ROWS_PER_PAGE     4

static NSString *CellIdentifier = @"HITCApplicationCell";


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCApplicationCollectionViewController ()

@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCApplicationCollectionViewController

//-----------------------------------------------------------------------------------
- (void)dealloc
//-----------------------------------------------------------------------------------
{
    // Remove observer for KVO
    HITCApplicationList *sharedApplicationList = [HITCApplicationList sharedApplicationList];
    [sharedApplicationList removeObserver:self forKeyPath:@"applications"];
    
    [sharedApplicationList.applications enumerateObjectsUsingBlock:^(HITCApplication *application, NSUInteger idx, BOOL *stop) {
        [application removeObserver:self forKeyPath:@"image"];
    }];
}


#pragma mark -
#pragma mark Override

//-----------------------------------------------------------------------------------
- (void)viewDidLoad
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super viewDidLoad];
    
    // Register a prototype cell class for the collection view
    [self.collectionView registerClass:[HITCApplicationCell class] forCellWithReuseIdentifier:CellIdentifier];
}

//-----------------------------------------------------------------------------------
- (void)viewDidLayoutSubviews
//-----------------------------------------------------------------------------------
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    BOOL isPortrait = YES;
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        isPortrait = NO;
    }
    
    [self HITCPrepareCollectionViewLayoutForPortrait:isPortrait];
}

//-----------------------------------------------------------------------------------
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//-----------------------------------------------------------------------------------
{
    BOOL isPortrait = YES;
    if (fromInterfaceOrientation == UIDeviceOrientationPortrait ||
        fromInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        isPortrait = NO;
    }
    
    [self HITCPrepareCollectionViewLayoutForPortrait:isPortrait];
}

//-----------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
//-----------------------------------------------------------------------------------
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-----------------------------------------------------------------------------------
- (void)awakeFromNib
//-----------------------------------------------------------------------------------
{
    // Add observer for KVO
    HITCApplicationList *sharedApplicationList = [HITCApplicationList sharedApplicationList];
    [sharedApplicationList addObserver:self forKeyPath:@"applications" options:NSKeyValueObservingOptionPrior|NSKeyValueObservingOptionOld context:NULL];
}


#pragma mark -
#pragma mark NSKeyValueObserving Informal Protocol

//-----------------------------------------------------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//-----------------------------------------------------------------------------------
{
    if ([keyPath isEqualToString:@"applications"]) {
        // 一旦、既存 application に対し removeObserver:forKeyPath: し、その後、全ての application を addObserver:forKeyPath:options:context: する。
        if ([change[NSKeyValueChangeNotificationIsPriorKey] boolValue] == YES) {
            // Remove observer for KVO
            NSArray *applications = change[NSKeyValueChangeOldKey];
            [applications enumerateObjectsUsingBlock:^(HITCApplication *application, NSUInteger idx, BOOL *stop) {
                [application removeObserver:self forKeyPath:@"image"];
            }];
        }
        else {
            // Add observer for KVO
            HITCApplicationList *sharedApplicationList = object;
            [sharedApplicationList.applications enumerateObjectsUsingBlock:^(HITCApplication *application, NSUInteger idx, BOOL *stop) {
                [application addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
            }];
            
            // Reload data
            [self.collectionView reloadData];
        }
    }
    else if ([keyPath isEqualToString:@"image"]) {
        HITCApplicationList *sharedApplicationList = [HITCApplicationList sharedApplicationList];
        NSInteger index = [sharedApplicationList.applications indexOfObject:object];
        
        // Reload cells
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    }
}


#pragma mark -
#pragma mark UICollectionViewDataSource

//-----------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//-----------------------------------------------------------------------------------
{
    HITCApplicationList *sharedApplicationList = [HITCApplicationList sharedApplicationList];
    
    return [sharedApplicationList.applications count];
}

//-----------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//-----------------------------------------------------------------------------------
{
    // Dequeue a prototype cell and set the label to indicate the page
    HITCApplicationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                                                          forIndexPath:indexPath];
    
    // Configure the cell...
    [self HITCConfigureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark -
#pragma mark UICollectionViewDelegate

//-----------------------------------------------------------------------------------
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//-----------------------------------------------------------------------------------
{
    // Deselect cell
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    
    // Get application
    HITCApplicationList *sharedApplicationList = [HITCApplicationList sharedApplicationList];
    HITCApplication *application = sharedApplicationList.applications[indexPath.row];
    
    // Add application item
    HITCApplication *launchedApplication = nil;
    if (application.applicationType == HITCApplicationTypeWidget) {
        launchedApplication = [[HITCApplication alloc] initWithWidgetName:application.name tag:0];
    }
    else if (application.applicationType == HITCApplicationTypePlugin) {
        launchedApplication = [[HITCApplication alloc] initWithPluginName:application.name tag:0];
    }
    launchedApplication.file = nil;
    launchedApplication.owner = [HITCLocalhost IPAddress];
    launchedApplication.position = CGPointZero;
    launchedApplication.size = CGSizeZero;
    launchedApplication.focus = NO;
    launchedApplication.date = [NSDate date];
    launchedApplication.signature = [HITCLocalhost IPAddress];
    launchedApplication.componentID = [[NSUUID UUID] UUIDString];
    launchedApplication.contentSource = @"";
    launchedApplication.displayState = HITCItemDisplayStateNormal;
    launchedApplication.normalPosition = CGPointZero;
    launchedApplication.normalSize = CGSizeZero;
    launchedApplication.selected = NO;
    launchedApplication.image = application.image;
    if (application.applicationType == HITCApplicationTypePlugin) {
        CGSize masterScreenSize = [HITCMaster screenSize];
        CGSize pluginSize = CGSizeMake(320.0, 240.0);
        launchedApplication.position = CGPointMake(floor((masterScreenSize.width - pluginSize.width) * 0.5),
                                                   floor((masterScreenSize.height - pluginSize.height) * 0.5));
        launchedApplication.size = pluginSize;
        launchedApplication.normalPosition = launchedApplication.position;
        launchedApplication.normalSize = launchedApplication.size;
    }
    HITCItemList *sharedItemList = [HITCItemList sharedItemList];
    [sharedItemList addLaunchedItem:launchedApplication];
    
    // Communicate with master
    HITCCommunicateWithTCP *sharedCommunicateWithTCP = [HITCCommunicateWithTCP sharedCommunicateWithTCP];
    [sharedCommunicateWithTCP createItem:launchedApplication];
}


#pragma mark -
#pragma mark Private

/// Configure cell
//-----------------------------------------------------------------------------------
- (void)HITCConfigureCell:(HITCApplicationCell *)cell atIndexPath:(NSIndexPath *)indexPath
//-----------------------------------------------------------------------------------
{
    HITCApplicationList *sharedApplicationList = [HITCApplicationList sharedApplicationList];
    HITCApplication *application = sharedApplicationList.applications[indexPath.row];
    
    cell.label.text = application.name;
    cell.imageView.image = application.iconImage;
    
#if 0
    CGFloat hue = (CGFloat)indexPath.row / [self collectionView:self.collectionView numberOfItemsInSection:0];
    cell.contentView.backgroundColor = [UIColor colorWithHue:hue saturation:1.0f brightness:0.5f alpha:1.0f];
#endif
}

/// Preapre collection view's layout
//-----------------------------------------------------------------------------------
- (void)HITCPrepareCollectionViewLayoutForPortrait:(BOOL)isPortrait
//-----------------------------------------------------------------------------------
{
    NSInteger columns = isPortrait == YES ? NUMBER_OF_COLUMNS_PER_PAGE : NUMBER_OF_ROWS_PER_PAGE;
    NSInteger rows = isPortrait == YES ? NUMBER_OF_ROWS_PER_PAGE : NUMBER_OF_COLUMNS_PER_PAGE;
    HITCApplicationLayout *flowLayout = (HITCApplicationLayout *)self.collectionView.collectionViewLayout;
    if (flowLayout.numberOfColumnsPerPage != columns || flowLayout.numberOfRowsPerPage != rows) {
        flowLayout.itemSize = CGSizeMake(CGRectGetWidth(self.view.frame) / columns, CGRectGetHeight(self.view.frame) / rows);
        flowLayout.numberOfColumnsPerPage = columns;
        flowLayout.numberOfRowsPerPage = rows;
        [self.collectionView.collectionViewLayout invalidateLayout];
    }

}

@end
