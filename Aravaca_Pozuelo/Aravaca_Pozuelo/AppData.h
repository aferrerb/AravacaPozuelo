//
//  AppData.h
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 25/03/2026.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppData : NSObject

@property (nonatomic, strong, readonly) NSArray *homeRows;
@property (nonatomic, strong, readonly) NSArray      *pages;
@property (nonatomic, strong, readonly) NSArray      *articles;
@property (nonatomic, strong, readonly) NSArray      *nav;

+ (instancetype)shared;

- (void)fetchWithCompletion:(void(^)(BOOL success))completion;

- (nullable NSDictionary *)articleWithID:(NSInteger)articleID;
- (nullable NSDictionary *)pageWithID:(NSInteger)pageID;

@end

NS_ASSUME_NONNULL_END
