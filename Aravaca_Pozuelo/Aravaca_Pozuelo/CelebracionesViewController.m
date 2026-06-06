//
//  CelebracionesViewController.m
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 03/06/2026.
//

#import "CelebracionesViewController.h"
#import <WebKit/WebKit.h>
#import <UserNotifications/UserNotifications.h>

@import BranchSDK;

//static NSString * const kDevURL  = @"https://igroglobal.com/aravacapozuelo/fiestas_dev.html";
// When ready for production, swap the URL in loadPage below to kProdURL:
static NSString * const kProdURL = @"https://igroglobal.com/aravacapozuelo/fiestas.html";

@interface CelebracionesViewController () <WKScriptMessageHandler>
@property (nonatomic, strong) UIView    *headerView;
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation CelebracionesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupHeader];
    [self setupWebView];
    [self loadPage];
    [self trackViewEvent];
}

// ── Header ────────────────────────────────────────────────────────────────────
// Mirrors the pattern used throughout the app.

- (void)setupHeader {
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = [UIColor whiteColor];
    _headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_headerView];

    [NSLayoutConstraint activateConstraints:@[
        [_headerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_headerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:68],
    ]];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [backBtn setTitle:@"‹" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:38];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [backBtn addTarget:self action:@selector(closeToHome) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:backBtn];
    [NSLayoutConstraint activateConstraints:@[
        [backBtn.leadingAnchor constraintEqualToAnchor:_headerView.leadingAnchor constant:8],
        [backBtn.bottomAnchor constraintEqualToAnchor:_headerView.bottomAnchor constant:-10],
        [backBtn.widthAnchor constraintEqualToConstant:44],
        [backBtn.heightAnchor constraintEqualToConstant:44],
    ]];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.pageTitle ?: @"Celebraciones";
    titleLabel.font = [UIFont fontWithName:@"CabinSketch-Regular" size:24];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 2;
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
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *shareIcon = [UIImage systemImageNamed:@"square.and.arrow.up"];
    [shareBtn setImage:shareIcon forState:UIControlStateNormal];
    shareBtn.tintColor = [UIColor colorWithRed:0x2D/255.0
                                         green:0x5E/255.0
                                          blue:0x61/255.0
                                         alpha:1.0];
    shareBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [shareBtn addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:shareBtn];
    [NSLayoutConstraint activateConstraints:@[
        [shareBtn.trailingAnchor constraintEqualToAnchor:_headerView.trailingAnchor constant:-12],
        [shareBtn.bottomAnchor constraintEqualToAnchor:_headerView.bottomAnchor constant:-14],
        [shareBtn.widthAnchor constraintEqualToConstant:36],
        [shareBtn.heightAnchor constraintEqualToConstant:36],
    ]];
}

// ── Web View ──────────────────────────────────────────────────────────────────

- (void)setupWebView {
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];

    // Register the JS message handler named "notifications".
    // JS calls: window.webkit.messageHandlers.notifications.postMessage({...})
    [config.userContentController addScriptMessageHandler:self name:@"notifications"];

    _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.opaque = NO;
    _webView.underPageBackgroundColor = [UIColor whiteColor];
    _webView.scrollView.backgroundColor = [UIColor whiteColor];

    if (@available(iOS 13.0, *)) {
        // Keep light mode consistent with the rest of the app.
        _webView.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }

    [self.view addSubview:_webView];
    [NSLayoutConstraint activateConstraints:@[
        [_webView.topAnchor constraintEqualToAnchor:_headerView.bottomAnchor],
        [_webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)loadPage {
    NSURL *url = [NSURL URLWithString:kProdURL];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

// ── Navigation ────────────────────────────────────────────────────────────────

- (void)closeToHome {
    [self.navigationController popViewControllerAnimated:YES];
}

// ── WKScriptMessageHandler ────────────────────────────────────────────────────
// Receives all messages posted by JS via:
//   window.webkit.messageHandlers.notifications.postMessage({action, ...})

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {

    if (![message.name isEqualToString:@"notifications"]) return;
    if (![message.body isKindOfClass:[NSDictionary class]]) return;

    NSDictionary *body = message.body;
    NSString *action   = body[@"action"];

    if ([action isEqualToString:@"schedule"]) {
        [self handleSchedule:body];
    } else if ([action isEqualToString:@"cancel"]) {
        [self handleCancel:body];
    }
}

// ── Schedule ──────────────────────────────────────────────────────────────────
// Payload keys: key, name, day, month, offset (0/-1/-2/-7), hour, minute

- (void)handleSchedule:(NSDictionary *)payload {
    NSString *key    = payload[@"key"];
    NSString *name   = payload[@"name"];
    NSInteger day    = [payload[@"day"]    integerValue];
    NSInteger month  = [payload[@"month"]  integerValue];
    NSInteger offset = [payload[@"offset"] integerValue]; // days before feast (0 or negative)
    NSInteger hour   = [payload[@"hour"]   integerValue];
    NSInteger minute = [payload[@"minute"] integerValue];

    if (!key || !name || day == 0 || month == 0) {
        NSLog(@"⚠️ Celebraciones: invalid schedule payload: %@", payload);
        return;
    }

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    // Check authorisation before scheduling.
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        if (settings.authorizationStatus != UNAuthorizationStatusAuthorized) {
            NSLog(@"⚠️ Celebraciones: notifications not authorised — skipping schedule for '%@'", name);
            return;
        }
        [self scheduleAnnualNotificationWithKey:key
                                           name:name
                                            day:day
                                          month:month
                                         offset:offset
                                           hour:hour
                                         minute:minute];
    }];
}

- (void)scheduleAnnualNotificationWithKey:(NSString *)key
                                     name:(NSString *)name
                                      day:(NSInteger)day
                                    month:(NSInteger)month
                                   offset:(NSInteger)offset
                                     hour:(NSInteger)hour
                                   minute:(NSInteger)minute {

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

    // Remove any existing notification for this feast before re-scheduling.
    [center removePendingNotificationRequestsWithIdentifiers:@[key]];

    // Build the notification content.
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];

    NSString *offsetLabel = @"";
    if      (offset == -1) offsetLabel = @" (mañana)";
    else if (offset == -2) offsetLabel = @" (en 2 días)";
    else if (offset == -7) offsetLabel = @" (en 1 semana)";

    content.title = [NSString stringWithFormat:@"✝ %@", name];
    content.body  = (offset == 0)
        ? @"Celebración litúrgica hoy"
        : [NSString stringWithFormat:@"Celebración litúrgica%@", offsetLabel];
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = @{
        @"destination_type": @"url",
        @"destination_url":  @"https://igroglobal.com/aravacapozuelo/fiestas_dev.html",
        @"title":            name
    };

    // Calculate the actual notification date by applying the offset to the feast date.
    // We schedule for the current year; if the date has already passed this year,
    // UNCalendarNotificationTrigger with repeats:YES will fire next year automatically.
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month  = month;
    components.day    = day + offset; // NSDateComponents handles day overflow correctly
    components.hour   = hour;
    components.minute = minute;
    components.second = 0;

    UNCalendarNotificationTrigger *trigger =
        [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components
                                                                 repeats:YES];

    UNNotificationRequest *request =
        [UNNotificationRequest requestWithIdentifier:key
                                             content:content
                                             trigger:trigger];

    [center addNotificationRequest:request withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"❌ Celebraciones: failed to schedule '%@': %@", name, error);
        } else {
            NSLog(@"✅ Celebraciones: scheduled '%@' — %ld/%ld offset:%ld at %02ld:%02ld",
                  name, (long)month, (long)day, (long)offset, (long)hour, (long)minute);
        }
    }];
}

// ── Cancel ────────────────────────────────────────────────────────────────────
// Payload keys: key

- (void)handleCancel:(NSDictionary *)payload {
    NSString *key = payload[@"key"];
    if (!key) return;

    [[UNUserNotificationCenter currentNotificationCenter]
        removePendingNotificationRequestsWithIdentifiers:@[key]];

    NSLog(@"🗑 Celebraciones: cancelled notification for key '%@'", key);
}

// ── Cleanup ───────────────────────────────────────────────────────────────────
// Remove the script message handler when the VC is deallocated to avoid a
// retain cycle (WKUserContentController holds a strong reference to its handlers).

- (void)dealloc {
    [_webView.configuration.userContentController
        removeScriptMessageHandlerForName:@"notifications"];
}

#pragma mark - Share

- (void)shareTapped {
    NSString *title = @"Celebraciones - AravacaPozuelo";
    NSString *url   = @"https://igroglobal.com/aravacapozuelo/fiestas.html";

    BranchUniversalObject *buo = [[BranchUniversalObject alloc]
        initWithCanonicalIdentifier:@"celebraciones"];
    buo.title = title;

    BranchLinkProperties *lp = [[BranchLinkProperties alloc] init];
    lp.feature = @"sharing";
    [lp addControlParam:@"destination_type" withValue:@"url"];
    [lp addControlParam:@"destination_url"  withValue:url];
    [lp addControlParam:@"title"            withValue:title];

    [buo getShortUrlWithLinkProperties:lp andCallback:^(NSString *branchURL, NSError *error) {
        if (error || !branchURL) {
            NSLog(@"❌ Branch link error: %@", error);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIActivityViewController *actVC = [[UIActivityViewController alloc]
                initWithActivityItems:@[branchURL]
                applicationActivities:nil];
            [self presentViewController:actVC animated:YES completion:nil];
        });
    }];
}

- (void)trackViewEvent {
    NSString *title = @"Celebraciones";

    BranchUniversalObject *buo = [[BranchUniversalObject alloc]
        initWithCanonicalIdentifier:[NSString stringWithFormat:@"title %@", title]];
    buo.title = title;
    buo.contentMetadata.contentSchema = BranchContentSchemaCommerceProduct;

    BranchEvent *event = [BranchEvent standardEvent:BranchStandardEventViewItem
                                    withContentItem:buo];
    event.alias = [NSString stringWithFormat:@"%@", title];
    [event logEvent];
}

@end
