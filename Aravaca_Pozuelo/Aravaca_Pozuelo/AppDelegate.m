//
//  AppDelegate.m
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 18/03/2026.
//

#import "AppDelegate.h"
@import FirebaseCore;
@import FirebaseMessaging;

@interface AppDelegate () <FIRMessagingDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    [application registerForRemoteNotifications];
    // Override point for customization after application launch.
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}


#pragma mark - FIRMessagingDelegate

- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"🔑 FCM Token: %@", fcmToken);
    [[NSUserDefaults standardUserDefaults] setObject:fcmToken forKey:@"FCMToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - APNs

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [FIRMessaging messaging].APNSToken = deviceToken;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"❌ APNs registration failed: %@", error);
}

@end
