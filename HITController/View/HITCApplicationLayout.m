//
//  HITCApplicationLayout.m
//  HITController
//
//  Created by Masakazu Suetomo on 2013/07/12.
//  Copyright (c) 2013 Kyoto University. All rights reserved.
//

#import "HITCApplicationLayout.h"


//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
@implementation HITCApplicationLayout


#pragma mark -
#pragma mark Override

//-----------------------------------------------------------------------------------
- (CGSize)collectionViewContentSize
//-----------------------------------------------------------------------------------
{
    CGSize contentSize = [super collectionViewContentSize];
    
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    NSInteger pages = (numberOfItems - 1) / (self.numberOfColumnsPerPage * self.numberOfRowsPerPage) + 1;
    contentSize = CGSizeMake(CGRectGetWidth(self.collectionView.frame) * pages, contentSize.height);
    
    return contentSize;
}

//-----------------------------------------------------------------------------------
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
//-----------------------------------------------------------------------------------
{
    NSMutableArray *attributesArray = [NSMutableArray array];
    
    if (self.numberOfColumnsPerPage != 0 && self.numberOfRowsPerPage != 0) {
        NSInteger index = 0;
        CGSize contentSize = [self collectionViewContentSize];
        CGFloat pageWidth = self.itemSize.width * self.numberOfColumnsPerPage;
        for (int page=0; page<contentSize.width/pageWidth; page++) {
            for (CGFloat y=0.0; y<contentSize.height; y+=self.itemSize.height) {
                for (CGFloat x=page*pageWidth; x<(page+1)*pageWidth; x+=self.itemSize.width) {
                    CGRect itemRect = CGRectMake(x, y, self.itemSize.width, self.itemSize.height);
                    if (index < [self.collectionView numberOfItemsInSection:0] && (CGRectIntersectsRect(itemRect, rect) || CGRectContainsRect(itemRect, rect))) {
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                        attributes.frame = itemRect;
                        [attributesArray addObject:attributes];
                    }
                    ++index;
                }
            }
        }
    }
    
    return attributesArray;
}

@end
