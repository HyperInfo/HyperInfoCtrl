//
//  HITCItemListViewController.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/11/24.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCItemListViewController.h"
#import "HITCResizeRelocateViewController.h"
#import "HITCCommunicateWithTCP.h"
#import "HITCItemList.h"
#import "HITCItem.h"
#import "HITCLocalhost.h"
#import "HITCMaster.h"
#import "HITCUtility.h"
#import "QuickDialog.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCItemListViewController ()
{
    BOOL _preventsToReloadTable;    ///< YES if prevent to reload table
}
/// NavigationController for settings screen
@property (nonatomic, weak) UINavigationController *setteingsNavigationController;
@end


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCItemListViewController

//-----------------------------------------------------------------------------------
- (void)dealloc
//-----------------------------------------------------------------------------------
{
    // Remove observer for KVO
    HITCItemList *sharedItemList = [HITCItemList sharedItemList];
    [sharedItemList removeObserver:self forKeyPath:@"items"];
    
    [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
        [item removeObserver:self forKeyPath:@"image"];
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
    
    // Prepare left BarButtonItem
    UIImage *image = [UIImage imageNamed:@"gear.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(HITCShowSettings:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button sizeToFit];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    // Prepare right BarButtonItem
    [self HITCAdjustRightBarButtonItem];
    
    // Add observer for KVO
    HITCItemList *sharedItemList = [HITCItemList sharedItemList];
    [sharedItemList addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionPrior|NSKeyValueObservingOptionOld context:NULL];
    
    // Observe notification
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(HITCDidAddLaunchedItem:) name:HITCItemListDidAddLaunchedItemNotification object:nil];
}

//-----------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super viewWillDisappear:animated];
    
    // Exit edit mode
    self.editing = NO;
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
    if ([[segue identifier] isEqualToString:@"ShowResizeRelocate"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        HITCItemList *sharedItemList = [HITCItemList sharedItemList];
        HITCItem *item = sharedItemList.items[indexPath.row];
        
        ((HITCResizeRelocateViewController *)[segue destinationViewController]).item = item;
    }
}

//-----------------------------------------------------------------------------------
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
//-----------------------------------------------------------------------------------
{
    // Invoke super
    [super setEditing:editing animated:animated];
    
    // Prepare right BarButtonItem
    [self HITCAdjustRightBarButtonItem];
}


#pragma mark -
#pragma mark NSKeyValueObserving Informal Protocol

//-----------------------------------------------------------------------------------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//-----------------------------------------------------------------------------------
{
    if ([keyPath isEqualToString:@"items"]) {
        // 一旦、既存 item に対し removeObserver:forKeyPath: し、その後、全ての item を addObserver:forKeyPath:options:context: する。
        if ([change[NSKeyValueChangeNotificationIsPriorKey] boolValue] == YES) {
            // Remove observer for KVO
            NSArray *items = change[NSKeyValueChangeOldKey];
            [items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                [item removeObserver:self forKeyPath:@"image"];
            }];
        }
        else {
            // Add observer for KVO
            HITCItemList *sharedItemList = object;
            [sharedItemList.items enumerateObjectsUsingBlock:^(HITCItem *item, NSUInteger idx, BOOL *stop) {
                [item addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
            }];
            
            // Reload data
            if (_preventsToReloadTable == NO) {
                [self.tableView reloadData];
            }
        }
    }
    else if ([keyPath isEqualToString:@"image"]) {
        HITCItemList *sharedItemList = [HITCItemList sharedItemList];
        NSInteger index = [sharedItemList.items indexOfObject:object];
        
        // Reload rows
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
}


#pragma mark -
#pragma mark UITableViewDataSource

//-----------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-----------------------------------------------------------------------------------
{
    // Prepare right BarButtonItem
    [self HITCAdjustRightBarButtonItem];
    
    //
    HITCItemList *sharedItemList = [HITCItemList sharedItemList];
    
    return [sharedItemList.items count];
}

//-----------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-----------------------------------------------------------------------------------
{
    static NSString *CellIdentifier = @"HITCItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self HITCConfigureCell:cell atIndexPath:indexPath];
    
    return cell;
}

//-----------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//-----------------------------------------------------------------------------------
{
    return YES;
}

//-----------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//-----------------------------------------------------------------------------------
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //
        HITCItemList *sharedItemList = [HITCItemList sharedItemList];
        HITCItem *item = sharedItemList.items[indexPath.row];
        
        // Communicate with master
        HITCCommunicateWithTCP *sharedCommunicateWithTCP = [HITCCommunicateWithTCP sharedCommunicateWithTCP];
        [sharedCommunicateWithTCP deleteItem:item];
        
        // Remove item
        [self HITCBeginPreventToReloadTable];
        [sharedItemList removeItem:item];
        [self HITCEndPreventToReloadTable];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark -
#pragma mark UITableViewDelegate

//-----------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-----------------------------------------------------------------------------------
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


#pragma mark -
#pragma mark Private

/// Show settings screen
//-----------------------------------------------------------------------------------
- (void)HITCShowSettings:(id)sender
//-----------------------------------------------------------------------------------
{
    QRootElement *rootElement = [[QRootElement alloc] init];
    rootElement.grouped = YES;
    rootElement.title = @"Settings";
    
    QSection *section = [[QSection alloc] initWithTitle:@"IP Address"];
    QLabelElement *element = [[QLabelElement alloc] initWithTitle:@"Localhost" Value:[HITCLocalhost IPAddress]];
    [section addElement:element];
    element = [[QLabelElement alloc] initWithTitle:@"Master" Value:[HITCMaster IPAddress]];
    [section addElement:element];
    [rootElement addSection:section];
    
    section = [[QSection alloc] initWithTitle:@""];
    [section addElement:[self HITCCreateLicenseText]];
    section.footer = [NSString stringWithFormat:@"%@ %@\nCopyright © 2013 Kyoto University.\nAll rights reserved.",
                      [HITCUtility applicationDisplayName],
                      [HITCUtility applicationVersion]];
    [rootElement addSection:section];
    
    QuickDialogController *quickDialogController = [[QuickDialogController alloc] initWithRoot:rootElement];
    quickDialogController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                            target:self
                                                                                                            action:@selector(HITCHideSettings)];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:quickDialogController];
    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self presentViewController:navigationController animated:YES completion:NULL];
    
    self.setteingsNavigationController = navigationController;
    
    // Gesture for showing log
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HITCShowLogWithGestureRecognizer:)];
    tapGestureRecognizer.numberOfTapsRequired = 3;
    tapGestureRecognizer.numberOfTouchesRequired = 3;
    [navigationController.view addGestureRecognizer:tapGestureRecognizer];
}

/// Adjust right bar button item
//-----------------------------------------------------------------------------------
- (void)HITCAdjustRightBarButtonItem
//-----------------------------------------------------------------------------------
{
    HITCItemList *sharedItemList = [HITCItemList sharedItemList];
    NSInteger numberOfItems = [sharedItemList.items count];
    
    UIBarButtonItem *barButtonItem = nil;
    
    if (self.isEditing && numberOfItems > 0) {
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                      target:self
                                                                      action:@selector(HITCExitEditMode:)];
    }
    
    else {
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                      target:self
                                                                      action:@selector(HITCEnterEditMode:)];
    }
    
    self.navigationItem.rightBarButtonItem = barButtonItem;
    barButtonItem.enabled = (numberOfItems < 1) ? NO : YES;
}

/// Enter edit mode
//-----------------------------------------------------------------------------------
- (void)HITCEnterEditMode:(id)sender
//-----------------------------------------------------------------------------------
{
    [self setEditing:YES animated:YES];
}

/// Exit edit mode
//-----------------------------------------------------------------------------------
- (void)HITCExitEditMode:(id)sender
//-----------------------------------------------------------------------------------
{
    [self setEditing:NO animated:YES];
}

/// Show log screen
//-----------------------------------------------------------------------------------
- (void)HITCShowLogWithGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
//-----------------------------------------------------------------------------------
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        UIViewController *logViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Log"];
        [self.setteingsNavigationController pushViewController:logViewController animated:YES];
    }
}

/// Configure cell
//-----------------------------------------------------------------------------------
- (void)HITCConfigureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
//-----------------------------------------------------------------------------------
{
    HITCItemList *sharedItemList = [HITCItemList sharedItemList];
    HITCItem *item = sharedItemList.items[indexPath.row];
    
    cell.textLabel.text = item.name;
    cell.imageView.image = item.iconImage;
}

/// Begins to prevent to reload table
//-----------------------------------------------------------------------------------
- (void)HITCBeginPreventToReloadTable
//-----------------------------------------------------------------------------------
{
    _preventsToReloadTable = YES;
}

/// Ends to prevent to reload table
//-----------------------------------------------------------------------------------
- (void)HITCEndPreventToReloadTable
//-----------------------------------------------------------------------------------
{
    _preventsToReloadTable = NO;
}

/// Invoke if launched item was added
//-----------------------------------------------------------------------------------
- (void)HITCDidAddLaunchedItem:(NSNotification *)notification
//-----------------------------------------------------------------------------------
{
    // Determine target item
    HITCItem *item = [notification userInfo][HITCItemListLaunchedItemKey];
    
    // Pop to root view controller
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    // Show ResizeRelocate screen
    [self performSelector:@selector(HITCShowResizeRelocateScreenWithItem:) withObject:item afterDelay:0.0];
    
    // Switch tab to list screen
    UITabBarController *tabBarController = (UITabBarController *)self.navigationController.parentViewController;
    tabBarController.selectedIndex = 0;
}

/// Show ResizeRelocate screen
//-----------------------------------------------------------------------------------
- (void)HITCShowResizeRelocateScreenWithItem:(HITCItem *)item
//-----------------------------------------------------------------------------------
{
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ResizeRelocate"];
    ((HITCResizeRelocateViewController *)viewController).item = item;
    [self.navigationController pushViewController:viewController animated:YES];
}

/// Hide settings screen
//-----------------------------------------------------------------------------------
- (void)HITCHideSettings
//-----------------------------------------------------------------------------------
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/// Create license screen
//-----------------------------------------------------------------------------------
- (QRootElement *)HITCCreateLicenseText
//-----------------------------------------------------------------------------------
{
    QRootElement *rootElement = [[QRootElement alloc] init];
    rootElement.title = @"License";
    
    QAppearance *appearance = [QAppearance new];
    appearance.valueFont = [UIFont systemFontOfSize:10.0];
    rootElement.appearance = appearance;
    
    QTextElement *textElement1 = [[QTextElement alloc] initWithText:@"MSFCommonThings\n\n"
                                  @"Software License Agreement (BSD License)\n"
                                  @"\n"
                                  @"Copyright (c) 2012, moonxseed (http://www.moonxseed.com)\n"
                                  @"All rights reserved.\n"
                                  @"\n"
                                  @"Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n"
                                  
                                  @"    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n"
                                  @"    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n"
                                  @"\n"
                                  @"THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\n"];
    
    QTextElement *textElement2 = [[QTextElement alloc] initWithText:@"QuickDialog\n\n"
                                  @"Copyright 2011 ESCOZ Inc  - http://escoz.com\n"
                                  @"--------\n"
                                  @"\n"
                                  @"Licensed under the Apache License, Version 2.0 (the \"License\"); you may not use this\n"
                                  @"file except in compliance with the License. You may obtain a copy of the License at\n"
                                  @"\n"
                                  @"                             http://www.apache.org/licenses/LICENSE-2.0\n"
                                  @"\n"
                                  @"Unless required by applicable law or agreed to in writing, software distributed under\n"
                                  @"the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF\n"
                                  @"ANY KIND, either express or implied. See the License for the specific language governing\n"
                                  @"permissions and limitations under the License.\n"];
    
    QTextElement *textElement3 = [[QTextElement alloc] initWithText:@"AFNetworking\n\n"
                                  @"Copyright (c) 2011 Gowalla (http://gowalla.com/)\n"
                                  @"\n"
                                  @"Permission is hereby granted, free of charge, to any person obtaining a copy\n"
                                  @"of this software and associated documentation files (the \"Software\"), to deal\n"
                                  @"in the Software without restriction, including without limitation the rights\n"
                                  @"to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n"
                                  @"copies of the Software, and to permit persons to whom the Software is\n"
                                  @"furnished to do so, subject to the following conditions:\n"
                                  @"\n"
                                  @"The above copyright notice and this permission notice shall be included in\n"
                                  @"all copies or substantial portions of the Software.\n"
                                  @"\n"
                                  @"THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n"
                                  @"IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n"
                                  @"FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n"
                                  @"AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n"
                                  @"LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n"
                                  @"OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n"
                                  @"THE SOFTWARE.\n"];
    
    QTextElement *textElement4 = [[QTextElement alloc] initWithText:@"CocoaAsyncSocket\n\n"
                                  @"Public Domain.\n"];
    
    QTextElement *textElement5 = [[QTextElement alloc] initWithText:@"CocoaHTTPServer\n\n"
                                  @"Software License Agreement (BSD License)\n"
                                  @"\n"
                                  @"Copyright (c) 2011, Deusty, LLC\n"
                                  @"All rights reserved.\n"
                                  @"\n"
                                  @"Redistribution and use of this software in source and binary forms,\n"
                                  @"with or without modification, are permitted provided that the following conditions are met:\n"
                                  @"\n"
                                  @"* Redistributions of source code must retain the above\n"
                                  @"copyright notice, this list of conditions and the\n"
                                  @"following disclaimer.\n"
                                  @"\n"
                                  @"* Neither the name of Deusty nor the names of its\n"
                                  @"contributors may be used to endorse or promote products\n"
                                  @"derived from this software without specific prior\n"
                                  @"written permission of Deusty, LLC.\n"
                                  @"\n"
                                  @"THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\n"];
    
    QTextElement *textElement6 = [[QTextElement alloc] initWithText:@"CocoaLumberjack\n\n"
                                  @"Software License Agreement (BSD License)\n"
                                  @"\n"
                                  @"Copyright (c) 2010, Deusty, LLC\n"
                                  @"All rights reserved.\n"
                                  @"\n"
                                  @"Redistribution and use of this software in source and binary forms,\n"
                                  @"with or without modification, are permitted provided that the following conditions are met:\n"
                                  @"\n"
                                  @"* Redistributions of source code must retain the above\n"
                                  @"copyright notice, this list of conditions and the\n"
                                  @"following disclaimer.\n"
                                  @"\n"
                                  @"* Neither the name of Deusty nor the names of its\n"
                                  @"contributors may be used to endorse or promote products\n"
                                  @"derived from this software without specific prior\n"
                                  @"written permission of Deusty, LLC.\n"
                                  @"\n"
                                  @"THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\n"];
    
    QTextElement *textElement7 = [[QTextElement alloc] initWithText:@"KissXML\n\n"
                                  @"Copyright (c) 2012, Robbie Hanson\n"
                                  @"All rights reserved.\n"
                                  @"\n"
                                  @"Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n"
                                  @"\n"
                                  @"- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n"
                                  @"\n"
                                  @"THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\n"];
    
    QSection *section = [[QSection alloc] init];
    [section addElement:textElement1];
    [section addElement:textElement2];
    [section addElement:textElement3];
    [section addElement:textElement4];
    [section addElement:textElement5];
    [section addElement:textElement6];
    [section addElement:textElement7];
    [rootElement addSection:section];
    
    return rootElement;
}

@end
