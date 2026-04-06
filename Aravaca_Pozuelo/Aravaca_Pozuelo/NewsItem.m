//
//  NewsItem.m
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 19/03/2026.
//

#import "NewsItem.h"

@implementation NewsItem

- (instancetype)initWithTitle:(NSString *)title
                     imageURL:(NSString *)imageURL
                       webURL:(NSString *)webURL
                  contentType:(NSString *)contentType {
    self = [super init];
    if (self) {
        _title       = [title copy];
        _imageURL    = [imageURL copy];
        _webURL      = [webURL copy];
        _contentType = [contentType copy];
    }
    return self;
}

- (BOOL)isPDF {
    return [self.contentType isEqualToString:@"pdf"];
}

- (BOOL)isWebBased {
    return [self.contentType isEqualToString:@"link"]   ||
           [self.contentType isEqualToString:@"article"]||
           [self.contentType isEqualToString:@"video"];
}

@end
