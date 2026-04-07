//
//  HomeViewController.m
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 19/03/2026.


#import "HomeViewController.h"
#import "NewsItem.h"
#import "NewsCell.h"
#import "NewsWebViewController.h"
#import "AppData.h"
#import <QuickLook/QuickLook.h>
#import <objc/runtime.h>
#import "PageViewController.h"
#import "ArticleViewController.h"
#import "NavDrawerViewController.h"
#import "GateKeeper.h"


static NSString * const kNewsCellID    = @"NewsCell";
static NSString * const kBannerCellID  = @"BannerCell";

@interface HomeViewController () <UICollectionViewDelegate,
                                  UICollectionViewDataSource,
                                  QLPreviewControllerDataSource,
                                  NavDrawerDelegate>

@property (nonatomic, strong) UIView                *headerView;
@property (nonatomic, strong) UIScrollView          *scrollView;
@property (nonatomic, strong) UIStackView           *stackView;

// News carousel
@property (nonatomic, strong) UICollectionView      *newsCollectionView;
@property (nonatomic, strong) NSArray<NewsItem *>   *newsItems;

// Banner carousel
@property (nonatomic, strong) UICollectionView      *bannerCollectionView;
@property (nonatomic, strong) NSArray               *bannerItems;
@property (nonatomic, assign) BOOL                  bannerAdjusting;
@property (nonatomic, strong) NSURL                 *localPDFURL;
@property (nonatomic, strong) NavDrawerViewController *drawer;

@end

@implementation HomeViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppBackground"]];
    bg.contentMode = UIViewContentModeScaleAspectFill;
    bg.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:bg atIndex:0];
    [NSLayoutConstraint activateConstraints:@[
        [bg.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [bg.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [bg.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [bg.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    ]];
    [self setupHeader];
    [self setupScrollView];
    [self buildRows];
    [self setupDrawer];
}
- (void)setupDrawer {
    _drawer = [[NavDrawerViewController alloc] init];
    _drawer.delegate = self;
    [self addChildViewController:_drawer];
    _drawer.view.frame = self.view.bounds;
    _drawer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _drawer.view.hidden = YES;
    [self.view addSubview:_drawer.view];
    [_drawer didMoveToParentViewController:self];
}

#pragma mark - Data

- (void)buildRows {
    NSArray *homeRows = [AppData shared].homeRows;

    for (NSDictionary *row in homeRows) {
        NSString *type = row[@"type"];

        if ([type isEqualToString:@"news_carousel"]) {
            [self addNewsCarousel:row[@"items"]];
        } else if ([type isEqualToString:@"carousel"]) {
            [self addBannerCarousel:row[@"items"]];
        } else if ([type isEqualToString:@"grid"]) {
            [self addGridRow:row];
        }
    }
}

#pragma mark - UI Setup

- (void)setupHeader {
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor whiteColor];
    _headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_headerView];

    [NSLayoutConstraint activateConstraints:@[
        [_headerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_headerView.heightAnchor constraintEqualToConstant:52],
    ]];

    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [menuBtn setTitle:@"≡" forState:UIControlStateNormal];
    menuBtn.titleLabel.font = [UIFont systemFontOfSize:38];
    [menuBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    menuBtn.frame = CGRectMake(12, 4, 44, 44);
    [menuBtn addTarget:self action:@selector(menuTapped)
      forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:menuBtn];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = @"AravacaPozuelo";
    titleLabel.font = [UIFont fontWithName:@"CabinSketch-Regular" size:28];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_headerView addSubview:titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.centerXAnchor constraintEqualToAnchor:_headerView.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:_headerView.centerYAnchor],
    ]];

    UIView *sep = [[UIView alloc] init];
    sep.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    sep.translatesAutoresizingMaskIntoConstraints = NO;
    [_headerView addSubview:sep];

    [NSLayoutConstraint activateConstraints:@[
        [sep.bottomAnchor constraintEqualToAnchor:_headerView.bottomAnchor],
        [sep.leadingAnchor constraintEqualToAnchor:_headerView.leadingAnchor],
        [sep.trailingAnchor constraintEqualToAnchor:_headerView.trailingAnchor],
        [sep.heightAnchor constraintEqualToConstant:0.5],
    ]];
}

- (void)setupScrollView {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:_scrollView];

    [NSLayoutConstraint activateConstraints:@[
        [_scrollView.topAnchor constraintEqualToAnchor:_headerView.bottomAnchor],
        [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    _stackView = [[UIStackView alloc] init];
    _stackView.axis = UILayoutConstraintAxisVertical;
    _stackView.spacing = 0;
    _stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_stackView];

    [NSLayoutConstraint activateConstraints:@[
        [_stackView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor],
        [_stackView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor],
        [_stackView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor],
        [_stackView.bottomAnchor constraintEqualToAnchor:_scrollView.bottomAnchor],
        [_stackView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor],
    ]];
}

#pragma mark - News Carousel

- (void)addNewsCarousel:(NSArray *)items {
    NSMutableArray<NewsItem *> *newsItems = [NSMutableArray array];
    for (NSDictionary *d in items) {
            NewsItem *item = [[NewsItem alloc] initWithTitle:d[@"title"] ?: @""
                                                   imageURL:d[@"image_url"] ?: @""
                                                     webURL:d[@"content"] ?: @""
                                                contentType:d[@"content_type"] ?: @"link"];
            item.rawData = d;
            [newsItems addObject:item];
        }
    self.newsItems = [newsItems copy];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    CGFloat sideInset  = 16.0;
    CGFloat spacing    = 12.0;
    CGFloat peekWidth  = 20.0;
    CGFloat cardWidth  = (self.view.bounds.size.width - sideInset * 2 - spacing - peekWidth) / 2;
    CGFloat cardHeight = cardWidth * 1.1;
    
    layout.itemSize                = CGSizeMake(cardWidth, cardHeight);
    layout.minimumLineSpacing      = spacing;
    layout.minimumInteritemSpacing = spacing;
    layout.sectionInset            = UIEdgeInsetsMake(0, sideInset, 0, sideInset);

    _newsCollectionView = [[UICollectionView alloc]
                            initWithFrame:CGRectZero
                      collectionViewLayout:layout];
    _newsCollectionView.tag = 100;
    _newsCollectionView.backgroundColor = [UIColor clearColor];
    _newsCollectionView.showsHorizontalScrollIndicator = NO;
    _newsCollectionView.clipsToBounds = NO;
    _newsCollectionView.delegate   = self;
    _newsCollectionView.dataSource = self;

    [_newsCollectionView registerClass:[NewsCell class]
            forCellWithReuseIdentifier:kNewsCellID];

    [_newsCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_newsCollectionView.heightAnchor constraintEqualToConstant:cardHeight + 16].active = YES;

    UIView *wrapper = [[UIView alloc] init];
    wrapper.clipsToBounds = NO;
    [wrapper addSubview:_newsCollectionView];
    _newsCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [_newsCollectionView.topAnchor constraintEqualToAnchor:wrapper.topAnchor constant:8],
        [_newsCollectionView.bottomAnchor constraintEqualToAnchor:wrapper.bottomAnchor constant:-8],
        [_newsCollectionView.leadingAnchor constraintEqualToAnchor:wrapper.leadingAnchor],
        [_newsCollectionView.trailingAnchor constraintEqualToAnchor:wrapper.trailingAnchor],
    ]];

    [_stackView addArrangedSubview:wrapper];
}

#pragma mark - Banner Carousel

- (void)addBannerCarousel:(NSArray *)items {
    self.bannerItems = items;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    CGFloat cardWidth  = self.view.bounds.size.width - 100.0;
    CGFloat cardHeight = cardWidth * 0.70;
    CGFloat sideInset  = 32.0;
    
    layout.itemSize           = CGSizeMake(cardWidth, cardHeight);
    layout.minimumLineSpacing = 12;
    layout.sectionInset       = UIEdgeInsetsMake(0, sideInset, 0, sideInset);
    
    _bannerCollectionView = [[UICollectionView alloc]
                             initWithFrame:CGRectZero
                             collectionViewLayout:layout];
    _bannerCollectionView.tag = 200;
    _bannerCollectionView.backgroundColor = [UIColor clearColor];
    _bannerCollectionView.showsHorizontalScrollIndicator = NO;
    _bannerCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    _bannerCollectionView.tag = 200;
    _bannerCollectionView.delegate   = self;
    _bannerCollectionView.dataSource = self;
    
    [_bannerCollectionView registerClass:[UICollectionViewCell class]
              forCellWithReuseIdentifier:kBannerCellID];
    
    _bannerCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_bannerCollectionView.heightAnchor constraintEqualToConstant:cardHeight + 24].active = YES;
    
    [_stackView addArrangedSubview:_bannerCollectionView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self centerBannerCarousel];
    });
}
- (void)centerBannerCarousel {
    if (!self.bannerItems.count) return;
    NSInteger middleIndex = self.bannerItems.count;
    [_bannerCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:middleIndex inSection:0]
                                 atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                         animated:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != _bannerCollectionView) return;
    if (_bannerAdjusting) return;

    CGFloat contentWidth = scrollView.contentSize.width;
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat oneSetWidth = contentWidth / 3.0;

    if (offsetX <= 0) {
        _bannerAdjusting = YES;
        scrollView.contentOffset = CGPointMake(offsetX + oneSetWidth, scrollView.contentOffset.y);
        _bannerAdjusting = NO;
    } else if (offsetX >= oneSetWidth * 2) {
        _bannerAdjusting = YES;
        scrollView.contentOffset = CGPointMake(offsetX - oneSetWidth, scrollView.contentOffset.y);
        _bannerAdjusting = NO;
    }
}

#pragma mark - Grid Row

- (void)addGridRow:(NSDictionary *)row {
    NSArray *items = row[@"items"];
    NSInteger cols = MAX(1, [row[@"columns_count"] integerValue]);
    if (!items.count) return;

    CGFloat cellSize = self.view.bounds.size.width / cols;

    UIView *gridView = [[UIView alloc] init];
    gridView.backgroundColor = [UIColor clearColor];
    gridView.translatesAutoresizingMaskIntoConstraints = NO;

    UIColor *neutralDivider = [UIColor colorWithWhite:0.84 alpha:0.22];

    UIView *topBorder = [[UIView alloc] init];
    topBorder.backgroundColor = neutralDivider;
    topBorder.translatesAutoresizingMaskIntoConstraints = NO;
    [gridView addSubview:topBorder];
    [NSLayoutConstraint activateConstraints:@[
        [topBorder.topAnchor constraintEqualToAnchor:gridView.topAnchor],
        [topBorder.leadingAnchor constraintEqualToAnchor:gridView.leadingAnchor],
        [topBorder.trailingAnchor constraintEqualToAnchor:gridView.trailingAnchor],
        [topBorder.heightAnchor constraintEqualToConstant:0.5],
    ]];

    NSInteger rowCount = (NSInteger)ceil((double)items.count / cols);
    CGFloat rowHeight = cellSize * 1.3;
    CGFloat totalHeight = rowHeight * rowCount;

    [gridView.heightAnchor constraintEqualToConstant:totalHeight].active = YES;

    for (NSInteger i = 0; i < (NSInteger)items.count; i++) {
        NSDictionary *item = items[i];
        NSInteger col = i % cols;
        NSInteger rowIdx = i / cols;

        UIButton *cell = [UIButton buttonWithType:UIButtonTypeSystem];
        cell.translatesAutoresizingMaskIntoConstraints = NO;
        cell.tag = 1000 + i;
        cell.backgroundColor = [UIColor clearColor];
        objc_setAssociatedObject(cell, "itemData", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [cell addTarget:self action:@selector(gridItemTapped:) forControlEvents:UIControlEventTouchUpInside];
        [gridView addSubview:cell];

        [NSLayoutConstraint activateConstraints:@[
            [cell.leadingAnchor constraintEqualToAnchor:gridView.leadingAnchor constant:col * cellSize],
            [cell.topAnchor constraintEqualToAnchor:gridView.topAnchor constant:rowIdx * rowHeight],
            [cell.widthAnchor constraintEqualToConstant:cellSize],
            [cell.heightAnchor constraintEqualToConstant:rowHeight],
        ]];

        NSString *colorHex = item[@"color"] ?: @"#374151";
        UIColor *baseColor = [self colorFromHex:colorHex];
        UIColor *iconColor = [self iconColorFromBaseColor:baseColor];
        UIColor *titleColor = [self titleColorFromBaseColor:baseColor];
        UIColor *tintedDivider = [self dividerColorFromBaseColor:baseColor];
        
        // Right border (except last in row)
        if (col < cols - 1) {
            UIView *rightBorder = [[UIView alloc] init];
            rightBorder.backgroundColor = tintedDivider;
            rightBorder.translatesAutoresizingMaskIntoConstraints = NO;
            [gridView addSubview:rightBorder];
            [NSLayoutConstraint activateConstraints:@[
                [rightBorder.topAnchor constraintEqualToAnchor:cell.topAnchor constant:10],
                [rightBorder.bottomAnchor constraintEqualToAnchor:cell.bottomAnchor constant:-10],
                [rightBorder.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor],
                [rightBorder.widthAnchor constraintEqualToConstant:0.8],
            ]];
        }
        
        // Bottom border
        UIView *bottomBorder = [[UIView alloc] init];
        bottomBorder.backgroundColor = neutralDivider;
        bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
        [gridView addSubview:bottomBorder];
        [NSLayoutConstraint activateConstraints:@[
            [bottomBorder.bottomAnchor constraintEqualToAnchor:cell.bottomAnchor],
            [bottomBorder.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor],
            [bottomBorder.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor],
            [bottomBorder.heightAnchor constraintEqualToConstant:0.5],
        ]];

        NSString *iconName = item[@"icon_name"];
        BOOL hasPngIcon = iconName && iconName != (id)[NSNull null] && iconName.length > 0;

        if (hasPngIcon) {
            UIImageView *iconView = [[UIImageView alloc] init];
            UIImage *img = [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            iconView.image = img;
            iconView.tintColor = iconColor;
            iconView.contentMode = UIViewContentModeScaleAspectFit;
            iconView.translatesAutoresizingMaskIntoConstraints = NO;
            CGFloat iconSize = cellSize * 0.38;
            [cell addSubview:iconView];
            [NSLayoutConstraint activateConstraints:@[
                [iconView.centerXAnchor constraintEqualToAnchor:cell.centerXAnchor],
                [iconView.topAnchor constraintEqualToAnchor:cell.topAnchor constant:26],
                [iconView.widthAnchor constraintEqualToConstant:iconSize],
                [iconView.heightAnchor constraintEqualToConstant:iconSize],
            ]];

            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.text = item[@"title"];
            CGFloat labelSize = cellSize * 0.13;
            titleLabel.font = [UIFont fontWithName:@"Karla-SemiBold" size:labelSize];
            titleLabel.adjustsFontSizeToFitWidth = NO;
            titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            titleLabel.numberOfLines = 2;
            titleLabel.textColor = titleColor;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [cell addSubview:titleLabel];
            [NSLayoutConstraint activateConstraints:@[
                [titleLabel.topAnchor constraintEqualToAnchor:iconView.bottomAnchor constant:12],
                [titleLabel.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:6],
                [titleLabel.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor constant:-6],
                [titleLabel.bottomAnchor constraintLessThanOrEqualToAnchor:cell.bottomAnchor constant:-20],
            ]];

        } else if (item[@"icon_value"] && item[@"icon_value"] != (id)[NSNull null]) {
            UILabel *iconLabel = [[UILabel alloc] init];
            CGFloat iconSize = cellSize * 0.30;
            NSString *iconStyle = item[@"icon_style"] ?: @"regular";
            NSString *fontName = [iconStyle isEqualToString:@"regular"] ? @"FontAwesome6Free-Regular" : @"FontAwesome6Free-Solid";
            iconLabel.font = [UIFont fontWithName:fontName size:iconSize];
            iconLabel.textColor = iconColor;
            iconLabel.textAlignment = NSTextAlignmentCenter;
            iconLabel.translatesAutoresizingMaskIntoConstraints = NO;

            NSString *hex = item[@"icon_value"];
            unsigned hexVal = 0;
            [[NSScanner scannerWithString:hex] scanHexInt:&hexVal];
            iconLabel.text = [NSString stringWithFormat:@"%C", (unichar)hexVal];

            [cell addSubview:iconLabel];
            [NSLayoutConstraint activateConstraints:@[
                [iconLabel.centerXAnchor constraintEqualToAnchor:cell.centerXAnchor],
                [iconLabel.topAnchor constraintEqualToAnchor:cell.topAnchor constant:26],
            ]];

            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.text = item[@"title"];
            CGFloat labelSize = cellSize * 0.102;
            titleLabel.font = [UIFont fontWithName:@"Karla-Regular" size:labelSize];
            titleLabel.adjustsFontSizeToFitWidth = NO;
            titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            titleLabel.numberOfLines = 2;
            titleLabel.textColor = titleColor;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [cell addSubview:titleLabel];
            [NSLayoutConstraint activateConstraints:@[
                [titleLabel.topAnchor constraintEqualToAnchor:iconLabel.bottomAnchor constant:12],
                [titleLabel.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:6],
                [titleLabel.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor constant:-6],
                [titleLabel.bottomAnchor constraintLessThanOrEqualToAnchor:cell.bottomAnchor constant:-20],
            ]];
        }
    }

    [_stackView addArrangedSubview:gridView];
}

#pragma mark - Grid Tap

- (void)gridItemTapped:(UIButton *)sender {
    NSDictionary *item = objc_getAssociatedObject(sender, "itemData");
    BOOL isGated = [item[@"is_gated"] boolValue];
    NSString *hint = item[@"credentials_hint"];
    if (hint == (id)[NSNull null]) hint = nil;

    if (isGated) {
        [GateKeeper presentGateFrom:self credentialsHint:hint completion:^(BOOL granted) {
            if (granted) {
                [self navigateToItem:item];
            }
        }];
    } else {
        [self navigateToItem:item];
    }
}

#pragma mark - Navigation

- (void)navigateToItem:(NSDictionary *)item {
    NSString *dtype = item[@"destination_type"];

    if ([dtype isEqualToString:@"url"]) {
        NewsWebViewController *webVC = [[NewsWebViewController alloc] init];
        webVC.urlString = item[@"destination_url"];
        webVC.newsTitle = item[@"title"];
        [self.navigationController pushViewController:webVC animated:YES];

    } else if ([dtype isEqualToString:@"article"]) {
        id articleVal = item[@"destination_article_id"];
        if (!articleVal || articleVal == (id)[NSNull null]) return;
        NSDictionary *article = [[AppData shared] articleWithID:[articleVal integerValue]];
        if (!article) return;
        ArticleViewController *articleVC = [[ArticleViewController alloc] init];
        articleVC.article = article;
        [self.navigationController pushViewController:articleVC animated:YES];

    }  else if ([dtype isEqualToString:@"section"]) {
        id sectionVal = item[@"destination_section_id"];
        PageViewController *pageVC = [[PageViewController alloc] init];
        pageVC.pageTitle = item[@"title"] ?: @"";
        pageVC.pageID = (sectionVal && sectionVal != (id)[NSNull null]) ? [sectionVal integerValue] : 0;
        [self.navigationController pushViewController:pageVC animated:YES];

    } else if ([dtype isEqualToString:@"pdf"]) {
        NewsItem *newsItem = [[NewsItem alloc] initWithTitle:item[@"title"] ?: @""
                                                   imageURL:@""
                                                     webURL:item[@"destination_url"] ?: @""
                                                contentType:@"pdf"];
        [self openPDF:newsItem];
    }
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)cv numberOfItemsInSection:(NSInteger)section {
    if (cv.tag == 100) return self.newsItems.count;
    if (cv.tag == 200) return self.bannerItems.count * 3;
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (cv.tag == 100) {
        NewsCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kNewsCellID
                                                       forIndexPath:indexPath];
        [cell configureWithNewsItem:self.newsItems[indexPath.item]];
        return cell;
    }

    // Banner cell
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kBannerCellID
                                                               forIndexPath:indexPath];
    NSDictionary *item = self.bannerItems[indexPath.item % self.bannerItems.count];
    
    // Clear reused content
    for (UIView *v in cell.contentView.subviews) [v removeFromSuperview];

    cell.contentView.layer.cornerRadius  = 14;
    cell.contentView.layer.masksToBounds = YES;

    NSString *colorHex = item[@"color"] ?: @"#cccccc";
    cell.contentView.backgroundColor = [self colorFromHex:colorHex];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = item[@"title"];
    titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:24];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 2;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = item[@"subtitle"];
    subtitleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:15];
    subtitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.85];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.numberOfLines = 2;
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:subtitleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor constant:-12],
        [titleLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
        [titleLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],

        [subtitleLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:6],
        [subtitleLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
        [subtitleLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
    ]];

    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)cv didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (cv.tag == 100) {
        NewsItem *item = self.newsItems[indexPath.item];
        if ([item isPDF]) {
            [self openPDF:item];
        } else if ([item.contentType isEqualToString:@"article"]) {
                    ArticleViewController *articleVC = [[ArticleViewController alloc] init];
                    NSDictionary *d = item.rawData ?: @{};
                    NSString *body  = [d[@"article_body"]  isKindOfClass:[NSString class]] ? d[@"article_body"]  : @"";
                    NSString *image = [d[@"article_image"] isKindOfClass:[NSString class]] ? d[@"article_image"] : @"";
                    articleVC.article = @{ @"title": item.title, @"body": body, @"image": image };
                    [self.navigationController pushViewController:articleVC animated:YES];
                } else {
            NewsWebViewController *webVC = [[NewsWebViewController alloc] init];
            webVC.urlString = item.webURL;
            webVC.newsTitle = item.title;
            [self.navigationController pushViewController:webVC animated:YES];
        }
        return;
    }

    if (cv.tag == 200) {
        NSDictionary *item = self.bannerItems[indexPath.item % self.bannerItems.count];
        BOOL isGated = [item[@"is_gated"] boolValue];

        if (isGated) {
            NSString *hint = item[@"credentials_hint"];
            if (hint == (id)[NSNull null]) hint = nil;
            [GateKeeper presentGateFrom:self credentialsHint:hint completion:^(BOOL granted) {                if (granted) {
                    [self navigateToItem:item];
                }
            }];
        } else {
            [self navigateToItem:item];
        }
    }
}

#pragma mark - PDF Handling

- (void)openPDF:(NewsItem *)item {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    spinner.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:spinner];
    [NSLayoutConstraint activateConstraints:@[
        [spinner.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [spinner.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];
    [spinner startAnimating];

    NSURL *remoteURL = [NSURL URLWithString:item.webURL];
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession]
        downloadTaskWithURL:remoteURL
          completionHandler:^(NSURL *tmpURL, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            if (error || !tmpURL) {
                UIAlertController *alert = [UIAlertController
                    alertControllerWithTitle:@"Error"
                    message:@"No se pudo cargar el PDF."
                    preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                    style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
            NSString *filename = [item.webURL lastPathComponent];
            NSURL *cachesDir   = [[[NSFileManager defaultManager]
                                   URLsForDirectory:NSCachesDirectory
                                   inDomains:NSUserDomainMask] firstObject];
            NSURL *destURL     = [cachesDir URLByAppendingPathComponent:filename];
            [[NSFileManager defaultManager] removeItemAtURL:destURL error:nil];
            [[NSFileManager defaultManager] moveItemAtURL:tmpURL toURL:destURL error:nil];
            self.localPDFURL = destURL;
            QLPreviewController *ql = [[QLPreviewController alloc] init];
            ql.dataSource = self;
            [self.navigationController pushViewController:ql animated:YES];
        });
    }];
    [task resume];
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return self.localPDFURL ? 1 : 0;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller
                    previewItemAtIndex:(NSInteger)index {
    return self.localPDFURL;
}

#pragma mark - Helpers

- (UIColor *)colorFromHex:(NSString *)hex {
    hex = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
    unsigned int rgb = 0;
    [[NSScanner scannerWithString:hex] scanHexInt:&rgb];
    return [UIColor colorWithRed:((rgb >> 16) & 0xFF) / 255.0
                           green:((rgb >> 8)  & 0xFF) / 255.0
                            blue:( rgb        & 0xFF) / 255.0
                           alpha:1.0];
}

#pragma mark - Menu

- (void)menuTapped {
    [_drawer openAnimated:YES];
}

#pragma mark - NavDrawerDelegate

- (void)drawerDidSelectHome {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)drawerDidSelectURL:(NSString *)urlString title:(NSString *)title {
    NewsWebViewController *webVC = [[NewsWebViewController alloc] init];
    webVC.urlString = urlString;
    webVC.newsTitle = title;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)drawerDidSelectArticleID:(NSInteger)articleID {
    NSDictionary *article = [[AppData shared] articleWithID:articleID];
    if (!article) return;
    ArticleViewController *articleVC = [[ArticleViewController alloc] init];
    articleVC.article = article;
    [self.navigationController pushViewController:articleVC animated:YES];
}

- (void)drawerDidSelectPageID:(NSInteger)pageID {
    PageViewController *pageVC = [[PageViewController alloc] init];
    pageVC.pageID = pageID;
    [self.navigationController pushViewController:pageVC animated:YES];
}

- (void)drawerDidSelectPDFURL:(NSString *)urlString title:(NSString *)title {
    NewsItem *newsItem = [[NewsItem alloc] initWithTitle:title
                                               imageURL:@""
                                                 webURL:urlString
                                            contentType:@"pdf"];
    [self openPDF:newsItem];
}

- (UIColor *)blendedColorFromColor:(UIColor *)color withWhiteAmount:(CGFloat)whiteAmount alpha:(CGFloat)alpha {
    CGFloat r, g, b, a;
    if (![color getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithWhite:0.85 alpha:alpha];
    }

    r = r + (1.0 - r) * whiteAmount;
    g = g + (1.0 - g) * whiteAmount;
    b = b + (1.0 - b) * whiteAmount;

    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

- (UIColor *)dividerColorFromBaseColor:(UIColor *)color {
    return [self blendedColorFromColor:color withWhiteAmount:0.35 alpha:0.55];
}

- (UIColor *)iconColorFromBaseColor:(UIColor *)color {
    return [self blendedColorFromColor:color withWhiteAmount:0.06 alpha:0.95];
}

- (UIColor *)titleColorFromBaseColor:(UIColor *)color {
    return [self blendedColorFromColor:color withWhiteAmount:0.05 alpha:1.0];
}

@end
