//
//  HITCApplicationCell.h
//  HITController
//
//  Created by Masakazu Suetomo on 2013/07/12.
//  Copyright (c) 2013 Kyoto University. All rights reserved.
//

#import <UIKit/UIKit.h>


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@interface HITCApplicationCell : UICollectionViewCell

/// Application title
@property (nonatomic, strong) UILabel *label;
/// Application icon
@property (nonatomic, strong) UIImageView *imageView;

@end
