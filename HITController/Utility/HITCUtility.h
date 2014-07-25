//
//  HITCUtility.h
//  HITController
//
//  Created by Masakazu Suetomo on 2012/11/25.
//  Copyright (c) 2012 Kyoto University. All rights reserved.
//

#import <Foundation/Foundation.h>


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCUtility : NSObject

///
+ (void)applyCustomAppearanceToButton:(UIButton *)button title:(NSString *)title;

/// Returns bundle name
+ (NSString *)bundleName;

/// Returns application display name
+ (NSString *)applicationDisplayName;

/// Returns application version string with revision
+ (NSString *)applicationVersionStringWithRevisionString;

/// Returns application version string
+ (NSString *)applicationVersionString;

/// Returns application version
+ (NSString *)applicationVersion;

/// Returns application revision
+ (NSString *)applicationRevision;

/// Returns system version
+ (NSString *)systemVersion;

/// Compare system version with specified version
+ (BOOL)isEqualToSystemVersion:(NSString *)targetVersion;

/// Compare system version with specified version
+ (BOOL)isEqualAndGreaterToSystemVersion:(NSString *)targetVersion;

/// Compare application version with specified version
+ (BOOL)isEqualToApplicationVersion:(NSString *)targetVersion;

/// Compare application version with specified version
+ (BOOL)isEqualAndGreaterToApplicationVersion:(NSString *)targetVersion;

@end
