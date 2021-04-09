//Adopted from https://github.com/LacertosusRepo/Preference-Cell-Examples/blob/main/Switch%20with%20Info%20Cell/
#import "KMQSegmentWithInfoCell.h"

@implementation KMQSegmentWithInfoCell {
    OBWelcomeController *_welcomeController;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier {
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if(self) {
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        self.accessoryView = infoButton;
        [infoButton addTarget:self action:@selector(infoButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
-(void)infoButtonTapped {
    NSString *title = [self.specifier propertyForKey:@"infoTitle"];
    UIImage *icon;
    if([self.specifier propertyForKey:@"isInfoIconSystemImage"]) {
        icon = [UIImage systemImageNamed:[self.specifier propertyForKey:@"infoIcon"]];
    }
    else {
        PSListController *controller = [self cellTarget];
        icon = [UIImage imageNamed:[self.specifier propertyForKey:@"infoIcon"] inBundle:[controller bundle] compatibleWithTraitCollection:nil];
    }

    _welcomeController = [[OBWelcomeController alloc] initWithTitle:title detailText:nil icon:icon];

    NSArray *infoBulletItems = [self.specifier propertyForKey:@"infoBulletItems"];
    for(NSDictionary *bulletItem in infoBulletItems) {
        UIImage *image;
        if([bulletItem[@"isSystemImage"] boolValue]) {
            image = [UIImage systemImageNamed:bulletItem[@"image"]];
        }
        else {
            PSListController *controller = [self cellTarget];
            image = [UIImage imageNamed:bulletItem[@"image"] inBundle:[controller bundle] compatibleWithTraitCollection:nil];
        }
        [_welcomeController addBulletedListItemWithTitle:bulletItem[@"title"] description:bulletItem[@"description"] image:image];
    }

    OBBoldTrayButton *continueButton = [OBBoldTrayButton buttonWithType:1];
    [continueButton addTarget:self action:@selector(dismissWelcomeController) forControlEvents:UIControlEventTouchUpInside];
    [continueButton setTitle:@"Done" forState:UIControlStateNormal];
    [continueButton setClipsToBounds:YES];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueButton.layer setCornerRadius:15];
    [_welcomeController.buttonTray addButton:continueButton];

    _welcomeController.modalPresentationStyle = UIModalPresentationPageSheet;
    _welcomeController.view.tintColor = [UIColor systemOrangeColor];
    
    UIViewController *rootViewController = self._viewControllerForAncestor ?: [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:_welcomeController animated:YES completion:nil];
}
-(void)dismissWelcomeController {
    [_welcomeController dismissViewControllerAnimated:YES completion:nil];
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
