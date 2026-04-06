//
//  NewsCell.h
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 19/03/2026.
//
#import <UIKit/UIKit.h>
#import "NewsItem.h"

@interface NewsCell : UICollectionViewCell

- (void)configureWithNewsItem:(NewsItem *)item;

@end
