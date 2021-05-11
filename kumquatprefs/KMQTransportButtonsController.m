#include "KMQTransportButtonsController.h"
//WARNING BAD CODE ALERT
@implementation KMQTransportButtonsController
- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"TransportButtons" target:self];
        
        
        NSArray *chosenIDs = @[@"leftX", @"leftY", @"leftWidth", @"leftHeight", @"middleX", @"middleY", @"middleWidth", @"middleHeight", @"rightX", @"rightY", @"rightWidth", @"rightHeight", @"leftFrameOption", @"middleFrameOption", @"rightFrameOption"];
        self.savedSpecifiers = (self.savedSpecifiers) ?: [NSMutableDictionary dictionary];
        for(PSSpecifier *specifier in [self specifiersForIDs:chosenIDs]) {
            [self.savedSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
        }
    }

    return _specifiers;
}

-(void)updateSpecifierVisibility:(BOOL)animated {
    if(![self.preset[@"hasCustomTransportLeftFrame"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"leftFrameOption"], self.savedSpecifiers[@"leftX"], self.savedSpecifiers[@"leftY"], self.savedSpecifiers[@"leftWidth"], self.savedSpecifiers[@"leftHeight"]] animated:animated];
    }

    else if(![self containsSpecifier:self.savedSpecifiers[@"leftX"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"leftFrameOption"], self.savedSpecifiers[@"leftX"], self.savedSpecifiers[@"leftY"], self.savedSpecifiers[@"leftWidth"], self.savedSpecifiers[@"leftHeight"]] afterSpecifierID:@"hasCustomLeftFrame" animated:animated];
    }

    if(![self.preset[@"hasCustomTransportMiddleFrame"] boolValue]) {
        [self removeContiguousSpecifiers:@[self.savedSpecifiers[@"middleFrameOption"], self.savedSpecifiers[@"middleX"], self.savedSpecifiers[@"middleY"], self.savedSpecifiers[@"middleWidth"], self.savedSpecifiers[@"middleHeight"]] animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"middleX"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"middleFrameOption"], self.savedSpecifiers[@"middleX"], self.savedSpecifiers[@"middleY"], self.savedSpecifiers[@"middleWidth"], self.savedSpecifiers[@"middleHeight"]] afterSpecifierID:@"hasCustomMiddleFrame" animated:animated];
    }

    
    if(![self.preset[@"hasCustomTransportRightFrame"] boolValue]) {
        NSArray *array = @[self.savedSpecifiers[@"rightFrameOption"], self.savedSpecifiers[@"rightX"], self.savedSpecifiers[@"rightY"], self.savedSpecifiers[@"rightWidth"], self.savedSpecifiers[@"rightHeight"]];
        [self removeContiguousSpecifiers:array animated:animated];
    }
    else if(![self containsSpecifier:self.savedSpecifiers[@"rightX"]]) {
        [self insertContiguousSpecifiers:@[self.savedSpecifiers[@"rightFrameOption"], self.savedSpecifiers[@"rightX"], self.savedSpecifiers[@"rightY"], self.savedSpecifiers[@"rightWidth"], self.savedSpecifiers[@"rightHeight"]] afterSpecifierID:@"hasCustomRightFrame" animated:animated];
    }

}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSMutableArray *presets = settings[@"customPresetsList"];
    [presets replaceObjectAtIndex:[presets indexOfObject:self.preset] withObject:self.preset];
    [self.preset setValue:value forKey:specifier.properties[@"key"]];
    [settings setObject:presets forKey:@"customPresetsList"];
    RLog(@"preste!!!s %@", presets);
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

-(void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist"];
    NSDictionary *presetPrefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatpresets.plist"];

    NSInteger selectedPreset = [prefs[@"selectedPreset"] intValue];
    NSArray *presets = presetPrefs[@"customPresetsList"];
    if(selectedPreset < presets.count) {
        self.preset = [presets[selectedPreset] mutableCopy];
    }
    else {
        self.preset = [presets[0] mutableCopy];
    }
    
    [self updateSpecifierVisibility:NO];
}

-(void)_returnKeyPressed:(id)arg1 {
    [self.view endEditing:YES];
}
@end
