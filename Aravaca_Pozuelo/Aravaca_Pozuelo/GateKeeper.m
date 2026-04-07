//
//  GateKeeper.m
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 07/04/2026.


#import "GateKeeper.h"

static NSString * const kGateKey      = @"ap_gate_unlocked";
static NSString * const kCorrectUser  = @"aravaca";
static NSString * const kCorrectPass  = @"aravaca01";

@implementation GateKeeper

+ (BOOL)isUnlocked {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kGateKey];
}

+ (void)presentGateFrom:(UIViewController *)presentingVC
        credentialsHint:(NSString *)hint
             completion:(void (^)(BOOL granted))completion {

    if ([self isUnlocked]) {
        completion(YES);
        return;
    }

    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Acceso restringido"
        message:@"Introduce las credenciales para acceder a este contenido."
        preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = @"Usuario";
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = @"Contraseña";
        tf.secureTextEntry = YES;
    }];

    UIAlertAction *enter = [UIAlertAction actionWithTitle:@"Entrar"
        style:UIAlertActionStyleDefault
        handler:^(UIAlertAction *action) {
            NSString *user = alert.textFields[0].text ?: @"";
            NSString *pass = alert.textFields[1].text ?: @"";
            if ([user isEqualToString:kCorrectUser] &&
                [pass isEqualToString:kCorrectPass]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kGateKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                completion(YES);
            } else {
                // Wrong — show error and ask again
                UIAlertController *err = [UIAlertController
                    alertControllerWithTitle:@"Credenciales incorrectas"
                    message:@"Usuario o contraseña incorrectos. Inténtalo de nuevo."
                    preferredStyle:UIAlertControllerStyleAlert];
                [err addAction:[UIAlertAction actionWithTitle:@"Reintentar"
                    style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction *a) {
                    [self presentGateFrom:presentingVC credentialsHint:hint completion:completion];                    }]];
                [err addAction:[UIAlertAction actionWithTitle:@"Cancelar"
                    style:UIAlertActionStyleCancel
                    handler:^(UIAlertAction *a) {
                        completion(NO);
                    }]];
                [presentingVC presentViewController:err animated:YES completion:nil];
            }
        }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancelar"
        style:UIAlertActionStyleCancel
        handler:^(UIAlertAction *action) {
            completion(NO);
        }];

    [alert addAction:enter];
    [alert addAction:cancel];
    [presentingVC presentViewController:alert animated:YES completion:nil];
}


@end
