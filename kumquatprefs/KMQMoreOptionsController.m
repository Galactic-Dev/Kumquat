#include "KMQMoreOptionsController.h"
//WARNING BAD CODE ALERT
@implementation KMQMoreOptionsController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"MoreOptions" target:self];
        
        
        NSArray *chosenIDs = @[@"headerY", @"headerX", @"headerWidth", @"headerHeight", @"artworkX", @"artworkY", @"artworkWidth", @"artworkHeight", @"playerHeight", @"volumeX", @"volumeY", @"volumeWidth", @"volumeHeight", @"scrubberX", @"scrubberY", @"scrubberWidth", @"scrubberHeight", @"transportX", @"transportY", @"transportWidth", @"transportHeight"];
        self.savedSpecifiers = (self.savedSpecifiers) ?: [NSMutableDictionary dictionary];
        for(PSSpecifier *specifier in [self specifiersForIDs:chosenIDs]) {
            [self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
        }
    }

    return _specifiers;
}

-(void)updateSpecifierVisibility:(BOOL)animated {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist"];
    if(![prefs[@"hasCustomHeaderFrame"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"headerX"], self.savedSpecifiers[@"headerY"], self.savedSpecifiers[@"headerWidth"], self.savedSpecifiers[@"headerHeight"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"headerX"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"headerX"], self.savedSpecifiers[@"headerY"], self.savedSpecifiers[@"headerWidth"], self.savedSpecifiers[@"headerHeight"]] afterSpecifierID:@"hasCustomHeaderFrame" animated:animated];
    }
    
    if(![prefs[@"hasCustomArtworkFrame"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"artworkX"], self.savedSpecifiers[@"artworkY"], self.savedSpecifiers[@"artworkWidth"], self.savedSpecifiers[@"artworkHeight"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"artworkX"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"artworkX"], self.savedSpecifiers[@"artworkY"], self.savedSpecifiers[@"artworkWidth"], self.savedSpecifiers[@"artworkHeight"]] afterSpecifierID:@"hasCustomArtworkFrame" animated:animated];
    }
    
    if(![prefs[@"hasCustomPlayerHeight"] boolValue]) {
        [self removeSpecifier:self.savedSpecifiers[@"playerHeight"] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"playerHeight"]]) {
        [self insertSpecifier:self.savedSpecifiers[@"playerHeight"] afterSpecifierID:@"hasCustomPlayerHeight" animated:animated];
    }
    
    if(![prefs[@"hasCustomVolumeBarFrame"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"volumeX"], self.savedSpecifiers[@"volumeY"], self.savedSpecifiers[@"volumeWidth"], self.savedSpecifiers[@"volumeHeight"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"volumeX"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"volumeX"], self.savedSpecifiers[@"volumeY"], self.savedSpecifiers[@"volumeWidth"], self.savedSpecifiers[@"volumeHeight"]] afterSpecifierID:@"hasCustomVolumeBarFrame" animated:animated];
    }
    
    if(![prefs[@"hasCustomScrubberFrame"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"scrubberX"], self.savedSpecifiers[@"scrubberY"], self.savedSpecifiers[@"scrubberWidth"], self.savedSpecifiers[@"scrubberHeight"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"scrubberX"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"scrubberX"], self.savedSpecifiers[@"scrubberY"], self.savedSpecifiers[@"scrubberWidth"], self.savedSpecifiers[@"scrubberHeight"]] afterSpecifierID:@"hasCustomScrubberFrame" animated:animated];
    }
    
    if(![prefs[@"hasCustomTransportFrame"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"transportX"], self.savedSpecifiers[@"transportY"], self.savedSpecifiers[@"transportWidth"], self.savedSpecifiers[@"transportHeight"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"transportX"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"transportX"], self.savedSpecifiers[@"transportY"], self.savedSpecifiers[@"transportWidth"], self.savedSpecifiers[@"transportHeight"]] afterSpecifierID:@"hasCustomTransportFrame" animated:animated];
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

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateSpecifierVisibility:NO];
    
    UISwitch *enabledSwitch = [[UISwitch alloc] init];
    [enabledSwitch addTarget:self action:@selector(enabledSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    NSString *path = @"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist";
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
    NSNumber *isEnabled = [settings valueForKey:@"isEnabled"] ?: @1;
    if([isEnabled isEqual:@1]){
        [enabledSwitch setOn:YES animated:NO];
    }
    else {
        [enabledSwitch setOn:NO animated:NO];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:enabledSwitch];
}

-(void)_returnKeyPressed:(id)arg1 {
    [self.view endEditing:YES];
}
@end
