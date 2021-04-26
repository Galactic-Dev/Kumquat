//Adopted from https://github.com/LacertosusRepo/Preference-Cell-Examples/blob/main/Switch%20with%20Info%20Cell/
#import "KMQSegmentWithButtonCell.h"

@implementation KMQSegmentWithButtonCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if(self) {
        UIButton *button = [UIButton systemButtonWithImage:[UIImage systemImageNamed:@"plus"] target:self action:@selector(buttonTapped)];
        self.accessoryView = button;
    }
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

  if([self respondsToSelector:@selector(tintColor)]) {
    self.accessoryView.tintColor = self.tintColor;
  }
}
@end

