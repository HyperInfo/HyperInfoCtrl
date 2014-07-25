//
//  HITCUtility.m
//  HITController
//
//  Created by Masakazu Suetomo on 2012/11/25.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import "HITCUtility.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCUtility

//-----------------------------------------------------------------------------------
+ (void)applyCustomAppearanceToButton:(UIButton *)button title:(NSString *)title
//-----------------------------------------------------------------------------------
{
    // Set the button Title
    [button setTitle:title forState:UIControlStateNormal];
    
    // Set the button Text Color
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
    // Set the button Background Color
    [button setBackgroundColor:[UIColor blackColor]];
    
    // Draw a custom gradient
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = button.bounds;
    gradient.colors = @[
    (id)[UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f].CGColor,
    (id)[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f].CGColor
    ];
    [button.layer insertSublayer:gradient atIndex:0];
    
    // Round button corners
    CALayer *buttonLayer = [button layer];
    [buttonLayer setMasksToBounds:YES];
    [buttonLayer setCornerRadius:5.0f];
    
    // Apply a 1 pixel, black border around by button
    [buttonLayer setBorderWidth:1.0f];
    [buttonLayer setBorderColor:[[UIColor blackColor] CGColor]];
    
    //
    button.alpha = 0.6;
}


#pragma mark -
#pragma mark System and Application Information

//-----------------------------------------------------------------------------------
+ (NSString *)bundleName
//-----------------------------------------------------------------------------------
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *infoDictionary = [bundle infoDictionary];
    
    return [infoDictionary objectForKey:(NSString *)kCFBundleNameKey];
}

//-----------------------------------------------------------------------------------
+ (NSString *)applicationDisplayName
//-----------------------------------------------------------------------------------
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *infoDictionary = [bundle infoDictionary];
    
    return [infoDictionary objectForKey:@"CFBundleDisplayName"];
    
}

//-----------------------------------------------------------------------------------
+ (NSString *)applicationVersionStringWithRevisionString
//-----------------------------------------------------------------------------------
{
    NSString *applicationVersion = [HITCUtility applicationVersion];
    NSString *applicationRevision = [HITCUtility applicationRevision];
    
    NSString *versionString = nil;
    if (applicationRevision) {
        versionString = [NSString stringWithFormat:@"Version %@ (%@)", applicationVersion, applicationRevision];
    }
    else {
#ifdef DEBUG
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"Revision" ofType:@"plist"];
        NSDictionary *revisionInfo = [NSDictionary dictionaryWithContentsOfFile:path];
        NSString *builtDate = [revisionInfo objectForKey:@"Date"];
        versionString = [NSString stringWithFormat:@"Version %@ (%@ built)", applicationVersion, builtDate];
#else
        versionString = [NSString stringWithFormat:@"Version %@", applicationVersion];
#endif
    }
    
    return versionString;
}

//-----------------------------------------------------------------------------------
+ (NSString *)applicationVersionString
//-----------------------------------------------------------------------------------
{
    NSString *applicationVersion = [HITCUtility applicationVersion];
    NSString *versionString = [NSString stringWithFormat:@"Version %@", applicationVersion];
    
    return versionString;
}

//-----------------------------------------------------------------------------------
+ (NSString *)applicationVersion
//-----------------------------------------------------------------------------------
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *bundleInfo = [bundle infoDictionary];
    NSString *applicationVersion = [bundleInfo objectForKey:@"CFBundleVersion"];
    
    return applicationVersion;
}

//-----------------------------------------------------------------------------------
+ (NSString *)applicationRevision
//-----------------------------------------------------------------------------------
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"Revision" ofType:@"plist"];
    NSDictionary *revisionInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *applicationRevision = [revisionInfo objectForKey:@"Revision"];
    
    return applicationRevision;
}

//-----------------------------------------------------------------------------------
+ (NSString *)systemVersion
//-----------------------------------------------------------------------------------
{
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    
    return systemVersion;
}

//-----------------------------------------------------------------------------------
+ (BOOL)isEqualToSystemVersion:(NSString *)targetVersion
//-----------------------------------------------------------------------------------
{
    NSString *systemVersion = [self systemVersion];
    
    BOOL equal = [systemVersion compare:targetVersion options:NSNumericSearch] == NSOrderedSame;
    
    return equal;
}

//-----------------------------------------------------------------------------------
+ (BOOL)isEqualAndGreaterToSystemVersion:(NSString *)targetVersion
//-----------------------------------------------------------------------------------
{
    NSString *systemVersion = [self systemVersion];
    
    BOOL equalAndGreater = [systemVersion compare:targetVersion options:NSNumericSearch] != NSOrderedDescending;
    
    return equalAndGreater;
}

//-----------------------------------------------------------------------------------
+ (BOOL)isEqualToApplicationVersion:(NSString *)targetVersion
//-----------------------------------------------------------------------------------
{
    NSString *applicationVersion = [self applicationVersion];
    
    BOOL equal = [applicationVersion compare:targetVersion options:NSNumericSearch] == NSOrderedSame;
    
    return equal;
}

//-----------------------------------------------------------------------------------
+ (BOOL)isEqualAndGreaterToApplicationVersion:(NSString *)targetVersion
//-----------------------------------------------------------------------------------
{
    NSString *applicationVersion = [self applicationVersion];
    
    BOOL equalAndGreater = [applicationVersion compare:targetVersion options:NSNumericSearch] != NSOrderedDescending;
    
    return equalAndGreater;
}

@end
