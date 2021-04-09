//Adopted from https://github.com/LacertosusRepo/Preference-Cell-Examples/blob/main/Switch%20with%20Info%20Cell/
#import <Preferences/PSSegmentTableCell.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface KMQSegmentWithInfoCell : PSSegmentTableCell
@end

@interface UIView (Private)
-(UIViewController *)_viewControllerForAncestor;
@end

@interface OBButtonTray : UIView
- (void)addButton:(id)arg1;
- (void)addCaptionText:(id)arg1;;
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
