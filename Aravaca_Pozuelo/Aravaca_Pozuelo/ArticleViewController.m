//
//  ArticleViewController.m
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 27/03/2026.


#import "ArticleViewController.h"
#import <WebKit/WebKit.h>

@interface ArticleViewController ()
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) NSInteger fontSize;
@end

@implementation ArticleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _fontSize = 16;

    [self setupHeader];
    [self setupWebView];
    [self loadArticle];
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
        [headerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:44],
    ]];

    // Back button
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"‹" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:38];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:backBtn];
    [NSLayoutConstraint activateConstraints:@[
        [backBtn.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:8],
        [backBtn.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-4],
        [backBtn.widthAnchor constraintEqualToConstant:44],
        [backBtn.heightAnchor constraintEqualToConstant:44],
    ]];

    // Teal colour for right-side buttons
    UIColor *teal = [UIColor colorWithRed:0x2D/255.0
                                    green:0x5E/255.0
                                     blue:0x61/255.0
                                    alpha:1.0];

    // A+ button
    UIButton *fontUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fontUpBtn setTitle:@"A+" forState:UIControlStateNormal];
    fontUpBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17];
    [fontUpBtn setTitleColor:teal forState:UIControlStateNormal];
    fontUpBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [fontUpBtn addTarget:self action:@selector(fontUp) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:fontUpBtn];
    [NSLayoutConstraint activateConstraints:@[
        [fontUpBtn.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-12],
        [fontUpBtn.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-10],
        [fontUpBtn.widthAnchor constraintEqualToConstant:36],
        [fontUpBtn.heightAnchor constraintEqualToConstant:36],
    ]];

    // A- button
    UIButton *fontDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fontDownBtn setTitle:@"A-" forState:UIControlStateNormal];
    fontDownBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17];
    [fontDownBtn setTitleColor:teal forState:UIControlStateNormal];
    fontDownBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [fontDownBtn addTarget:self action:@selector(fontDown) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:fontDownBtn];
    [NSLayoutConstraint activateConstraints:@[
        [fontDownBtn.trailingAnchor constraintEqualToAnchor:fontUpBtn.leadingAnchor constant:-4],
        [fontDownBtn.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-10],
        [fontDownBtn.widthAnchor constraintEqualToConstant:36],
        [fontDownBtn.heightAnchor constraintEqualToConstant:36],
    ]];

    // Share button
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *shareIcon = [UIImage systemImageNamed:@"square.and.arrow.up"];
    [shareBtn setImage:shareIcon forState:UIControlStateNormal];
    shareBtn.tintColor = teal;
    shareBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [shareBtn addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:shareBtn];
    [NSLayoutConstraint activateConstraints:@[
        [shareBtn.trailingAnchor constraintEqualToAnchor:fontDownBtn.leadingAnchor constant:-8],
        [shareBtn.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-10],
        [shareBtn.widthAnchor constraintEqualToConstant:36],
        [shareBtn.heightAnchor constraintEqualToConstant:36],
    ]];

    // Title label — between back and share
    /*UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.article[@"title"] ?: @"";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont fontWithName:@"CabinSketch-Regular" size:22];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.7;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:titleLabel];
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor],
        [titleLabel.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-12],
        [titleLabel.leadingAnchor constraintEqualToAnchor:backBtn.trailingAnchor constant:4],
        [titleLabel.trailingAnchor constraintEqualToAnchor:shareBtn.leadingAnchor constant:-4],
    ]];*/

    // Separator
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

#pragma mark - Font sizing

- (void)fontUp {
    _fontSize = MIN(_fontSize + 2, 28);
    [self applyFontSize];
}

- (void)fontDown {
    _fontSize = MAX(_fontSize - 2, 12);
    [self applyFontSize];
}

- (void)applyFontSize {
    NSString *js = [NSString stringWithFormat:
        @"var el = document.getElementById('font-override');"
        @"if (!el) { el = document.createElement('style'); el.id = 'font-override'; document.head.appendChild(el); }"
                    @"el.textContent = 'body, body p, body div, body span, body li { font-size: %ldpx !important; }';",
                    (long)_fontSize];
    [_webView evaluateJavaScript:js completionHandler:^(id result, NSError *error) {
        if (error) NSLog(@"JS error: %@", error);
    }];
}

#pragma mark - Share

- (void)shareTapped {
    NSString *title = self.article[@"title"] ?: @"";
    NSString *body  = self.article[@"body"]  ?: @"";
    // Strip HTML tags for plain text sharing
    NSRegularExpression *regex = [NSRegularExpression
        regularExpressionWithPattern:@"<[^>]+>" options:0 error:nil];
    NSString *plain = [regex stringByReplacingMatchesInString:body
                                                      options:0
                                                        range:NSMakeRange(0, body.length)
                                                 withTemplate:@""];
    NSString *shareText = [NSString stringWithFormat:@"%@\n\n%@", title, plain];
    // TODO: replace shareText with deep link URL once implemented
    UIActivityViewController *actVC = [[UIActivityViewController alloc]
        initWithActivityItems:@[shareText]
        applicationActivities:nil];
    [self presentViewController:actVC animated:YES completion:nil];
}

- (void)setupWebView {
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:_webView];

    
    [NSLayoutConstraint activateConstraints:@[
        [_webView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:44],
        [_webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)loadArticle {
    NSString *body  = self.article[@"body"]  ?: @"";
    NSString *image = [self.article[@"image"] isKindOfClass:[NSString class]]
                      ? self.article[@"image"] : @"";
    NSLog(@"DEBUG loadArticle image: %@", image);

    NSString *imageHTML = @"";
    if (image.length > 0) {
        imageHTML = [NSString stringWithFormat:
            @"<img src='%@' alt='' "
             "style='width:100%%;height:200px;object-fit:cover;"
             "display:block;border-radius:12px;margin-bottom:16px'>",
            image];
    }

    NSString *html = [NSString stringWithFormat:@"<!DOCTYPE html>"
        "<html><head>"
        "<meta charset='UTF-8'>"
        "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
        "<style>"
        "body { font-family: -apple-system, sans-serif; font-size: 16px; "
        "line-height: 1.6; color: #333; padding: 20px; margin: 0; }"
        "h1 { font-size: 1.4em; color: #1a1a2e; }"
        "h2 { font-size: 1.2em; color: #E63946; }"
        "h3 { font-size: 1.0em; color: #666; }"
        "img { max-width: 100%%; height: auto; }"
        "a { color: #7BA492; }"
        "</style>"
        "</head><body>%@%@</body></html>", imageHTML, body];

    [_webView loadHTMLString:html baseURL:[NSURL URLWithString:@"https://ap.igroglobal.com"]];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
