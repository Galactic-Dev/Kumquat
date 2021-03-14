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
    
    [self updateSpecifierVisibility:YES];

    CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (notificationName) {
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 25, self.view.frame.size.width, 200)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/kumquatprefs.bundle/header.png"]];
    imageView.frame = self.headerView.frame;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.headerView addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,125,50)];
    label.text = @"Kumquat";
    label.font = [UIFont boldSystemFontOfSize:25];
    label.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label.centerXAnchor constraintEqualToAnchor:self.headerView.centerXAnchor].active = YES;
    [label.topAnchor constraintEqualToAnchor:imageView.topAnchor constant:25].active = YES;
    
    if(!self.navigationItem.titleView) {
        KMQAnimatedTitleView *titleView = [[KMQAnimatedTitleView alloc] initWithTitle:@"Kumquat" minimumScrollOffsetRequired:0];
        self.navigationItem.titleView = titleView;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tableHeaderView = self.headerView;
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if([self.navigationItem.titleView respondsToSelector:@selector(adjustLabelPositionToScrollOffset:)]) {
        [(KMQAnimatedTitleView *)self.navigationItem.titleView adjustLabelPositionToScrollOffset:scrollView.contentOffset.y];
    }}
@end
