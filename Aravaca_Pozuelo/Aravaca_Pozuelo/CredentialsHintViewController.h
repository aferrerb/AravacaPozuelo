//
//  CredentialsHintViewController.h
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 07/04/2026.
//

#import <UIKit/UIKit.h>

@interface CredentialsHintViewController : UIViewController

@property (nonatomic, copy) NSString *hint;
@property (nonatomic, copy) void (^onContinue)(void);

@end
