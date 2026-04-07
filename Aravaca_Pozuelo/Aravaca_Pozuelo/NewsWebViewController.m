//
//  NewsWebViewController.m
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 19/03/2026.
//
#import "NewsWebViewController.h"
#import <WebKit/WebKit.h>
#import "CredentialsHintViewController.h"

@interface NewsWebViewController ()
@property (nonatomic, strong) UIView    *headerView;
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation NewsWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupHeader];
    [self setupWebView];
    [self loadNews];
    if (self.credentialsHint && self.credentialsHint.length > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            [self showCredentialsHint];
        });
    }
}

- (void)showCredentialsHint {
    CredentialsHintViewController *hintVC = [[CredentialsHintViewController alloc] init];
    hintVC.hint = self.credentialsHint;
    hintVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    hintVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    hintVC.onContinue = nil; // just dismiss, already on the page
    [self presentViewController:hintVC animated:YES completion:nil];
}

// ── Header ────────────────────────────────────────────────────────────────────
- (void)setupHeader {
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor whiteColor];
    _headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_headerView];

    [NSLayoutConstraint activateConstraints:@[
        [_headerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_headerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:52],
    ]];

    UIButton *homeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    homeBtn.tag = 103;
    [homeBtn setTitle:@"‹" forState:UIControlStateNormal];
    homeBtn.titleLabel.font = [UIFont systemFontOfSize:38];
    [homeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    homeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [homeBtn addTarget:self action:@selector(closeToHome)
                      forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:homeBtn];
    [NSLayoutConstraint activateConstraints:@[
        [homeBtn.leadingAnchor constraintEqualToAnchor:_headerView.leadingAnchor constant:8],
        [homeBtn.bottomAnchor constraintEqualToAnchor:_headerView.bottomAnchor constant:-10],
        [homeBtn.widthAnchor constraintEqualToConstant:44],
        [homeBtn.heightAnchor constraintEqualToConstant:44],
    ]];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = self.newsTitle;
    titleLabel.font = [UIFont fontWithName:@"CabinSketch-Regular" size:24];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_headerView addSubview:titleLabel];
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.centerXAnchor constraintEqualToAnchor:_headerView.centerXAnchor],
        [titleLabel.bottomAnchor constraintEqualToAnchor:_headerView.bottomAnchor constant:-14],
        [titleLabel.leadingAnchor constraintEqualToAnchor:_headerView.leadingAnchor constant:52],
        [titleLabel.trailingAnchor constraintEqualToAnchor:_headerView.trailingAnchor constant:-52],
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
    if (self.credentialsHint && self.credentialsHint.length > 0) {
        UIButton *hintBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        UIImage *hintIcon = [UIImage systemImageNamed:@"key.fill"];
        [hintBtn setImage:hintIcon forState:UIControlStateNormal];
        hintBtn.tintColor = [UIColor colorWithRed:0x2D/255.0
                                                green:0x5E/255.0
                                                 blue:0x61/255.0
                                                alpha:1.0];
        hintBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [hintBtn addTarget:self action:@selector(showCredentialsHint)
            forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:hintBtn];

        [NSLayoutConstraint activateConstraints:@[
            [hintBtn.trailingAnchor constraintEqualToAnchor:_headerView.trailingAnchor constant:-16],
            [hintBtn.bottomAnchor constraintEqualToAnchor:_headerView.bottomAnchor constant:-10],
            [hintBtn.widthAnchor constraintEqualToConstant:36],
            [hintBtn.heightAnchor constraintEqualToConstant:36],
        ]];
    }
}

// ── Web View ──────────────────────────────────────────────────────────────────
- (void)setupWebView {
    _webView = [[WKWebView alloc] init];
    _webView.underPageBackgroundColor = [UIColor whiteColor];
    if (@available(iOS 13.0, *)) {
        _webView.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_webView];

    [NSLayoutConstraint activateConstraints:@[
        [_webView.topAnchor constraintEqualToAnchor:_headerView.bottomAnchor],
        [_webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)loadNews {
    if (self.urlString) {
        NSURL *url = [NSURL URLWithString:self.urlString];
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

// ── Navigation — same pattern as CDR app ─────────────────────────────────────
- (void)closeToHome {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
