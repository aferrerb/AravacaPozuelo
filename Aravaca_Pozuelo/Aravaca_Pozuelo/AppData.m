//  AppData.m
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 25/03/2026.


#import "AppData.h"

static NSString * const kAPIURL    = @"https://ap.igroglobal.com/api/menu.php";
static NSString * const kCacheKey  = @"AppDataCache";

@interface AppData ()
@property (nonatomic, strong) NSArray *homeRows;
@property (nonatomic, strong) NSArray      *pages;
@property (nonatomic, strong) NSArray      *articles;
@property (nonatomic, strong) NSArray      *nav;
@end

@implementation AppData

+ (instancetype)shared {
    static AppData *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{ instance = [AppData new]; });
    return instance;
}

- (void)fetchWithCompletion:(void(^)(BOOL success))completion {
    NSURL *url = [NSURL URLWithString:kAPIURL];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
        dataTaskWithURL:url
      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (error || !data) {
            // Network failed — try cache
            NSData *cached = [[NSUserDefaults standardUserDefaults] dataForKey:kCacheKey];
            if (cached && [self parseData:cached]) {
                dispatch_async(dispatch_get_main_queue(), ^{ completion(YES); });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{ completion(NO); });
            }
            return;
        }

        if ([self parseData:data]) {
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCacheKey];
            dispatch_async(dispatch_get_main_queue(), ^{ completion(YES); });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{ completion(NO); });
        }
    }];
    [task resume];
}

- (BOOL)parseData:(NSData *)data {
    NSError *err;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data
                                                        options:0
                                                          error:&err];
    if (err || ![root isKindOfClass:[NSDictionary class]]) return NO;

    self.homeRows = root[@"home_rows"] ?: @[];
    self.pages    = root[@"pages"]     ?: @[];
    self.articles = root[@"articles"]  ?: @[];
    self.nav      = root[@"nav"]       ?: @[];
    return YES;
}

- (nullable NSDictionary *)articleWithID:(NSInteger)articleID {
    for (NSDictionary *a in self.articles) {
        if ([a[@"id"] integerValue] == articleID) return a;
    }
    return nil;
}

- (nullable NSDictionary *)pageWithID:(NSInteger)pageID {
    for (NSDictionary *p in self.pages) {
        if ([p[@"id"] integerValue] == pageID) return p;
    }
    return nil;
}

@end
