//
//  SplashViewController.m
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 19/03/2026.
//
#import "SplashViewController.h"
#import "HomeViewController.h"
#import "AppData.h"

@interface SplashViewController ()
@property (nonatomic, strong) UIImageView *splashImageView;
@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ── CHANGE THIS COLOUR WHEN YOU KNOW IT ──────────────────
    self.view.backgroundColor = [UIColor colorWithRed:0x2D/255.0
                                                green:0x5E/255.0
                                                 blue:0x61/255.0
                                                alpha:1.0];
    // ─────────────────────────────────────────────────────────

    // Add your logo to Assets.xcassets named "AppLogo"
    UIImage *img = [UIImage imageNamed:@"AppLogo"];
    self.splashImageView = [[UIImageView alloc] initWithImage:img];
    self.splashImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.splashImageView.alpha = 0.0;
    self.splashImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.splashImageView];

    [NSLayoutConstraint activateConstraints:@[
        [self.splashImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.splashImageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.splashImageView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.6],
        [self.splashImageView.heightAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.6],
    ]];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"AravacaPozuelo";
    titleLabel.font = [UIFont fontWithName:@"CabinSketch-Regular" size:50];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleLabel];
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [titleLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
    ]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self runSplashAnimation];
    [self fetchData];
}

- (void)fetchData {
    [[AppData shared] fetchWithCompletion:^(BOOL success) {
        if (success) {
            [self goToHome];
        } else {
            [self showError];
        }
    }];
}

- (void)showError {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Sin conexión"
        message:@"No se pudo cargar el contenido y no hay datos guardados. Comprueba tu conexión e inténtalo de nuevo."
        preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Reintentar"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            [self fetchData];
        }]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)runSplashAnimation {
    // Fade IN over 0.6s, hold for 1s, fade OUT, then go to Home
    [UIView animateWithDuration:0.6
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        self.splashImageView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6
                              delay:1.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.splashImageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self goToHome];
        }];
    }];
}

- (void)goToHome {
    HomeViewController *home = [HomeViewController new];

    UINavigationController *nav = [[UINavigationController alloc]
                                    initWithRootViewController:home];
    nav.navigationBarHidden = YES;
    nav.view.backgroundColor = [UIColor colorWithRed:0x2D/255.0
                                               green:0x5E/255.0
                                                blue:0x61/255.0
                                               alpha:1.0];
    UIWindow *w = self.view.window;
    if (!w) {
        for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                w = ((UIWindowScene *)scene).windows.firstObject;
                break;
            }
        }
    }

    if (w) {
        [UIView transitionWithView:w
                          duration:0.35
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
            w.rootViewController = nav;
        } completion:nil];
        [w makeKeyAndVisible];
    }
}

@end
