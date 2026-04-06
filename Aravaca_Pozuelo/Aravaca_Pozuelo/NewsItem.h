//
//  NewsItem.h
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 19/03/2026.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewsItem : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *imageURL;
@property (nonatomic, copy, readonly) NSString *webURL;
@property (nonatomic, copy, readonly) NSString *contentType; // "link" | "article" | "pdf" | "video"
@property (nonatomic, strong, nullable) NSDictionary *rawData;
- (instancetype)initWithTitle:(NSString *)title
                     imageURL:(NSString *)imageURL
                       webURL:(NSString *)webURL
                  contentType:(NSString *)contentType;

// Convenience checkers
- (BOOL)isPDF;
- (BOOL)isWebBased;

@end

NS_ASSUME_NONNULL_END
