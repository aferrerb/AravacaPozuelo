//
//  Navdrawerviewcontroller.m
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 28/03/2026.
//

#import "NavDrawerViewController.h"
#import "AppData.h"
#import "GateKeeper.h"

static CGFloat const kDrawerWidthFraction = 0.25;
static NSString * const kCellID = @"NavDrawerCell";

@interface NavDrawerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView      *dimView;
@property (nonatomic, strong) UIView      *drawerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray     *navItems;
@property (nonatomic, assign) CGFloat     drawerWidth;
@property (nonatomic, assign) BOOL        isOpen;

@end

@implementation NavDrawerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.navItems = [AppData shared].nav ?: @[];

    [self setupDimView];
    [self setupDrawer];

    // Start off-screen to the left
    self.drawerView.transform = CGAffineTransformMakeTranslation(-self.drawerWidth, 0);
    self.dimView.alpha = 0;
}

#pragma mark - Setup

- (void)setupDimView {
    _dimView = [[UIView alloc] initWithFrame:self.view.bounds];
    _dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    _dimView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_dimView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(dimTapped)];
    [_dimView addGestureRecognizer:tap];
}

- (void)setupDrawer {
    _drawerWidth = self.view.bounds.size.width * kDrawerWidthFraction;

    _drawerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _drawerWidth, self.view.bounds.size.height)];
    _drawerView.backgroundColor = [UIColor colorWithRed:0x2D/255.0
                                                  green:0x5E/255.0
                                                   blue:0x61/255.0
                                                  alpha:1.0];
    _drawerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_drawerView];

    // Settings button pinned to bottom
    UIButton *settingsBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    settingsBtn.tintColor = [UIColor whiteColor];
    UIImage *gearIcon = [UIImage systemImageNamed:@"gearshape.fill"];
    [settingsBtn setImage:gearIcon forState:UIControlStateNormal];
    settingsBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    settingsBtn.translatesAutoresizingMaskIntoConstraints = NO;

    UILabel *settingsLabel = [[UILabel alloc] init];
    settingsLabel.text = @"Settings";
    settingsLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:10];
    settingsLabel.textColor = [UIColor whiteColor];
    settingsLabel.textAlignment = NSTextAlignmentCenter;
    settingsLabel.translatesAutoresizingMaskIntoConstraints = NO;

    UIStackView *settingsStack = [[UIStackView alloc] initWithArrangedSubviews:@[settingsBtn, settingsLabel]];
    settingsStack.axis = UILayoutConstraintAxisVertical;
    settingsStack.alignment = UIStackViewAlignmentCenter;
    settingsStack.spacing = 4;
    settingsStack.translatesAutoresizingMaskIntoConstraints = NO;
    [_drawerView addSubview:settingsStack];

    [NSLayoutConstraint activateConstraints:@[
        [settingsStack.centerXAnchor constraintEqualToAnchor:_drawerView.centerXAnchor],
        [settingsStack.bottomAnchor constraintEqualToAnchor:_drawerView.safeAreaLayoutGuide.bottomAnchor constant:-12],
        [settingsBtn.widthAnchor constraintEqualToConstant:28],
        [settingsBtn.heightAnchor constraintEqualToConstant:28],
    ]];

    // Table view for nav items
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate            = self;
    _tableView.dataSource          = self;
    _tableView.backgroundColor     = [UIColor clearColor];
    _tableView.separatorStyle      = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_drawerView addSubview:_tableView];

    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellID];

    [NSLayoutConstraint activateConstraints:@[
        [_tableView.topAnchor constraintEqualToAnchor:_drawerView.topAnchor],
        [_tableView.leadingAnchor constraintEqualToAnchor:_drawerView.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:_drawerView.trailingAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:settingsStack.topAnchor constant:-8],
    ]];
}

#pragma mark - Open / Close

- (void)openAnimated:(BOOL)animated {
    _isOpen = YES;
    self.view.hidden = NO;
    NSTimeInterval duration = animated ? 0.28 : 0;
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.drawerView.transform = CGAffineTransformIdentity;
        self.dimView.alpha = 1;
    } completion:nil];
}

- (void)closeAnimated:(BOOL)animated {
    _isOpen = NO;
    NSTimeInterval duration = animated ? 0.22 : 0;
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        self.drawerView.transform = CGAffineTransformMakeTranslation(-self.drawerWidth, 0);
        self.dimView.alpha = 0;
    } completion:^(BOOL finished) {
        self.view.hidden = YES;
    }];
}

- (void)dimTapped {
    [self closeAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    return self.navItems.count;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (UIView *)tableView:(UITableView *)tv viewForHeaderInSection:(NSInteger)section {
    // Safe area spacer at top
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _drawerWidth, 5)];
    header.backgroundColor = [UIColor clearColor];
    return header;
}

- (CGFloat)tableView:(UITableView *)tv heightForHeaderInSection:(NSInteger)section {
    return 5.0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];

    // Clear reused content
    for (UIView *v in cell.contentView.subviews) [v removeFromSuperview];

    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle  = UITableViewCellSelectionStyleNone;

    NSDictionary *item = self.navItems[indexPath.row];
    NSString *iconValue = item[@"icon_value"];
    NSString *iconStyle = item[@"icon_style"] ?: @"solid";
    NSString *title     = item[@"title"] ?: @"";

    // Icon label
    if (iconValue && iconValue != (id)[NSNull null] && iconValue.length > 0) {
        UILabel *iconLabel = [[UILabel alloc] init];
        NSString *fontName = [iconStyle isEqualToString:@"regular"]
            ? @"FontAwesome6Free-Regular"
            : @"FontAwesome6Free-Solid";
        iconLabel.font = [UIFont fontWithName:fontName size:28];
        iconLabel.textColor = [UIColor whiteColor];
        iconLabel.textAlignment = NSTextAlignmentCenter;
        iconLabel.translatesAutoresizingMaskIntoConstraints = NO;

        unsigned hexVal = 0;
        [[NSScanner scannerWithString:iconValue] scanHexInt:&hexVal];
        iconLabel.text = [NSString stringWithFormat:@"%C", (unichar)hexVal];

        [cell.contentView addSubview:iconLabel];
        [NSLayoutConstraint activateConstraints:@[
            [iconLabel.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:12],
            [iconLabel.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
        ]];
    }

    // Title label
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text          = title;
    titleLabel.font          = [UIFont fontWithName:@"Montserrat-Regular" size:10];
    titleLabel.textColor     = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 2;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor        = 0.7;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-8],
        [titleLabel.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:4],
        [titleLabel.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-4],
    ]];

    // Separator line at bottom
    UIView *sep = [[UIView alloc] init];
    sep.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    sep.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:sep];
    [NSLayoutConstraint activateConstraints:@[
        [sep.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor],
        [sep.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor],
        [sep.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor],
        [sep.heightAnchor constraintEqualToConstant:0.5],
    ]];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.navItems[indexPath.row];
    NSString *dtype    = item[@"destination_type"];
    BOOL isGated = [item[@"is_gated"] boolValue];
    NSString *hint = item[@"credentials_hint"];
    if (hint == (id)[NSNull null]) hint = nil;
    if (isGated) {
        [GateKeeper presentGateFrom:self credentialsHint:hint completion:^(BOOL granted) {
            if (granted) {
                [self closeAnimated:YES];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)),
                               dispatch_get_main_queue(), ^{
                    [self navigateItem:item dtype:dtype];
                });
            }
        }];
    } else {
        [self closeAnimated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [self navigateItem:item dtype:dtype];
        });
    }
}

- (void)navigateItem:(NSDictionary *)item dtype:(NSString *)dtype {
    if ([dtype isEqualToString:@"home"] || dtype == nil || [dtype isEqualToString:@""]) {
        [self.delegate drawerDidSelectHome];
    } else if ([dtype isEqualToString:@"url"]) {
        [self.delegate drawerDidSelectURL:item[@"destination_url"] ?: @""
                                    title:item[@"title"] ?: @""];
    } else if ([dtype isEqualToString:@"article"]) {
        NSInteger articleID = [item[@"destination_article_id"] integerValue];
        [self.delegate drawerDidSelectArticleID:articleID];
    } else if ([dtype isEqualToString:@"page"]) {
        NSInteger pageID = [item[@"destination_page_id"] integerValue];
        [self.delegate drawerDidSelectPageID:pageID];
    } else if ([dtype isEqualToString:@"pdf"]) {
        [self.delegate drawerDidSelectPDFURL:item[@"destination_url"] ?: @""
                                       title:item[@"title"] ?: @""];
    }
}

@end
