//
//  HITCApplicationLayout.h
//  HITController
//
//  Created by Masakazu Suetomo on 2013/07/12.
//  Copyright (c) 2013 Kyoto University. All rights reserved.
//

#import <UIKit/UIKit.h>


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCApplicationLayout : UICollectionViewFlowLayout

/// Number of columns per page
@property (nonatomic, assign) NSInteger numberOfColumnsPerPage;
/// Number of rows per page
@property (nonatomic, assign) NSInteger numberOfRowsPerPage;

@end
