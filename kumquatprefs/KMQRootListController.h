#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#include <RemoteLog.h>
#import "NSTask.h"
#import "KMQAnimatedTitleView.h"

@interface PSListController (Private)
-(BOOL)containsSpecifier:(PSSpecifier *)arg1;
@end

@interface KMQRootListController : PSListController
@property (strong, nonatomic) NSMutableDictionary *savedSpecifiers;
-(void)updateSpecifierVisibility:(BOOL)animated;
@property (strong, nonatomic) UIView *headerView;
-(void)updateHeaderView;
@property (strong, nonatomic) KMQAnimatedTitleView *titleView;
@end
