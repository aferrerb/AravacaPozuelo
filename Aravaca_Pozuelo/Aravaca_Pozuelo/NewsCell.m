//
//  NewsCell.m
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 19/03/2026.
//

#import "NewsCell.h"
#import "NewsItem.h"

@implementation NewsCell {
    UIImageView             *_thumbnailImageView;
    UILabel                 *_titleLabel;
    UIActivityIndicatorView *_spinner;
    NSURLSessionDataTask    *_imageTask;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // ── Card shape ───────────────────────────────────────
        //self.contentView.backgroundColor    = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor colorWithRed:0.98 green:0.96 blue:0.93 alpha:1.0];
        self.contentView.layer.cornerRadius = 12;
        self.contentView.layer.masksToBounds = YES;
        self.layer.shadowColor   = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.10;
        self.layer.shadowOffset  = CGSizeMake(0, 2);
        self.layer.shadowRadius  = 5;

        // ── Thumbnail — top 50% ──────────────────────────────
        _thumbnailImageView = [[UIImageView alloc] init];
        _thumbnailImageView.contentMode   = UIViewContentModeScaleAspectFill;
        _thumbnailImageView.clipsToBounds = YES;
        _thumbnailImageView.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.0];
        _thumbnailImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_thumbnailImageView];

        [NSLayoutConstraint activateConstraints:@[
            [_thumbnailImageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
            [_thumbnailImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [_thumbnailImageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
            [_thumbnailImageView.heightAnchor constraintEqualToAnchor:self.contentView.widthAnchor multiplier:0.5625],
        ]];

        // ── Spinner centred in thumbnail ─────────────────────
        _spinner = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
        _spinner.translatesAutoresizingMaskIntoConstraints = NO;
        _spinner.hidesWhenStopped = YES;
        [_thumbnailImageView addSubview:_spinner];

        [NSLayoutConstraint activateConstraints:@[
            [_spinner.centerXAnchor constraintEqualToAnchor:_thumbnailImageView.centerXAnchor],
            [_spinner.centerYAnchor constraintEqualToAnchor:_thumbnailImageView.centerYAnchor],
        ]];

        // ── Title — bottom 50%, white area ───────────────────
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font          = [UIFont fontWithName:@"Montserrat-Regular" size:19];
        _titleLabel.textColor     = [UIColor colorWithWhite:0.15 alpha:1.0];
        _titleLabel.numberOfLines = 3;
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_titleLabel];

        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.topAnchor constraintEqualToAnchor:_thumbnailImageView.bottomAnchor constant:8],
            [_titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:10],
            [_titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10],
            [_titleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
        ]];
    }
    return self;
}

// ── Configure ─────────────────────────────────────────────────────────────────
- (void)configureWithNewsItem:(NewsItem *)item {
    _titleLabel.text          = item.title;
    _thumbnailImageView.image = nil;
    [_spinner startAnimating];

    NSURL *url = [NSURL URLWithString:item.imageURL];
    if (!url) {
        [_spinner stopAnimating];
        return;
    }

    // Cancel any in-flight task from a reused cell
    [_imageTask cancel];

    // Use cache — instant on second load
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:30];

    _imageTask = [[NSURLSession sharedSession]
        dataTaskWithRequest:request
          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            UIImage *img = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_thumbnailImageView.alpha = 0.0;
                self->_thumbnailImageView.image = img;
                [self->_spinner stopAnimating];
                [UIView animateWithDuration:0.25 animations:^{
                    self->_thumbnailImageView.alpha = 1.0;
                }];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->_spinner stopAnimating];
            });
        }
    }];
    [_imageTask resume];
}

// ── Reuse ─────────────────────────────────────────────────────────────────────
- (void)prepareForReuse {
    [super prepareForReuse];
    [_imageTask cancel];
    _imageTask                = nil;
    _thumbnailImageView.image = nil;
    _titleLabel.text          = nil;
}

@end
