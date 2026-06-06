//
//  PageViewDontroller.m
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 26/03/2026.

#import "PageViewController.h"
#import "AppData.h"
#import "NewsWebViewController.h"
#import <QuickLook/QuickLook.h>
#import <objc/runtime.h>
#import "NewsItem.h"
#import "ArticleViewController.h"
#import "GateKeeper.h"
#import "CredentialsHintViewController.h"
#import "CelebracionesViewController.h"

@import BranchSDK;

@interface PageViewController () <UITableViewDelegate, UITableViewDataSource, QLPreviewControllerDataSource>
@property (nonatomic, strong) NSDictionary *page;
@property (nonatomic, strong) NSArray      *items;
@property (nonatomic, strong) UITableView  *tableView;
@property (nonatomic, strong) NSURL        *localPDFURL;

@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
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
    self.page = [[AppData shared] pageWithID:self.pageID];
    if (!self.page) {
        self.page = @{ @"title": self.pageTitle ?: @"" };
    }
    self.items = self.page[@"items"] ?: @[];

    [self setupHeader];
    [self setupTableView];
    if (self.items.count == 0) {
        UILabel *emptyLabel = [[UILabel alloc] init];
        emptyLabel.text = @"No hay nada que enseñar aquí";
        emptyLabel.font = [UIFont fontWithName:@"Karla-Regular" size:16];
        emptyLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        emptyLabel.numberOfLines = 0;
        emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:emptyLabel];
        [NSLayoutConstraint activateConstraints:@[
            [emptyLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
            [emptyLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
            [emptyLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:32],
            [emptyLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-32],
        ]];
    }
    
    [self trackViewEvent];
}

- (void)setupHeader {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:headerView];

    [NSLayoutConstraint activateConstraints:@[
        [headerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [headerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:68],
    ]];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [backBtn setTitle:@"‹" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:38];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:backBtn];
    [NSLayoutConstraint activateConstraints:@[
        [backBtn.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:8],
        [backBtn.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-10],
        [backBtn.widthAnchor constraintEqualToConstant:44],
        [backBtn.heightAnchor constraintEqualToConstant:44],
    ]];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = self.page[@"title"] ?: @"";
    titleLabel.font = [UIFont fontWithName:@"CabinSketch-Regular" size:28];
    titleLabel.numberOfLines = 2;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:titleLabel];
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor],
        [titleLabel.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-14],
        [titleLabel.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:52],
        [titleLabel.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-52],
    ]];
    
    UIColor *teal = [UIColor colorWithRed:0x2D/255.0
                                    green:0x5E/255.0
                                     blue:0x61/255.0
                                    alpha:1.0];

    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *shareIcon = [UIImage systemImageNamed:@"square.and.arrow.up"];
    [shareBtn setImage:shareIcon forState:UIControlStateNormal];
    shareBtn.tintColor = teal;
    shareBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [shareBtn addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:shareBtn];
    [NSLayoutConstraint activateConstraints:@[
        [shareBtn.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-12],
        [shareBtn.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-14],
        [shareBtn.widthAnchor constraintEqualToConstant:36],
        [shareBtn.heightAnchor constraintEqualToConstant:36],
    ]];

    UIView *sep = [[UIView alloc] init];
    sep.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    sep.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:sep];
    [NSLayoutConstraint activateConstraints:@[
        [sep.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor],
        [sep.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor],
        [sep.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor],
        [sep.heightAnchor constraintEqualToConstant:0.5],
    ]];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] init];
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];

    [NSLayoutConstraint activateConstraints:@[
        [_tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:68],
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PageItemCell"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"PageItemCell" forIndexPath:indexPath];
    NSDictionary *item = self.items[indexPath.row];

    cell.textLabel.text = item[@"title"];
    cell.textLabel.font = [UIFont fontWithName:@"Karla-Regular" size:24];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.textColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    cell.accessoryType = UITableViewCellAccessoryNone;
    UIImageView *chevron = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    chevron.tintColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    cell.accessoryView = chevron;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tv estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72.0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *item = self.items[indexPath.row];
    BOOL isGated = [item[@"is_gated"] boolValue];
    NSString *hint = item[@"credentials_hint"];
    if (hint == (id)[NSNull null]) hint = nil;

    if (isGated && ![GateKeeper isUnlocked]) {
        [GateKeeper presentGateFrom:self credentialsHint:hint completion:^(BOOL granted) {
            if (granted) {
                [self showHintIfNeeded:hint thenNavigate:item];
            }
        }];
    } else {
        [self showHintIfNeeded:hint thenNavigate:item];
    }
}

- (void)showHintIfNeeded:(NSString *)hint thenNavigate:(NSDictionary *)item {
    if (hint && hint.length > 0) {
        CredentialsHintViewController *hintVC = [[CredentialsHintViewController alloc] init];
        hintVC.hint = hint;
        hintVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        hintVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        hintVC.onContinue = ^{
            [self navigateToItem:item];
        };
        [self presentViewController:hintVC animated:YES completion:nil];
    } else {
        [self navigateToItem:item];
    }
}

#pragma mark - Navigation

- (void)navigateToItem:(NSDictionary *)item {
    NSString *dtype = item[@"destination_type"];
    NSString *urlString = [item[@"destination_url"] isKindOfClass:[NSString class]] ? item[@"destination_url"] : @"";
    
    if ([urlString containsString:@"fiestas"]) {
        CelebracionesViewController *vc = [[CelebracionesViewController alloc] init];
        vc.pageTitle = item[@"title"] ?: @"Celebraciones";
        [self.navigationController pushViewController:vc animated:YES];

    } else if ([dtype isEqualToString:@"url"]) {
        NewsWebViewController *webVC = [[NewsWebViewController alloc] init];
        webVC.urlString = urlString;
        webVC.newsTitle = item[@"title"];
        webVC.credentialsHint = item[@"credentials_hint"] == (id)[NSNull null] ? nil : item[@"credentials_hint"];
        [self.navigationController pushViewController:webVC animated:YES];

    } else if ([dtype isEqualToString:@"article"]) {
        NSInteger articleID = [item[@"destination_article_id"] integerValue];
        NSDictionary *article = [[AppData shared] articleWithID:articleID];
        if (!article) return;
        ArticleViewController *articleVC = [[ArticleViewController alloc] init];
        articleVC.article = article;
        [self.navigationController pushViewController:articleVC animated:YES];

    } else if ([dtype isEqualToString:@"page"]) {
        PageViewController *pageVC = [[PageViewController alloc] init];
        pageVC.pageID = [item[@"destination_page_id"] integerValue];
        [self.navigationController pushViewController:pageVC animated:YES];

    } else if ([dtype isEqualToString:@"pdf"]) {
        NewsItem *newsItem = [[NewsItem alloc] initWithTitle:item[@"title"] ?: @""
                                                   imageURL:@""
                                                     webURL:urlString
                                                contentType:@"pdf"];
        [self openPDF:newsItem];
    }
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Share

- (void)shareTapped {
    NSString *title = self.page[@"title"] ?: @"";
    NSInteger pageID = self.pageID;

    BranchUniversalObject *buo = [[BranchUniversalObject alloc]
        initWithCanonicalIdentifier:[NSString stringWithFormat:@"page/%ld", (long)pageID]];
    buo.title = title;
    buo.contentDescription = title;

    BranchLinkProperties *lp = [[BranchLinkProperties alloc] init];
    lp.feature = @"sharing";
    [lp addControlParam:@"destination_type" withValue:@"page"];
    [lp addControlParam:@"page_id" withValue:[NSString stringWithFormat:@"%ld", (long)pageID]];
    [lp addControlParam:@"title" withValue:title];

    [buo getShortUrlWithLinkProperties:lp andCallback:^(NSString *url, NSError *error) {
        if (error || !url) {
            NSLog(@"❌ Branch link error: %@", error);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActivityViewController *actVC = [[UIActivityViewController alloc]
                initWithActivityItems:@[url]
                applicationActivities:nil];
            [self presentViewController:actVC animated:YES completion:nil];
        });
    }];
}

#pragma mark - Branch Events

- (void)trackViewEvent {
    NSString *title = self.page[@"title"] ?: @"";
    
    BranchUniversalObject *buo = [[BranchUniversalObject alloc]
        initWithCanonicalIdentifier:[NSString stringWithFormat:@"page/%ld", (long)self.pageID]];
    buo.title = title;

    BranchEvent *event = [BranchEvent standardEvent:BranchStandardEventViewItems
                                 withContentItem:buo];
    event.alias = [NSString stringWithFormat:@"%@", title];
    [event logEvent];
}

#pragma mark - PDF

- (void)openPDF:(NewsItem *)item {
    NSLog(@"🔵 openPDF called with URL: %@", item.webURL);

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
    [[[NSURLSession sharedSession] downloadTaskWithURL:remoteURL
        completionHandler:^(NSURL *tmpURL, NSURLResponse *response, NSError *error) {
        // Move IMMEDIATELY on background thread before iOS deletes the tmp file
        NSURL *cachesDir = [[[NSFileManager defaultManager]
                             URLsForDirectory:NSCachesDirectory
                             inDomains:NSUserDomainMask] firstObject];
        NSString *filename = [item.title stringByAppendingPathExtension:@"pdf"];
        NSURL *destURL = [cachesDir URLByAppendingPathComponent:filename];

        BOOL fileReady = NO;
        if (!error && tmpURL) {
            [[NSFileManager defaultManager] removeItemAtURL:destURL error:nil];
            NSError *moveError = nil;
            fileReady = [[NSFileManager defaultManager] moveItemAtURL:tmpURL
                                                                toURL:destURL
                                                                error:&moveError];
            if (!fileReady) NSLog(@"🔴 Move failed: %@", moveError);
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            if (!fileReady) {
                UIAlertController *alert = [UIAlertController
                    alertControllerWithTitle:@"Error"
                    message:@"No se pudo cargar el PDF."
                    preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                    style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
            self.localPDFURL = destURL;
            QLPreviewController *ql = [[QLPreviewController alloc] init];
            ql.dataSource = self;
            [self.navigationController pushViewController:ql animated:YES];
        });
    }] resume];
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)c { return 1; }
- (id<QLPreviewItem>)previewController:(QLPreviewController *)c previewItemAtIndex:(NSInteger)i {
    return self.localPDFURL;
}

@end
