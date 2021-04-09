#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#include <RemoteLog.h>
#import "NSTask.h"
#import "KMQAnimatedTitleView.h"

@interface PSListController (Private)
-(BOOL)containsSpecifier:(PSSpecifier *)arg1;
@end

@interface OBButtonTray : UIView
- (void)addButton:(id)arg1;
- (void)addCaptionText:(id)arg1;
@end

@interface OBLinkTrayButton : UIButton
-(void)setTitle:(id)arg1 forState:(unsigned long long)arg2;
+(instancetype)linkButton;
@end

@interface OBBoldTrayButton : UIButton
-(void)setTitle:(id)arg1 forState:(unsigned long long)arg2;
+(id)buttonWithType:(long long)arg1;
@end

@interface OBWelcomeController : UIViewController
- (OBButtonTray *)buttonTray;
- (id)initWithTitle:(id)arg1 detailText:(id)arg2 icon:(id)arg3;
- (void)addBulletedListItemWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3;
@end

@interface KMQRootListController : PSListController
@property (strong, nonatomic) NSMutableDictionary *savedSpecifiers;
-(void)updateSpecifierVisibility:(BOOL)animated;
@property (strong, nonatomic) UIView *headerView;
-(void)updateHeaderView;
@property (strong, nonatomic) KMQAnimatedTitleView *titleView;
-(void)setupWelcomeController;
-(void)dismissWelcomeController;
@end
