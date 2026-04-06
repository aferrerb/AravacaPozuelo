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
        [headerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:52],
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
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:titleLabel];
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor],
        [titleLabel.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-14],
        [titleLabel.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:52],
        [titleLabel.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-52],
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
        [_tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:52],
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
    return 56.0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *item = self.items[indexPath.row];
    [self navigateToItem:item];
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
                                                     webURL:item[@"destination_url"] ?: @""
                                                contentType:@"pdf"];
        [self openPDF:newsItem];
    }
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PDF

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
    [[NSURLSession sharedSession] downloadTaskWithURL:remoteURL
        completionHandler:^(NSURL *tmpURL, NSURLResponse *r, NSError *e) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            if (e || !tmpURL) return;
            NSURL *cachesDir = [[[NSFileManager defaultManager]
                                 URLsForDirectory:NSCachesDirectory
                                 inDomains:NSUserDomainMask] firstObject];
            NSURL *destURL = [cachesDir URLByAppendingPathComponent:[item.webURL lastPathComponent]];
            [[NSFileManager defaultManager] removeItemAtURL:destURL error:nil];
            [[NSFileManager defaultManager] moveItemAtURL:tmpURL toURL:destURL error:nil];
            self.localPDFURL = destURL;
            QLPreviewController *ql = [[QLPreviewController alloc] init];
            ql.dataSource = self;
            [self.navigationController pushViewController:ql animated:YES];
        });
    }];
}

#pragma mark - QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)c { return 1; }
- (id<QLPreviewItem>)previewController:(QLPreviewController *)c previewItemAtIndex:(NSInteger)i {
    return self.localPDFURL;
}

@end
