#include "KMQRootListController.h"
//WARNING BAD CODE ALERT

OBWelcomeController *welcomeController;
@implementation KMQRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
        
        NSArray *chosenIDs = @[@"layoutForNotifications", @"layoutForNotificationsGroupCell", @"customPresets", @"customPresetsNotifs", @"editPresets", @"editPresetsNotifs", @"customPresetsDisabledNotifs", @"customPresetsNotifsGroup"];
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
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"layoutForNotificationsGroupCell"], self.savedSpecifiers[@"layoutForNotifications"], self.savedSpecifiers[@"customPresetsNotifsGroup"], self.savedSpecifiers[@"customPresetsDisabledNotifs"], self.savedSpecifiers[@"customPresetsNotifs"],self.savedSpecifiers[@"editPresetsNotifs"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"layoutForNotifications"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"layoutForNotificationsGroupCell"], self.savedSpecifiers[@"layoutForNotifications"], self.savedSpecifiers[@"customPresetsNotifsGroup"], self.savedSpecifiers[@"customPresetsDisabledNotifs"], self.savedSpecifiers[@"customPresetsNotifs"], self.savedSpecifiers[@"editPresetsNotifs"]] afterSpecifierID:@"switchIfNotifications" animated:animated];
    }
    
    if([prefs[@"customPresetsDisabled"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"customPresets"], self.savedSpecifiers[@"editPresets"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"customPresets"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"customPresets"], self.savedSpecifiers[@"editPresets"]] afterSpecifierID:@"customPresetsDisabled" animated:animated];
    }
    
    if([prefs[@"customPresetsDisabledNotifs"] boolValue] || ![prefs[@"switchIfNotifications"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"customPresetsNotifs"], self.savedSpecifiers[@"editPresetsNotifs"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"customPresetsNotifs"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"customPresetsNotifs"], self.savedSpecifiers[@"editPresetsNotifs"]] afterSpecifierID:@"customPresetsDisabledNotifs" animated:animated];
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
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist"];
    int defaultStyle = [prefs[@"defaultStyle"] intValue];
    
    int imageLayout = [prefs[@"defaultStyle"] intValue] + 1;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Library/PreferenceBundles/kumquatprefs.bundle/header%d.png", imageLayout]]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGFloat originalHeight = self.headerView.frame.size.height;
    CGFloat imageHeight = imageView.image.size.height * imageView.image.scale;
    CGFloat imageWidth = imageView.image.size.width * imageView.image.scale;
    
    CGFloat newWidth = self.view.frame.size.width - 100;
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
        
    CGRect frame = self.headerView.frame;
    frame.size.height = newHeight;
    imageView.frame = frame;

    self.headerView.frame = frame;

    //i have no idea why i have to remove the view, but the centerYAnchor won't update unless i do
    [label removeFromSuperview];
    [self.headerView addSubview:label];
    [label.centerXAnchor constraintEqualToAnchor:self.headerView.centerXAnchor].active = YES;

    switch (defaultStyle) {
        case 1:
            [label.centerYAnchor constraintEqualToAnchor:imageView.centerYAnchor constant:75].active = YES;
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

-(void)setupWelcomeController {
    NSString *path = @"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist";
    NSMutableDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy;
    [settings setValue:@YES forKey:@"shownWelcomeController"];
    [settings writeToFile:path atomically:YES];
    
    welcomeController = [[OBWelcomeController alloc] initWithTitle:@"Kumquat" detailText:@"By Galactic" icon:[UIImage systemImageNamed:@"forward.end.alt.fill"]];

    [welcomeController addBulletedListItemWithTitle:@"Choose your own style" description:@"Choose from multiple premade styles, or customize your own." image:[UIImage systemImageNamed:@"rectangle.3.offgrid"]];
    [welcomeController addBulletedListItemWithTitle:@"Automatically Switch Styles" description:@"Want to enjoy a larger style, but it gets in the way of your notifications. Don't worry, you can now automatically switch when you receive a notification." image:[UIImage systemImageNamed:@"app.badge"]];
    [welcomeController addBulletedListItemWithTitle:@"Unlimited Customization" description:@"There are tons of options to choose from to fine tune your music player's look." image:[UIImage systemImageNamed:@"gearshape.2"]];
    
    OBLinkTrayButton *linkButton = [OBLinkTrayButton linkButton];
    [linkButton addTarget:self action:@selector(openDonationLink) forControlEvents:UIControlEventTouchUpInside];
    [linkButton setTitle:@"Donate here" forState:UIControlStateNormal];
    
    
    OBBoldTrayButton* continueButton = [OBBoldTrayButton buttonWithType:1];
    [continueButton addTarget:self action:@selector(dismissWelcomeController) forControlEvents:UIControlEventTouchUpInside];
    [continueButton setTitle:@"Get Started" forState:UIControlStateNormal];
    [continueButton setClipsToBounds:YES];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [continueButton.layer setCornerRadius:15];
    
    [welcomeController.buttonTray addButton:continueButton];
    [welcomeController.buttonTray addButton:linkButton];

    [welcomeController.buttonTray addCaptionText:@"Thanks for installing Kumquat!"];

    welcomeController.modalPresentationStyle = UIModalPresentationPageSheet;
    welcomeController.view.tintColor = [UIColor systemOrangeColor];
    [self presentViewController:welcomeController animated:YES completion:nil];
}

-(void)dismissWelcomeController {
    [welcomeController dismissViewControllerAnimated:YES completion:nil];
}
-(void)openDonationLink {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/paypalme/DBrett684"] options:@{} completionHandler:nil];
}
-(void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = @"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist";
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
    
    if(![settings[@"shownWelcomeController"] boolValue]) [self setupWelcomeController];
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *path = @"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist";
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
    
    [self updateSpecifierVisibility:NO];
    
    UISwitch *enabledSwitch = [[UISwitch alloc] init];
    [enabledSwitch addTarget:self action:@selector(enabledSwitchChanged:) forControlEvents:UIControlEventValueChanged];
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
    
    [self updateHeaderView];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tableHeaderView = self.headerView;
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if([self.navigationItem.titleView respondsToSelector:@selector(adjustLabelPositionToScrollOffset:)]) {
        [(KMQAnimatedTitleView *)self.navigationItem.titleView adjustLabelPositionToScrollOffset:scrollView.contentOffset.y];
    }
}

-(void)newPreset {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Preset" message:@"Type a name for your new preset" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
    handler:^(UIAlertAction * action) {
        NSString *name = alert.textFields[0].text;
        PSSpecifier *customPresetsSpecifier = [self specifierForID:@"customPresets"];
        
        NSString *path = @"/User/Library/Preferences/com.galacticdev.kumquatpresets.plist";
        NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path] ?: [NSMutableDictionary dictionary];
        
        [self.presetTitles addObject:name];
        [self.presetValues addObject:@(self.presetTitles.count-1)];

        [self replaceContiguousSpecifiers:@[customPresetsSpecifier] withSpecifiers:@[customPresetsSpecifier]];
        
        NSMutableArray *presets = [settings[@"customPresetsList"] mutableCopy] ?: [NSMutableArray array];
        [presets addObject:@{
            @"title" : name
        }];
        [settings setValue:presets forKey:@"customPresetsList"];
        [settings writeToFile:path atomically:YES];
        
        [self reloadSpecifiers];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    UIAlertAction *importAction = [UIAlertAction actionWithTitle:@"Import" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *text = [UIPasteboard generalPasteboard].string;
        if(!text) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Clipboard empty. Copy the preset to your clipboard to import it!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            NSError *error;
            NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if(dictionary) {
                PSSpecifier *customPresetsSpecifier = [self specifierForID:@"customPresets"];
                
                NSString *path = @"/User/Library/Preferences/com.galacticdev.kumquatpresets.plist";
                NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path] ?: [NSMutableDictionary dictionary];
                
                [self.presetTitles addObject:dictionary[@"title"]];
                [self.presetValues addObject:@(self.presetTitles.count-1)];

                [self replaceContiguousSpecifiers:@[customPresetsSpecifier] withSpecifiers:@[customPresetsSpecifier]];
                
                NSMutableArray *presets = [settings[@"customPresetsList"] mutableCopy] ?: [NSMutableArray array];
                [presets addObject:dictionary];
                [settings setValue:presets forKey:@"customPresetsList"];
                [settings writeToFile:path atomically:YES];
                
                [self reloadSpecifiers];
            }
            else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong. Insure you copied the preset correctly" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                }];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }];
    [alert addAction:importAction];
    [alert addAction:cancelAction];
    [alert addAction:defaultAction];
    [alert addTextFieldWithConfigurationHandler:nil];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(NSArray *)presetValuesSource {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatpresets.plist"];
    if(!self.presetValues) {
        self.presetValues = [NSMutableArray array];
        for(NSDictionary *preset in prefs[@"customPresetsList"]) {
            [self.presetValues addObject:@([prefs[@"customPresetsList"] indexOfObject:preset])];
        }
    }
    return self.presetValues.copy;
}
-(NSArray *)presetTitlesSource {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatpresets.plist"];
    if(!self.presetTitles) {
        self.presetTitles = [NSMutableArray array];
        for(NSDictionary *preset in prefs[@"customPresetsList"]) {
            [self.presetTitles addObject:preset[@"title"]];
        }
    }
    return self.presetTitles.copy;
}
@end
