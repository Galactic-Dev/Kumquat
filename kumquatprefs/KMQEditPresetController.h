#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#include <RemoteLog.h>
#import "NSTask.h"
#import "KMQRootListController.h"

@interface KMQEditPresetController : PSListController
@property (strong, nonatomic) NSMutableDictionary *savedSpecifiers;
-(void)updateSpecifierVisibility:(BOOL)animated;
@property (strong, nonatomic) NSMutableDictionary *preset;
@end
