#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#include <RemoteLog.h>

@interface PSListController (Private)
-(BOOL)containsSpecifier:(PSSpecifier *)arg1;
@end

@interface KMQTransportButtonsController : PSListController
@property (strong, nonatomic) NSMutableDictionary *savedSpecifiers;
@property (strong, nonatomic) NSMutableDictionary *preset;
-(void)updateSpecifierVisibility:(BOOL)animated;
@end
