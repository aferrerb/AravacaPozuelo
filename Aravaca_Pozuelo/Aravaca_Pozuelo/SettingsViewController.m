//
//  SettingsViewController.m
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 08/04/2026.
//

#import "SettingsViewController.h"
#import "AppData.h"

static NSString * const kPreferredCentroKey = @"ap_preferred_centro";

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *centros;
@property (nonatomic, assign) NSInteger selectedCentroID;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1.0];
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }

    // Load centro options from banner carousel items
    _centros = [self loadCentros];
    _selectedCentroID = [[NSUserDefaults standardUserDefaults] integerForKey:kPreferredCentroKey];

    [self setupHeader];
    [self setupTableView];
}

- (NSArray *)loadCentros {
    NSArray *homeRows = [AppData shared].homeRows;
    for (NSDictionary *row in homeRows) {
        if ([row[@"type"] isEqualToString:@"carousel"]) {
            return row[@"items"] ?: @[];
        }
    }
    return @[];
}

#pragma mark - Setup

- (void)setupHeader {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:headerView];

    [NSLayoutConstraint activateConstraints:@[
        [headerView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [headerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:52],
    ]];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"‹" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:38];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:backBtn];
    [NSLayoutConstraint activateConstraints:@[
        [backBtn.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:8],
        [backBtn.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-10],
        [backBtn.widthAnchor constraintEqualToConstant:44],
        [backBtn.heightAnchor constraintEqualToConstant:44],
    ]];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Ajustes";
    titleLabel.font = [UIFont fontWithName:@"CabinSketch-Regular" size:28];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:titleLabel];
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor],
        [titleLabel.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:-14],
        [titleLabel.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:52],
        [titleLabel.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-52],
    ]];

    UIView *sep = [[UIView alloc] init];
    sep.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    sep.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:sep];
    [NSLayoutConstraint activateConstraints:@[
        [sep.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor],
        [sep.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor],
        [sep.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor],
        [sep.heightAnchor constraintEqualToConstant:0.5],
    ]];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 13.0, *)) {
        _tableView.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    [self.view addSubview:_tableView];

    [NSLayoutConstraint activateConstraints:@[
        [_tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:52],
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
    return 3;
}

- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"Mi centro";
        case 1: return @"Caché";
        case 2: return @"Compartir";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return _centros.count;
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

    if (indexPath.section == 0) {
        NSDictionary *centro = _centros[indexPath.row];
        NSInteger centroID = [centro[@"id"] integerValue];
        NSString *title = centro[@"title"] ?: @"";
        NSString *colorHex = centro[@"color"] ?: @"#cccccc";

        // Colour dot
        UIView *dot = [[UIView alloc] init];
        dot.layer.cornerRadius = 8;
        dot.translatesAutoresizingMaskIntoConstraints = NO;
        dot.backgroundColor = [self colorFromHex:colorHex];
        [cell.contentView addSubview:dot];
        [NSLayoutConstraint activateConstraints:@[
            [dot.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
            [dot.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
            [dot.widthAnchor constraintEqualToConstant:16],
            [dot.heightAnchor constraintEqualToConstant:16],
        ]];

        UILabel *label = [[UILabel alloc] init];
        label.text = title;
        label.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addSubview:label];
        [NSLayoutConstraint activateConstraints:@[
            [label.leadingAnchor constraintEqualToAnchor:dot.trailingAnchor constant:12],
            [label.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
        ]];

        cell.accessoryType = (centroID == _selectedCentroID)
            ? UITableViewCellAccessoryCheckmark
            : UITableViewCellAccessoryNone;
        cell.tintColor = [UIColor colorWithRed:0x2D/255.0
                                         green:0x5E/255.0
                                          blue:0x61/255.0
                                         alpha:1.0];

    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"Borrar caché";
        cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];
        cell.textLabel.textColor = [UIColor systemRedColor];
        cell.imageView.image = [UIImage systemImageNamed:@"trash"];
        cell.imageView.tintColor = [UIColor systemRedColor];

    } else if (indexPath.section == 2) {
        cell.textLabel.text = @"Recomendar la app";
        cell.textLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:16];
        cell.textLabel.textColor = [UIColor colorWithRed:0x2D/255.0
                                                    green:0x5E/255.0
                                                     blue:0x61/255.0
                                                    alpha:1.0];
        cell.imageView.image = [UIImage systemImageNamed:@"square.and.arrow.up"];
        cell.imageView.tintColor = [UIColor colorWithRed:0x2D/255.0
                                                    green:0x5E/255.0
                                                     blue:0x61/255.0
                                                    alpha:1.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tv deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        NSDictionary *centro = _centros[indexPath.row];
        _selectedCentroID = [centro[@"id"] integerValue];
        [[NSUserDefaults standardUserDefaults] setInteger:_selectedCentroID forKey:kPreferredCentroKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [tv reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];

    } else if (indexPath.section == 1) {
        [self clearCache];

    } else if (indexPath.section == 2) {
        [self shareApp];
    }
}

#pragma mark - Actions

- (void)clearCache {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Borrar caché"
        message:@"¿Seguro que quieres borrar el caché? La app volverá a descargar el contenido."
        preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancelar"
        style:UIAlertActionStyleCancel handler:nil]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Borrar"
        style:UIAlertActionStyleDestructive
        handler:^(UIAlertAction *action) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ap_cached_json"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            UIAlertController *done = [UIAlertController
                alertControllerWithTitle:@"Caché borrado"
                message:@"El contenido se descargará de nuevo la próxima vez que abras la app."
                preferredStyle:UIAlertControllerStyleAlert];
            [done addAction:[UIAlertAction actionWithTitle:@"OK"
                style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:done animated:YES completion:nil];
        }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)shareApp {
    NSString *shareText = @"Te recomiendo la app AravacaPozuelo";
    // TODO: replace with App Store link when available
    UIActivityViewController *actVC = [[UIActivityViewController alloc]
        initWithActivityItems:@[shareText]
        applicationActivities:nil];
    [self presentViewController:actVC animated:YES completion:nil];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helpers

- (UIColor *)colorFromHex:(NSString *)hex {
    hex = [hex stringByReplacingOccurrencesOfString:@"#" withString:@""];
    unsigned int rgb = 0;
    [[NSScanner scannerWithString:hex] scanHexInt:&rgb];
    return [UIColor colorWithRed:((rgb >> 16) & 0xFF) / 255.0
                           green:((rgb >> 8)  & 0xFF) / 255.0
                            blue:( rgb        & 0xFF) / 255.0
                           alpha:1.0];
}

@end
