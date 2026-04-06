//
//  Navdrawerviewcontroller.h
//  Aravaca_Pozuelo
//
//  Created by Ana Ferrer-Bonsoms on 28/03/2026.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NavDrawerDelegate <NSObject>
- (void)drawerDidSelectHome;
- (void)drawerDidSelectURL:(NSString *)urlString title:(NSString *)title;
- (void)drawerDidSelectArticleID:(NSInteger)articleID;
- (void)drawerDidSelectPageID:(NSInteger)pageID;
- (void)drawerDidSelectPDFURL:(NSString *)urlString title:(NSString *)title;
@end

@interface NavDrawerViewController : UIViewController

@property (nonatomic, weak) id<NavDrawerDelegate> delegate;

- (void)openAnimated:(BOOL)animated;
- (void)closeAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
