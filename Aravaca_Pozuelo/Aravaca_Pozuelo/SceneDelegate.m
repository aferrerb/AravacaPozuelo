//
//  SceneDelegate.m
//  Aravaca_Pozuelo
//

#import "SceneDelegate.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <UserNotifications/UserNotifications.h>

@import BranchSDK;

@interface SceneDelegate () <UNUserNotificationCenterDelegate>
@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {

    [UNUserNotificationCenter currentNotificationCenter].delegate = self;

    [[Branch getInstance] initSessionWithLaunchOptions:nil
                             andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {

        if (error) {
            NSLog(@"❌ Branch error: %@", error);
            return;
        }

        NSLog(@"🌿 Branch params: %@", params);

        BOOL clicked = [params[@"+clicked_branch_link"] boolValue];

        if (!clicked) {
            NSLog(@"🌿 Not a clicked Branch link");
            return;
        }

        NSString *destinationType = params[@"destination_type"];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *linkSecret = params[@"gate_secret"];
            if ([linkSecret isEqualToString:@"open-the-date"]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ap_gate_unlocked"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }

            [[NSUserDefaults standardUserDefaults] setObject:destinationType ?: @""
                                                      forKey:@"PendingDeepLinkType"];

            [[NSUserDefaults standardUserDefaults] setObject:params[@"destination_url"] ?: @""
                                                      forKey:@"PendingDeepLinkURL"];

            [[NSUserDefaults standardUserDefaults] setObject:params[@"article_id"] ?: @""
                                                      forKey:@"PendingDeepLinkArticleID"];

            [[NSUserDefaults standardUserDefaults] setObject:params[@"page_id"] ?: @""
                                                      forKey:@"PendingDeepLinkPageID"];

            [[NSUserDefaults standardUserDefaults] setObject:params[@"title"] ?: @""
                                                      forKey:@"PendingDeepLinkTitle"];

            [[NSUserDefaults standardUserDefaults] synchronize];

            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"BranchDeepLinkReceived"
                              object:nil
                            userInfo:@{
                                @"destination_type": destinationType ?: @"",
                                @"destination_url":  params[@"destination_url"] ?: @"",
                                @"article_id":       params[@"article_id"]      ?: @"",
                                @"page_id":          params[@"page_id"]         ?: @"",
                                @"title":            params[@"title"]           ?: @""
                            }];
        });
    }];

    // Cold start Universal Link
    if (connectionOptions.userActivities.count) {
        NSUserActivity *activity = connectionOptions.userActivities.anyObject;

        NSLog(@"❄️ Cold start userActivity: %@", activity.webpageURL);

        [[Branch getInstance] continueUserActivity:activity];
    }

    // Cold start custom scheme
    if (connectionOptions.URLContexts.count) {
        for (UIOpenURLContext *ctx in connectionOptions.URLContexts) {
            NSLog(@"❄️ Cold start URLContext: %@", ctx.URL);

            [[Branch getInstance] application:UIApplication.sharedApplication
                                      openURL:ctx.URL
                                      options:@{}];
        }
    }
}

#pragma mark - ATT + Push

- (void)sceneDidBecomeActive:(UIScene *)scene {
    if (@available(iOS 14, *)) {
        BOOL didPrompt = [[NSUserDefaults standardUserDefaults] boolForKey:@"DidPromptATTAndNotifications"];
        if (!didPrompt) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DidPromptATTAndNotifications"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                    NSLog(@"ATT status = %ld", (long)status);
                    [[Branch getInstance] handleATTAuthorizationStatus:status];

                    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
                    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)
                                         completionHandler:^(BOOL granted, NSError *error) {
                        NSLog(@"Notification permission: %@", granted ? @"GRANTED" : @"DENIED");
                        if (granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[UIApplication sharedApplication] registerForRemoteNotifications];
                            });
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                NSString *fcmToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"FCMToken"];
                                if (fcmToken) {
                                    [self sendTokenToServer:fcmToken];
                                }
                            });
                        }
                    }];
                }];
            });
        }
    } else {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)
                             completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    }
}

#pragma mark - Branch URL handling

// This is the IMPORTANT one for warm-start Universal Links.
// This is what fixed the other app.
- (void)scene:(UIScene *)scene continueUserActivity:(NSUserActivity *)userActivity {
    NSLog(@"🔥 Warm start userActivity WITHOUT restorationHandler");
    NSLog(@"🔥 webpageURL: %@", userActivity.webpageURL);
    NSLog(@"🔥 activityType: %@", userActivity.activityType);
    NSLog(@"🔥 userInfo: %@", userActivity.userInfo);

    [[Branch getInstance] continueUserActivity:userActivity];
}

// Keep this as a fallback.
// Some iOS flows may still call this version.
- (void)scene:(UIScene *)scene
continueUserActivity:(NSUserActivity *)userActivity
restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {

    NSLog(@"🔥 Warm start userActivity WITH restorationHandler");
    NSLog(@"🔥 webpageURL: %@", userActivity.webpageURL);
    NSLog(@"🔥 activityType: %@", userActivity.activityType);
    NSLog(@"🔥 userInfo: %@", userActivity.userInfo);

    [[Branch getInstance] continueUserActivity:userActivity];
}

// Custom scheme warm-start handling.
- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {

    for (UIOpenURLContext *ctx in URLContexts) {
        NSLog(@"🔥 Warm start openURL: %@", ctx.URL);

        [[Branch getInstance] application:UIApplication.sharedApplication
                                  openURL:ctx.URL
                                  options:@{}];
    }
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    NSLog(@"📬 Notification received (foreground): %@", userInfo);
    completionHandler(UNNotificationPresentationOptionBanner |
                      UNNotificationPresentationOptionList  |
                      UNNotificationPresentationOptionBadge |
                      UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {

    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSLog(@"👆 Notification tapped: %@", userInfo);

    NSString *destinationType = userInfo[@"destination_type"];
    NSString *destinationURL  = userInfo[@"destination_url"] ?: @"";
    NSString *title           = userInfo[@"title"] ?: @"";

    // Save to NSUserDefaults so HomeViewController can pick it up on cold start
    if (destinationType.length) {
        [[NSUserDefaults standardUserDefaults] setObject:destinationType forKey:@"PendingDeepLinkType"];
        [[NSUserDefaults standardUserDefaults] setObject:destinationURL  forKey:@"PendingDeepLinkURL"];
        [[NSUserDefaults standardUserDefaults] setObject:@""             forKey:@"PendingDeepLinkArticleID"];
        [[NSUserDefaults standardUserDefaults] setObject:@""             forKey:@"PendingDeepLinkPageID"];
        [[NSUserDefaults standardUserDefaults] setObject:title           forKey:@"PendingDeepLinkTitle"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    // Also post for warm/foreground case
    if (destinationType.length) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]
                postNotificationName:@"BranchDeepLinkReceived"
                              object:nil
                            userInfo:@{
                                @"destination_type": destinationType,
                                @"destination_url":  destinationURL,
                                @"article_id":       @"",
                                @"page_id":          @"",
                                @"title":            title
                            }];
        });
    }

    completionHandler();
}

#pragma mark - Token

- (void)sendTokenToServer:(NSString *)fcmToken {
    NSDictionary *payload = @{
        @"token":       fcmToken,
        @"device_type": @"ios"
    };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    NSURL *url = [NSURL URLWithString:@"https://ap.igroglobal.com/api/save_token.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"❌ Token send failed: %@", error);
        } else {
            NSLog(@"✅ Token sent to server");
        }
    }] resume];
}

#pragma mark - Unused scene lifecycle

- (void)sceneDidDisconnect:(UIScene *)scene {}
- (void)sceneWillResignActive:(UIScene *)scene {}
- (void)sceneWillEnterForeground:(UIScene *)scene {}
- (void)sceneDidEnterBackground:(UIScene *)scene {}

@end
