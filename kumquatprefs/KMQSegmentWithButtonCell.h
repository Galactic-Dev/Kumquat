#import <Preferences/PSSegmentTableCell.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#include <RemoteLog.h>

@interface KMQSegmentWithButtonCell : PSSegmentTableCell
@property (strong, nonatomic) UIScrollView *scrollView;
@end

@interface UIView (Private)
-(UIViewController *)_viewControllerForAncestor;
@end

