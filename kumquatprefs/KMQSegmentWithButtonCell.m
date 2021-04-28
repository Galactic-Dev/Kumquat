//Adopted from https://github.com/LacertosusRepo/Preference-Cell-Examples/blob/main/Switch%20with%20Info%20Cell/
#import "KMQSegmentWithButtonCell.h"

@implementation KMQSegmentWithButtonCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if(self) {
        UIButton *button = [UIButton systemButtonWithImage:[UIImage systemImageNamed:@"plus"] target:self action:@selector(buttonTapped)];
        self.accessoryView = button;
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, 66)];
        [self.scrollView addSubview:self.control];
        [self.contentView addSubview:self.scrollView];
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

//whatever i fucking gave up and chose this
-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat contentViewWidth = self.contentView.frame.size.width;
    CGFloat segmentedControlWidth = ([(UISegmentedControl *)self.control numberOfSegments] * 72);
    CGFloat newWidth;
    if(contentViewWidth > segmentedControlWidth) {
        newWidth = contentViewWidth - 5;
    }
    else {
        newWidth = segmentedControlWidth;
    }
    self.control.frame = CGRectMake(self.control.frame.origin.x, self.control.frame.origin.y, newWidth, 29);
    self.scrollView.contentSize = self.control.frame.size;
}
@end
