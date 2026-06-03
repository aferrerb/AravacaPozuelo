//
//  GateKeeper.h
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 07/04/2026.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GateKeeper : NSObject

+ (BOOL)isUnlocked;

+ (void)presentGateFrom:(UIViewController *)presentingVC
        credentialsHint:(NSString *)hint
             completion:(void (^)(BOOL granted))completion;

@end
