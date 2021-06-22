#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <RemoteLog.h>
#import <dlfcn.h>

BOOL notifications = NO;
NSInteger currentLayout;

//Preference Values
BOOL isEnabled;

NSInteger defaultLayout;
NSInteger layoutForNotifications;
BOOL switchIfNotifications;

BOOL presetsDisabled;
BOOL presetsDisabledNotifs;
NSInteger selectedPreset;
NSInteger selectedPresetNotifs;
NSInteger currentPreset;

BOOL hideRouteButton;
BOOL hideRouteLabel;
BOOL hideArtwork;
BOOL hideIconView;
BOOL hideVolumeBar;
BOOL hideScrubber;
BOOL disableHeaderViewTouches;
BOOL disableHeaderViewTouchesArtwork;
BOOL disableHeaderViewTouchesText;
CGFloat backgroundAlpha;
CGFloat customArtworkCornerRadius;
CGFloat customCornerRadius;
BOOL removeSpeakerIcons;
NSInteger headerTextAlignment;
BOOL hideQuickActionButtons;

BOOL hasCustomHeaderFrame;
NSInteger headerFrameOption;
CGFloat headerX;
CGFloat headerY;
CGFloat headerWidth;
CGFloat headerHeight;

BOOL hasCustomArtworkFrame;
NSInteger artworkFrameOption;
CGFloat artworkX;
CGFloat artworkY;
CGFloat artworkWidth;
CGFloat artworkHeight;

BOOL hasCustomPlayerFrame;
NSInteger playerFrameOption;
CGFloat playerX;
CGFloat playerY;
CGFloat playerWidth;
CGFloat playerHeight;

BOOL hasCustomVolumeBarFrame;
NSInteger volumeFrameOption;
CGFloat volumeX;
CGFloat volumeY;
CGFloat volumeWidth;
CGFloat volumeHeight;

BOOL hasCustomScrubberFrame;
NSInteger scrubberFrameOption;
CGFloat scrubberX;
CGFloat scrubberY;
CGFloat scrubberWidth;
CGFloat scrubberHeight;

BOOL hasCustomTransportFrame;
NSInteger transportFrameOption;
CGFloat transportX;
CGFloat transportY;
CGFloat transportWidth;
CGFloat transportHeight;

static void updatePreset() {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist"];
    NSMutableDictionary *presetPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatpresets.plist"];
    
    presetsDisabled = prefs[@"customPresetsDisabled"] ? [prefs[@"customPresetsDisabled"] boolValue] : NO;
    presetsDisabledNotifs = prefs[@"customPresetsDisabledNotifs"] ? [prefs[@"customPresetsDisabledNotifs"] boolValue] : NO;
    
    selectedPreset = prefs[@"selectedPreset"] ? [prefs[@"selectedPreset"] intValue] : 0;
    selectedPresetNotifs = prefs[@"selectedPresetNotifs"] ? [prefs[@"selectedPresetNotifs"] intValue] : 0;
    
    if(switchIfNotifications && notifications) {
        currentPreset = selectedPresetNotifs;
    }
    else {
        currentPreset = selectedPreset;
    }
    
    NSArray *presets = presetPrefs[@"customPresetsList"];

    if(selectedPreset > presets.count-1) {
        selectedPreset = 0;
    }
    if(selectedPresetNotifs > presets.count-1) {
        selectedPresetNotifs = 0;
    }
    NSDictionary *preset;
    if(presets.count <= 0) {
        preset = nil;
    }
    else if(switchIfNotifications && notifications) {
        if(!presetsDisabledNotifs) preset = presets[selectedPresetNotifs];
        else preset = nil;
    }
    else {
        if(!presetsDisabled) preset = presets[selectedPreset];
        else preset = nil;
    }
    
    hideRouteButton = preset[@"hideRouteButton"] ? [preset[@"hideRouteButton"] boolValue] : NO;
    hideRouteLabel = preset[@"hideRouteLabel"] ? [preset[@"hideRouteLabel"] boolValue] : NO;
    hideArtwork = preset[@"hideArtwork"] ? [preset[@"hideArtwork"] boolValue] : NO;
    hideIconView = preset[@"hideIconView"] ? [preset[@"hideIconView"] boolValue] : NO;
    hideVolumeBar = preset[@"hideVolumeBar"] ? [preset[@"hideVolumeBar"] boolValue] : NO;
    hideScrubber = preset[@"hideScrubber"] ? [preset[@"hideScrubber"] boolValue] : NO;
    disableHeaderViewTouches = preset[@"disableHeaderViewTouches"] ? [preset[@"disableHeaderViewTouches"] boolValue] : NO;
    disableHeaderViewTouchesArtwork = preset[@"disableHeaderViewTouchesArtwork"] ? [preset[@"disableHeaderViewTouchesArtwork"] boolValue] : YES;
    disableHeaderViewTouchesText = preset[@"disableHeaderViewTouchesText"] ? [preset[@"disableHeaderViewTouchesText"] boolValue] : YES;
    removeSpeakerIcons = preset[@"removeSpeakerIcons"] ? [preset[@"removeSpeakerIcons"] boolValue] : NO;
    headerTextAlignment = preset[@"headerTextAlignment"] ? [preset[@"headerTextAlignment"] intValue] : 0;
    hideQuickActionButtons = preset[@"hideQuickActionButtons"] ? [preset[@"hideQuickActionButtons"] boolValue] : NO;
    
    
    backgroundAlpha = preset[@"backgroundAlpha"] ? [preset[@"backgroundAlpha"] floatValue] : 1.0f;
    customCornerRadius = preset[@"customCornerRadius"] && ![preset[@"customCornerRadius"] isEqualToString:@""]? [preset[@"customCornerRadius"] floatValue] : -1;
    customArtworkCornerRadius = preset[@"customArtworkCornerRadius"] && ![preset[@"customArtworkCornerRadius"] isEqualToString:@""]? [preset[@"customArtworkCornerRadius"] floatValue] : -1;

    
    hasCustomHeaderFrame = preset[@"hasCustomHeaderFrame"] ? [preset[@"hasCustomHeaderFrame"] boolValue] : NO;
    if(hasCustomHeaderFrame) {
        headerFrameOption = preset[@"headerFrameOption"] ? [preset[@"headerFrameOption"] intValue] : 0;
        headerX = preset[@"headerX"] ? [preset[@"headerX"] floatValue] : 0;
        headerY = preset[@"headerY"] ? [preset[@"headerY"] floatValue] : 0;
        headerWidth = preset[@"headerWidth"] ? [preset[@"headerWidth"] floatValue] : 0;
        headerHeight = preset[@"headerHeight"] ? [preset[@"headerHeight"] floatValue] : 0;
    }
    
    hasCustomArtworkFrame = preset[@"hasCustomArtworkFrame"] ? [preset[@"hasCustomArtworkFrame"] boolValue] : NO;
    if(hasCustomArtworkFrame) {
        artworkFrameOption = preset[@"artworkFrameOption"] ? [preset[@"artworkFrameOption"] intValue] : 0;
        artworkX = preset[@"artworkX"] ? [preset[@"artworkX"] floatValue] : 0;
        artworkY = preset[@"artworkY"] ? [preset[@"artworkY"] floatValue] : 0;
        artworkWidth = preset[@"artworkWidth"] ? [preset[@"artworkWidth"] floatValue] : 0;
        artworkHeight = preset[@"artworkHeight"] ? [preset[@"artworkHeight"] floatValue] : 0;
    }
    
    hasCustomPlayerFrame = preset[@"hasCustomPlayerFrame"] ? [preset[@"hasCustomPlayerFrame"] boolValue] : NO;
    if(hasCustomPlayerFrame) {
        playerFrameOption = preset[@"playerFrameOption"] ? [preset[@"playerFrameOption"] intValue] : 0;
        playerX = preset[@"playerX"] ? [preset[@"playerX"] floatValue] : 0;
        playerY = preset[@"playerY"] ? [preset[@"playerY"] floatValue] : 0;
        playerWidth = preset[@"playerWidth"] ? [preset[@"playerWidth"] floatValue] : 0;
        playerHeight = preset[@"playerHeight"] ? [preset[@"playerHeight"] floatValue] : 0;
    }
    
    hasCustomVolumeBarFrame = preset[@"hasCustomVolumeBarFrame"] ? [preset[@"hasCustomVolumeBarFrame"] boolValue]: NO;
    if(hasCustomVolumeBarFrame) {
        volumeFrameOption = preset[@"volumeFrameOption"] ? [preset[@"volumeFrameOption"] intValue] : 0;
        volumeX = preset[@"volumeX"] ? [preset[@"volumeX"] floatValue] : 0;
        volumeY = preset[@"volumeY"] ? [preset[@"volumeY"] floatValue] : 0;
        volumeWidth = preset[@"volumeWidth"] ? [preset[@"volumeWidth"] floatValue] : 0;
        volumeHeight = preset[@"volumeHeight"] ? [preset[@"volumeHeight"] floatValue] : 44;
    }
    
    hasCustomScrubberFrame = preset[@"hasCustomScrubberFrame"] ? [preset [@"hasCustomScrubberFrame"] boolValue]: NO;
    if(hasCustomScrubberFrame) {
        scrubberFrameOption = preset[@"scrubberFrameOption"] ? [preset[@"scrubberFrameOption"] intValue] : 0;
        scrubberX = preset[@"scrubberX"] ? [preset[@"scrubberX"] floatValue] : 0;
        scrubberY = preset[@"scrubberY"] ? [preset[@"scrubberY"] floatValue] : 0;
        scrubberWidth = preset[@"scrubberWidth"] ? [preset[@"scrubberWidth"] floatValue] : 0;
        scrubberHeight = preset[@"scrubberHeight"] ? [preset[@"scrubberHeight"] floatValue] : 44;
    }
    
    hasCustomTransportFrame = preset[@"hasCustomTransportFrame"] ? [preset[@"hasCustomTransportFrame"] boolValue]: NO;
    if(hasCustomTransportFrame) {
        transportFrameOption = preset[@"transportFrameOption"] ? [preset[@"transportFrameOption"] intValue] : 0;
        transportX = preset[@"transportX"] ? [preset[@"transportX"] floatValue] : 0;
        transportY = preset[@"transportY"] ? [preset[@"transportY"] floatValue] : 0;
        transportWidth = preset[@"transportWidth"] ? [preset[@"transportWidth"] floatValue] : 0;
        transportHeight = preset[@"transportHeight"] ? [preset[@"transportHeight"] floatValue] : 44;
    }
}

static void loadPrefs() {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist"];

    isEnabled = prefs[@"isEnabled"] ? [prefs[@"isEnabled"] boolValue] : YES;
    
    defaultLayout = prefs[@"defaultStyle"] ? [prefs[@"defaultStyle"] intValue] : 0;
    currentLayout = defaultLayout;
    
    layoutForNotifications = prefs[@"layoutForNotifications"] ? [prefs[@"layoutForNotifications"] intValue] : 0;
    switchIfNotifications = prefs[@"switchIfNotifications"] ? [prefs[@"switchIfNotifications"] boolValue] : NO;
    notifications = NO;
    
    updatePreset();
}

@interface UILabel (Private)
-(void)setMarqueeEnabled:(BOOL)arg1;
-(void)setMarqueeRunning:(BOOL)arg2;
@end

@interface MRUArtworkView : UIView
@property (strong, nonatomic) UIView *iconView;
@property (strong, nonatomic) UIView *iconShadowView;
@property (strong, nonatomic) UIView *artworkShadowView;
@property (strong, nonatomic) UIImageView *artworkImageView;
@end

@interface MRUNowPlayingVolumeControlsView : UIView
@property (strong, nonatomic) UISlider *slider;
@end

@interface MRUNowPlayingTimeControlsView : UIView
@property (strong, nonatomic) UIView *knobView;
@end

@interface _UISliderVisualElement : UIView
@end

@interface MRUNowPlayingTransportControlsView : UIView
@property (strong, nonatomic) UIView *leftButton;
@property (strong, nonatomic) UIView *middleButton;
@property (strong, nonatomic) UIView *rightButton;
@end

@interface MRUTransportButton : UIView
@end

@interface MPRouteLabel : UIView
@end

@interface MPUMarqueeView : UIView
@end

@interface MRUNowPlayingLabelView : UIView
@property (strong, nonatomic) MPRouteLabel *routeLabel;
@property (strong, nonatomic) MPUMarqueeView *titleMarqueeView;
@property (strong, nonatomic) MPUMarqueeView *subtitleMarqueeView;
@end

@interface MRUNowPlayingHeaderView : UIView
@property (strong, nonatomic) MRUArtworkView *artworkView;
@property (nonatomic, assign) BOOL showArtworkView;
@property (nonatomic, assign) BOOL showRoutingButton;
@property (strong, nonatomic) MRUNowPlayingLabelView *labelView;
@end

@interface MRUNowPlayingControlsView : UIView
@property (strong, nonatomic) MRUNowPlayingHeaderView *headerView;
@property (strong, nonatomic) UIView *volumeControlsView;
@property (nonatomic, assign) BOOL showTimeControlsView;
@property (strong, nonatomic) MRUNowPlayingTransportControlsView *transportControlsView;
@end

@interface MRUNowPlayingContainerView : UIView
@property (nonatomic, assign) BOOL showSeparator;
@end

@interface MRUNowPlayingView : UIView
@property (strong, nonatomic) MRUNowPlayingContainerView *containerView;
@property (strong, nonatomic) MRUNowPlayingControlsView *controlsView;
@property (nonatomic, assign) NSInteger context;
@property (nonatomic, assign) NSInteger layout;
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;
@end

@interface CSMediaControlsViewController : UIViewController
@end

@interface CSAdjunctListView : UIView
-(void)_layoutStackView;
@end

@interface CSNotificationAdjunctListViewController : UIViewController
-(void)_insertItem:(id)arg1 animated:(BOOL)arg2;
@property (nonatomic,retain) NSMutableDictionary * identifiersToItems;
@property (strong, nonatomic) UIStackView *stackView;
@property (strong, nonatomic) CSAdjunctListView *view;
@end

//Notification stuff
@interface AXNView : UIView
@property (strong, nonatomic) UICollectionView *collectionView;
@end
