//
//  CredentialsHintViewController.m
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 07/04/2026.
//

#import "CredentialsHintViewController.h"

@interface CredentialsHintViewController ()
@property (nonatomic, strong) UIView *cardView;
@end

@implementation CredentialsHintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];

    // Card
    _cardView = [[UIView alloc] init];
    _cardView.backgroundColor = [UIColor whiteColor];
    _cardView.layer.cornerRadius = 16;
    _cardView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_cardView];

    [NSLayoutConstraint activateConstraints:@[
        [_cardView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_cardView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [_cardView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.85],
    ]];

    // Title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Credenciales de acceso";
    titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithRed:0x2D/255.0 green:0x5E/255.0 blue:0x61/255.0 alpha:1.0];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_cardView addSubview:titleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:_cardView.topAnchor constant:24],
        [titleLabel.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:16],
        [titleLabel.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],
    ]];

    // Subtitle
    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text = @"Copia las credenciales para acceder:";
    subtitle.font = [UIFont fontWithName:@"Montserrat-Regular" size:13];
    subtitle.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    subtitle.textAlignment = NSTextAlignmentCenter;
    subtitle.numberOfLines = 0;
    subtitle.translatesAutoresizingMaskIntoConstraints = NO;
    [_cardView addSubview:subtitle];

    [NSLayoutConstraint activateConstraints:@[
        [subtitle.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:8],
        [subtitle.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:16],
        [subtitle.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],
    ]];

    // Parse hint lines
    NSArray *lines = [self.hint componentsSeparatedByString:@"\n"];
    UIView *lastView = subtitle;

    UIColor *teal = [UIColor colorWithRed:0x2D/255.0
                                    green:0x5E/255.0
                                     blue:0x61/255.0
                                    alpha:1.0];

    for (NSString *line in lines) {
        NSString *trimmed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (!trimmed.length) continue;

        // Row container
        UIView *row = [[UIView alloc] init];
        row.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
        row.layer.cornerRadius = 8;
        row.translatesAutoresizingMaskIntoConstraints = NO;
        [_cardView addSubview:row];

        [NSLayoutConstraint activateConstraints:@[
            [row.topAnchor constraintEqualToAnchor:lastView.bottomAnchor constant:12],
            [row.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:16],
            [row.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],
            [row.heightAnchor constraintGreaterThanOrEqualToConstant:48],
        ]];

        // Credential label
        UILabel *credLabel = [[UILabel alloc] init];
        credLabel.text = trimmed;
        credLabel.font = [UIFont fontWithName:@"Courier" size:15];
        credLabel.textColor = [UIColor colorWithWhite:0.15 alpha:1.0];
        credLabel.translatesAutoresizingMaskIntoConstraints = NO;
        credLabel.numberOfLines = 0;
        credLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [row addSubview:credLabel];

        // Copy button
        UIButton *copyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [copyBtn setTitle:@"Copiar" forState:UIControlStateNormal];
        copyBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:13];
        copyBtn.tintColor = teal;
        copyBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [row addSubview:copyBtn];

        // Store the text to copy
        NSString *textToCopy = trimmed;
        // Extract just the value after ": " if present
        NSRange colonRange = [trimmed rangeOfString:@": "];
        if (colonRange.location != NSNotFound) {
            textToCopy = [trimmed substringFromIndex:colonRange.location + 2];
        }
        NSString *captured = textToCopy;
        [copyBtn addAction:[UIAction actionWithHandler:^(__kindof UIAction *action) {
            [UIPasteboard generalPasteboard].string = captured;
            [copyBtn setTitle:@"✓ Copiado" forState:UIControlStateNormal];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                [copyBtn setTitle:@"Copiar" forState:UIControlStateNormal];
            });
        }] forControlEvents:UIControlEventTouchUpInside];

        [NSLayoutConstraint activateConstraints:@[
            [credLabel.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:12],
            [credLabel.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
            [credLabel.trailingAnchor constraintEqualToAnchor:copyBtn.leadingAnchor constant:-8],

            [copyBtn.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-12],
            [copyBtn.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
            [copyBtn.widthAnchor constraintEqualToConstant:80],
        ]];

        lastView = row;
    }

    // Continuar button
    UIButton *continueBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [continueBtn setTitle:@"Continuar" forState:UIControlStateNormal];
    continueBtn.titleLabel.font = [UIFont fontWithName:@"Montserrat-Bold" size:16];
    continueBtn.backgroundColor = teal;
    [continueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    continueBtn.layer.cornerRadius = 10;
    continueBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [continueBtn addTarget:self action:@selector(continueTapped) forControlEvents:UIControlEventTouchUpInside];
    [_cardView addSubview:continueBtn];

    [NSLayoutConstraint activateConstraints:@[
        [continueBtn.topAnchor constraintEqualToAnchor:lastView.bottomAnchor constant:20],
        [continueBtn.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:16],
        [continueBtn.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],
        [continueBtn.heightAnchor constraintEqualToConstant:48],
        [continueBtn.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor constant:-24],
    ]];
}

- (void)continueTapped {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.onContinue) self.onContinue();
    }];
}

@end
