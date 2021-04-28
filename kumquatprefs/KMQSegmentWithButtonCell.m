//Adopted from https://github.com/LacertosusRepo/Preference-Cell-Examples/blob/main/Switch%20with%20Info%20Cell/
#import "KMQSegmentWithButtonCell.h"

@interface UISegmentedControlNoSwipe : UISegmentedControl
@end

@implementation UISegmentedControlNoSwipe
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        RLog(@"yes");
        return YES;
    }
    else {
        RLog(@"no");
        return NO;
    }
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *orig = [super hitTest:point withEvent:event];
    
    for(UIView *subview in self.subviews.reverseObjectEnumerator) {
        CGPoint subPoint = [subview convertPoint:point fromView:self];
        UIView *result = [subview hitTest:subPoint withEvent:event];
        RLog(@"result %@", result);
        if(result || [result isKindOfClass:NSClassFromString(@"UISegmentLabel")]) {
            return result;
        }
        return nil;
    }
    return orig;
}
@end

@implementation KMQSegmentWithButtonCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if(self) {
        UIButton *button = [UIButton systemButtonWithImage:[UIImage systemImageNamed:@"plus"] target:self action:@selector(buttonTapped)];
        self.accessoryView = button;
    }
    [self.contentView.subviews[0] removeFromSuperview];
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.frame];
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.control];
    self.scrollView.contentSize = self.control.frame.size;
    return self;
}
-(void)buttonTapped {
    PSListController *listController = (PSListController *)self._viewControllerForAncestor;
    [listController performSelector:NSSelectorFromString([self.specifier propertyForKey:@"action"])];
}
-(void)tintColorDidChange {
  [super tintColorDidChange];
  self.accessoryView.tintColor = self.tintColor;
}

-(void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier {
  [super refreshCellContentsWithSpecifier:specifier];
/*
    RLog(@"callllllled");
    UISegmentedControl *control = (UISegmentedControl *)self.control;
    control.frame = CGRectMake(control.frame.origin.x, control.frame.origin.y, (76 * control.numberOfSegments), control.frame.size.height);
    RLog(@"frame %@", NSStringFromCGRect(control.frame));
    self.scrollView.contentSize = control.frame.size;*/
    
  if([self respondsToSelector:@selector(tintColor)]) {
    self.accessoryView.tintColor = self.tintColor;
  }
}/*
-(void)controlChanged:(UISegmentedControlNoSwipe *)control {
    RLog(@"callllllled");
    control.frame = CGRectMake(control.frame.origin.x, control.frame.origin.y, (76 * control.numberOfSegments), control.frame.size.height);
    RLog(@"frame %@", NSStringFromCGRect(control.frame));
    self.scrollView.contentSize = control.frame.size;
    [super controlChanged:control];
}
-(void)setControl:(UISegmentedControlNoSwipe *)control {
    RLog(@"hi");
    NSDictionary *titleDict = [self valueForKey:@"_titleDict"];
    NSMutableArray *titles = [NSMutableArray array];
    for(int i = 0; i < titleDict.allKeys.count; i++) {
        [titles addObject:titleDict[@(i)]];
    }
    control = [[UISegmentedControlNoSwipe alloc] initWithItems:titles];
    control.frame = CGRectMake(control.frame.origin.x, control.frame.origin.y, (76 * control.numberOfSegments), 44);
    RLog(@"frame %@", NSStringFromCGRect(control.frame));
    self.scrollView.contentSize = control.frame.size;
    [super setControl:control];
}*/
@end
