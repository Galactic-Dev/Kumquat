#include "KMQRootListController.h"

@implementation KMQRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
        
        NSArray *chosenIDs = @[@"layoutForNotifications", @"layoutForNotificationsGroupCell"];
        self.savedSpecifiers = (self.savedSpecifiers) ?: [NSMutableDictionary dictionary];
        for(PSSpecifier *specifier in [self specifiersForIDs:chosenIDs]) {
            [self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
        }
	}

	return _specifiers;
}

-(void)updateSpecifierVisibility:(BOOL)animated {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist"];
    if(![prefs[@"switchIfNotifications"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"layoutForNotificationsGroupCell"], self.savedSpecifiers[@"layoutForNotifications"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"layoutForNotifications"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"layoutForNotificationsGroupCell"], self.savedSpecifiers[@"layoutForNotifications"]] afterSpecifierID:@"switchIfNotifications" animated:animated];
    }
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    [super setPreferenceValue:value specifier:specifier];
    NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    [settings setObject:value forKey:specifier.properties[@"key"]];
    [settings writeToFile:path atomically:YES];
    

    CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (notificationName) {
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }
    
    [self updateSpecifierVisibility:YES];
    
    if([specifier.properties[@"key"] isEqualToString:@"defaultStyle"]) {
        [self updateHeaderView];
    }
}

-(void)updateHeaderView {
    CGFloat originalHeight = self.headerView.frame.size.height;
    
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist"];
    int defaultStyle = [prefs[@"defaultStyle"] intValue];
    
    UIImageView *imageView = self.headerView.subviews[0];
    int imageLayout = defaultStyle + 1;
    imageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/kumquatprefs.bundle/header%d.png", imageLayout]];
    
    CGFloat imageHeight = imageView.image.size.height * imageView.image.scale;
    CGFloat imageWidth = imageView.image.size.width * imageView.image.scale;
    
    CGFloat newWidth = self.view.frame.size.width - 20;
    if(newWidth > 556) newWidth = 556;
    CGFloat newHeight = (imageHeight * newWidth) / imageWidth;
    
    CGRect frame = self.headerView.frame;
    frame.size.height = newHeight;
    imageView.frame = frame;

    self.headerView.frame = frame;

    UILabel *label = self.headerView.subviews[1];
    //i have no idea why i have to remove the view, but the centerYAnchor won't update unless i do
    [label removeFromSuperview];
    [self.headerView addSubview:label];
    [label.centerXAnchor constraintEqualToAnchor:self.headerView.centerXAnchor].active = YES;

    switch (defaultStyle) {
        case 1:
            [label.centerYAnchor constraintEqualToAnchor:imageView.centerYAnchor constant:50].active = YES;
            [self.titleView setValue:@200 forKey:@"_minimumOffsetRequired"];
            break;
        default:
            [self.titleView setValue:@0 forKey:@"_minimumOffsetRequired"];
            [label.centerYAnchor constraintEqualToAnchor:imageView.centerYAnchor constant:imageView.frame.size.height/-4].active = YES;
            break;
    }
    
    [self reloadSpecifiers];
    
    if(originalHeight - self.headerView.frame.size.height < 0) {
        CGPoint bottomOffset = CGPointMake(0, self.table.contentSize.height - self.table.bounds.size.height + self.table.contentInset.bottom);
        [self.table setContentOffset:bottomOffset animated:YES];
    }
    [self scrollViewDidScroll:self.table];
}

-(void)reloadSpecifiers {
    [super reloadSpecifiers];
    
    [self updateSpecifierVisibility:NO];
}

-(void)enabledSwitchChanged:(UISwitch *)enabledSwitch {
    NSString *path = @"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist";
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    if (enabledSwitch.on){
        [settings setObject:@1 forKey:@"isEnabled"];
    }
    else {
        [settings setObject:@0 forKey:@"isEnabled"];
    }
    [settings writeToFile:path atomically:YES];
    
    //Sleeping to give time for UISwitch animating to complete. It just looks cleaner that way, and I can't find a way to check if the UISwitch is still animating.
    [NSThread sleepForTimeInterval:0.3f];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStyleDone target:self action:@selector(respring)];
    self.navigationItem.rightBarButtonItem.tintColor = UIColor.systemRedColor;
}

-(void)respring {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/sbreload"];
    [task launch];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateSpecifierVisibility:NO];
    
    UISwitch *enabledSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [enabledSwitch addTarget:self action:@selector(enabledSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    NSString *path = @"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist";
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    NSNumber *isEnabled = [settings valueForKey:@"isEnabled"] ?: @1;
    if([isEnabled isEqual:@1]){
        [enabledSwitch setOn:YES animated:NO];
    }
    else {
        [enabledSwitch setOn:NO animated:NO];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:enabledSwitch];
    
    if(!self.navigationItem.titleView) {
        self.titleView = [[KMQAnimatedTitleView alloc] initWithTitle:@"Kumquat" minimumScrollOffsetRequired:0];
        self.navigationItem.titleView = self.titleView;
        self.titleView.superview.clipsToBounds = YES;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.headerView) {
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist"];
        int imageLayout = [prefs[@"defaultStyle"] intValue] + 1;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/kumquatprefs.bundle/header%d.png", imageLayout]]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        CGFloat imageHeight = imageView.image.size.height * imageView.image.scale;
        CGFloat imageWidth = imageView.image.size.width * imageView.image.scale;
        
        CGFloat newWidth = self.view.frame.size.width - 20;
        if(newWidth > 556) newWidth = 556;
        CGFloat newHeight = (imageHeight * newWidth) / imageWidth;
        
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - newWidth) / 2, 25, newWidth, newHeight)];
        [self.headerView addSubview:imageView];
        imageView.frame = self.headerView.frame;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,125,50)];
        label.text = @"Kumquat";
        label.font = [UIFont systemFontOfSize:25 weight:UIFontWeightHeavy];
        label.textAlignment = NSTextAlignmentCenter;
        [self.headerView addSubview:label];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self updateHeaderView];
    }
    tableView.tableHeaderView = self.headerView;
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if([self.navigationItem.titleView respondsToSelector:@selector(adjustLabelPositionToScrollOffset:)]) {
        [(KMQAnimatedTitleView *)self.navigationItem.titleView adjustLabelPositionToScrollOffset:scrollView.contentOffset.y];
    }}
@end
