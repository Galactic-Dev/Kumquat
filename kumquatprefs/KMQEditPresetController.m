#include "KMQEditPresetController.h"
//WARNING BAD CODE ALERT
@implementation KMQEditPresetController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"MoreOptions" target:self];
        
        
        NSArray *chosenIDs = @[@"headerY", @"headerX", @"headerWidth", @"headerHeight", @"artworkX", @"artworkY", @"artworkWidth", @"artworkHeight", @"playerX", @"playerY", @"playerWidth", @"playerHeight", @"volumeX", @"volumeY", @"volumeWidth", @"volumeHeight", @"scrubberX", @"scrubberY", @"scrubberWidth", @"scrubberHeight", @"transportX", @"transportY", @"transportWidth", @"transportHeight", @"disableHeaderViewTouchesArtwork", @"disableHeaderViewTouchesText", @"headerFrameOption", @"artworkFrameOption", @"playerFrameOption", @"volumeFrameOption", @"scrubberFrameOption", @"transportFrameOption"];
        self.savedSpecifiers = (self.savedSpecifiers) ?: [NSMutableDictionary dictionary];
        for(PSSpecifier *specifier in [self specifiersForIDs:chosenIDs]) {
            [self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
        }
    }

    return _specifiers;
}

-(void)updateSpecifierVisibility:(BOOL)animated {
    if(![self.preset[@"disableHeaderViewTouches"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"disableHeaderViewTouchesArtwork"], self.savedSpecifiers[@"disableHeaderViewTouchesText"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"disableHeaderViewTouchesArtwork"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"disableHeaderViewTouchesArtwork"], self.savedSpecifiers[@"disableHeaderViewTouchesText"]] afterSpecifierID:@"disableHeaderViewTouches" animated:animated];
    }
    
    if(![self.preset[@"hasCustomHeaderFrame"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"headerFrameOption"], self.savedSpecifiers[@"headerX"], self.savedSpecifiers[@"headerY"], self.savedSpecifiers[@"headerWidth"], self.savedSpecifiers[@"headerHeight"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"headerX"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"headerFrameOption"], self.savedSpecifiers[@"headerX"], self.savedSpecifiers[@"headerY"], self.savedSpecifiers[@"headerWidth"], self.savedSpecifiers[@"headerHeight"]] afterSpecifierID:@"hasCustomHeaderFrame" animated:animated];
    }
    
    if(![self.preset[@"hasCustomArtworkFrame"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"artworkFrameOption"], self.savedSpecifiers[@"artworkX"], self.savedSpecifiers[@"artworkY"], self.savedSpecifiers[@"artworkWidth"], self.savedSpecifiers[@"artworkHeight"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"artworkX"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"artworkFrameOption"], self.savedSpecifiers[@"artworkX"], self.savedSpecifiers[@"artworkY"], self.savedSpecifiers[@"artworkWidth"], self.savedSpecifiers[@"artworkHeight"]] afterSpecifierID:@"hasCustomArtworkFrame" animated:animated];
    }
    
    if(![self.preset[@"hasCustomPlayerFrame"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"playerFrameOption"], self.savedSpecifiers[@"playerX"], self.savedSpecifiers[@"playerY"], self.savedSpecifiers[@"playerWidth"], self.savedSpecifiers[@"playerHeight"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"playerX"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"playerFrameOption"], self.savedSpecifiers[@"playerX"], self.savedSpecifiers[@"playerY"], self.savedSpecifiers[@"playerWidth"], self.savedSpecifiers[@"playerHeight"]] afterSpecifierID:@"hasCustomPlayerFrame" animated:animated];
    }
    
    if(![self.preset[@"hasCustomVolumeBarFrame"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"volumeFrameOption"], self.savedSpecifiers[@"volumeX"], self.savedSpecifiers[@"volumeY"], self.savedSpecifiers[@"volumeWidth"], self.savedSpecifiers[@"volumeHeight"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"volumeX"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"volumeFrameOption"], self.savedSpecifiers[@"volumeX"], self.savedSpecifiers[@"volumeY"], self.savedSpecifiers[@"volumeWidth"], self.savedSpecifiers[@"volumeHeight"]] afterSpecifierID:@"hasCustomVolumeBarFrame" animated:animated];
    }
    
    if(![self.preset[@"hasCustomScrubberFrame"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"scrubberFrameOption"], self.savedSpecifiers[@"scrubberX"], self.savedSpecifiers[@"scrubberY"], self.savedSpecifiers[@"scrubberWidth"], self.savedSpecifiers[@"scrubberHeight"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"scrubberX"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"scrubberFrameOption"], self.savedSpecifiers[@"scrubberX"], self.savedSpecifiers[@"scrubberY"], self.savedSpecifiers[@"scrubberWidth"], self.savedSpecifiers[@"scrubberHeight"]] afterSpecifierID:@"hasCustomScrubberFrame" animated:animated];
    }
    
    if(![self.preset[@"hasCustomTransportFrame"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"transportFrameOption"], self.savedSpecifiers[@"transportX"], self.savedSpecifiers[@"transportY"], self.savedSpecifiers[@"transportWidth"], self.savedSpecifiers[@"transportHeight"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"transportX"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"transportFrameOption"], self.savedSpecifiers[@"transportX"], self.savedSpecifiers[@"transportY"], self.savedSpecifiers[@"transportWidth"], self.savedSpecifiers[@"transportHeight"]] afterSpecifierID:@"hasCustomTransportFrame" animated:animated];
    }
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSMutableArray *presets = settings[@"customPresetsList"];
    RLog(@"prestes %@, %d, %@", presets, [presets indexOfObject:self.preset], self.preset);
    [presets replaceObjectAtIndex:[presets indexOfObject:self.preset] withObject:self.preset];
    [self.preset setValue:value forKey:specifier.properties[@"key"]];
    [settings setObject:presets forKey:@"customPresetsList"];
    [settings writeToFile:path atomically:YES];
    
    [self updateSpecifierVisibility:YES];

    CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (notificationName) {
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    }
}

-(id)readPreferenceValue:(PSSpecifier *)specifier {
    return self.preset[specifier.properties[@"key"]];
}

-(void)reloadSpecifiers {
    [super reloadSpecifiers];
    [self updateSpecifierVisibility:NO];
}

-(void)respring {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/sbreload"];
    [task launch];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIBarButtonItem *trashButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deletePreset)];
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sharePreset)];
    NSArray *barButtonItems = @[shareButton, trashButton];
    self.navigationItem.rightBarButtonItems=barButtonItems;
    
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist"];
    NSDictionary *presetPrefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatpresets.plist"];

    NSInteger selectedPreset = [prefs[@"selectedPreset"] intValue];
    NSArray *presets = presetPrefs[@"customPresetsList"];
    self.preset = [presets[selectedPreset] mutableCopy];
    self.title = self.preset[@"title"];
    
    [self updateSpecifierVisibility:NO];
}

-(void)_returnKeyPressed:(id)arg1 {
    [self.view endEditing:YES];
}

-(void)deletePreset {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete This Preset" message:@"Are you sure you want to delete this preset?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive
    handler:^(UIAlertAction * action) {
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist"];
        NSMutableDictionary *presetPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatpresets.plist"];
        
        NSMutableArray *presets = [presetPrefs[@"customPresetsList"] mutableCopy];
        RLog(@"bvefore %@", presets);
        [presets removeObject:self.preset];
        RLog(@"after %@", presets);
        [presetPrefs setObject:presets forKey:@"customPresetsList"];
        
        [prefs setObject:@0 forKey:@"selectedPreset"];
        
        [prefs writeToFile:@"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist" atomically:YES];
        [presetPrefs writeToFile:@"/User/Library/Preferences/com.galacticdev.kumquatpresets.plist" atomically:YES];
        
        [self.navigationController popViewControllerAnimated:YES];

        KMQRootListController *previousController = self.navigationController.viewControllers[self.navigationController.viewControllers.count-1];
        RLog(@"previousController %@", previousController);
        previousController.presetValues = nil;
        previousController.presetTitles = nil;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)sharePreset {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[@"testing"] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}
@end
