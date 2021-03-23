#import "Tweak.h"

CSNotificationAdjunctListViewController *adjunctListController;
BOOL notifications = NO;
NSInteger currentLayout;

%hook MRUNowPlayingView
-(void)setContext:(NSInteger)context {
    %orig;
    if(context == 2) {
        switch (currentLayout) {
            case 0:
                self.controlsView.showTimeControlsView = YES;
                self.controlsView.volumeControlsView.hidden = NO;
                break;
            case 1:
                self.layout = 2;
                self.controlsView.showTimeControlsView = YES;
                self.controlsView.volumeControlsView.hidden = NO;
                break;
            case 2:
                self.layout = 1;
                self.containerView.showSeparator = NO;
                self.controlsView.volumeControlsView.hidden = NO;
                self.controlsView.headerView.artworkView.hidden = hideArtwork;
                break;
            case 3:
                self.layout = 1;
                self.containerView.showSeparator = NO;
                self.controlsView.showTimeControlsView = NO;
                self.controlsView.volumeControlsView.hidden = NO;
                self.controlsView.headerView.artworkView.hidden = hideArtwork;
                break;
            case 4:
                self.layout = 1;
                self.containerView.showSeparator = NO;
                self.controlsView.volumeControlsView.hidden = YES;
                self.controlsView.headerView.showArtworkView = hideArtwork;
                break;
        }
        notifications = NO;
    }
}
-(instancetype)initWithFrame:(CGRect)frame {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kumquatStyleChanged) name:@"KumquatStyleChange" object:nil];
    return %orig;
}
-(void)dealloc {
    %orig;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KumquatStyleChange" object:nil];
}
%new
-(void)kumquatStyleChanged {
    if(notifications && switchIfNotifications) {
        currentLayout = layoutForNotifications;
    }
    else {
        currentLayout = defaultLayout;
    }
    if(self.context == 2) {
        switch(currentLayout) {
            case 0:
                self.layout = 4;
                self.controlsView.showTimeControlsView = YES;
                self.controlsView.volumeControlsView.hidden = NO;
                break;
            case 1: {
                self.layout = 2;
                self.controlsView.showTimeControlsView = YES;
                self.controlsView.volumeControlsView.hidden = NO;
                break;
            }
            case 2: {
                self.layout = 1;
                self.containerView.showSeparator = NO;
                self.controlsView.showTimeControlsView = YES;
                self.controlsView.volumeControlsView.hidden = NO;
                self.controlsView.headerView.artworkView.hidden = hideArtwork; //artwork won't hide for some reason with this layout unless i hide it myself
                break;
            }
            case 3:
                self.layout = 1;
                self.containerView.showSeparator = NO;
                self.controlsView.showTimeControlsView = NO;
                self.controlsView.volumeControlsView.hidden = NO;
                self.controlsView.headerView.showArtworkView = hideArtwork;
                break;
            case 4:
                self.layout = 1;
                self.containerView.showSeparator = NO;
                self.controlsView.showTimeControlsView = YES;
                self.controlsView.volumeControlsView.hidden = YES;
                self.controlsView.headerView.showArtworkView = hideArtwork;
                break;
            default:
                self.layout = 4;
                break;
        }
        id nowPlayingItem = [adjunctListController.identifiersToItems objectForKey:@"SBDashBoardNowPlayingAssertionIdentifier"];
        if(nowPlayingItem) {
            [adjunctListController _insertItem:nowPlayingItem animated:NO];
            [adjunctListController.stackView.arrangedSubviews.firstObject removeFromSuperview];
            [adjunctListController.view _layoutStackView];
        }
    }
}
%end

%hook CSMediaControlsViewController
-(instancetype)init {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_layoutMediaControls) name:@"KumquatStyleChange" object:nil];
    return %orig;
}
-(void)dealloc {
    %orig;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KumquatStyleChange" object:nil];
}
-(CGRect)_suggestedFrameForMediaControls {
    CGRect oldRect = %orig;
    if (hasCustomPlayerHeight) {
        return CGRectMake(0, 0, oldRect.size.width, playerHeight);
    }
    switch (currentLayout) {
        case 0:
            return oldRect;
        case 1: {
            self.view.superview.superview.frame = CGRectMake(24, 0, oldRect.size.width - 48, oldRect.size.height + 298 - 26);
            [(UIView *)[self.view.superview.superview valueForKey:@"_backgroundView"] layer].cornerRadius = 42;
            UIViewController *platterViewController = [self valueForKey:@"_platterViewController"];
            MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)platterViewController.childViewControllers[0].view;
            nowPlayingView.contentEdgeInsets = UIEdgeInsetsMake(24,24,24,24);
            return CGRectMake(0, 0, oldRect.size.width - 48, oldRect.size.height + 298 - 26);
        }
        case 2:
            return CGRectMake(0, 0, oldRect.size.width, oldRect.size.height - 44);
        case 3:
            return CGRectMake(0, 0, oldRect.size.width, oldRect.size.height - 44 - 44);
        case 4:
            return CGRectMake(0, 0, oldRect.size.width, oldRect.size.height - 44 - 44);
    }
    return oldRect;
}
%end


%hook CSNotificationAdjunctListViewController
-(instancetype)init {
    adjunctListController = self;
    return %orig;
}
%end

%hook MRUNowPlayingHeaderView
-(void)setFrame:(CGRect)frame {
    if(currentLayout == 1 || hasCustomHeaderFrame) {
        MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
        if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2) {
            if(hasCustomHeaderFrame) {
                %orig(CGRectMake(headerX, headerY, headerWidth, headerHeight));
                return;
            }
        }
    }
    %orig;
}
-(void)setShowRoutingButton:(BOOL)arg1 {
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
    if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2) {
        if(hideRouteButton) %orig(NO);
        else %orig;
        
        if(hideArtwork) self.showArtworkView = NO;
        else self.showArtworkView = YES;
    }
}
-(BOOL)isUserInteractionEnabled {
    if(disableHeaderViewTouches) {
        return NO;
    }
    return %orig;
}
%end

%hook MRUArtworkView
//I would use the artworkOverrideFrame property of MRUNowPlayingHeaderView, but the frame only applies when using the Large layout
-(void)setFrame:(CGRect)frame {
    CGFloat xvalue = (self.superview.superview.frame.size.width - 298) / 2;
    
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview.superview;
    if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2) {
        if(hasCustomArtworkFrame) {
            %orig(CGRectMake(artworkX, artworkY, artworkWidth, artworkHeight));
            return;
        }
        else if(nowPlayingView.layout == 2) {
            %orig(CGRectMake(xvalue,0,298,298));
            return;
        }
    }
    %orig;
}
%end

%hook MRUNowPlayingVolumeControlsView
-(void)setFrame:(CGRect)frame {
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
    if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2 && hasCustomVolumeBarFrame) {
        %orig(CGRectMake(volumeX, volumeY, volumeWidth, volumeHeight));
    }
    else %orig;
}
%end

%hook MRUNowPlayingTimeControlsView
-(void)setFrame:(CGRect)frame {
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
    if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2 && hasCustomScrubberFrame) {
        %orig(CGRectMake(scrubberX, scrubberY, scrubberWidth, scrubberHeight));
    }
    else %orig;
}
%end

%hook MRUNowPlayingTransportControlsView
-(void)setFrame:(CGRect)frame {
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
    if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2 && hasCustomTransportFrame) {
        %orig(CGRectMake(transportX, transportY, transportWidth, transportHeight));
    }
    else %orig;
}
%end

%hook NCNotificationMasterList
-(NSUInteger)notificationCount {
    NSUInteger retVal = %orig;
    
    if(!switchIfNotifications || dlopen("/Library/MobileSubstrate/DynamicLibraries/Axon.dylib", RTLD_LAZY)) return retVal;
    
    if(!notifications && retVal > 0) {
        notifications = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KumquatStyleChange" object:self];
    }
    else if(notifications && retVal == 0) {
        notifications = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KumquatStyleChange" object:self];
    }
    return retVal;
}
%end

%hook AXNView
-(void)refresh {
    %orig;
    if(!switchIfNotifications) return;
    
    if(!notifications && self.collectionView.visibleCells.count > 0) {
        notifications = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KumquatStyleChange" object:self];
    }
    else if (notifications && self.collectionView.visibleCells.count == 0) {
        notifications = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KumquatStyleChange" object:self];
    }
}
%end

static void loadPrefs() {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist"];
    
    isEnabled = prefs[@"isEnabled"] ? [prefs[@"isEnabled"] boolValue] : YES;
    
    defaultLayout = prefs[@"defaultStyle"] ? [prefs[@"defaultStyle"] intValue] : 0;
    currentLayout = defaultLayout;
    
    layoutForNotifications = prefs[@"layoutForNotifications"] ? [prefs[@"layoutForNotifications"] intValue] : 0;
    switchIfNotifications = prefs[@"switchIfNotifications"] ? [prefs[@"switchIfNotifications"] boolValue] : NO;
    notifications = NO;
    
    hideRouteButton = prefs[@"hideRouteButton"] ? [prefs[@"hideRouteButton"] boolValue] : NO;
    hideArtwork = prefs[@"hideArtwork"] ? [prefs[@"hideArtwork"] boolValue] : NO;
    disableHeaderViewTouches = prefs[@"disableHeaderViewTouches"] ? [prefs[@"disableHeaderViewTouches"] boolValue] : NO;
    
    hasCustomHeaderFrame = prefs[@"hasCustomHeaderFrame"] ? [prefs[@"hasCustomHeaderFrame"] boolValue] : NO;
    headerX = prefs[@"headerX"] ? [prefs[@"headerX"] floatValue] : 0;
    headerY = prefs[@"headerY"] ? [prefs[@"headerY"] floatValue] : 0;
    headerWidth = prefs[@"headerWidth"] ? [prefs[@"headerWidth"] floatValue] : 0;
    headerHeight = prefs[@"headerHeight"] ? [prefs[@"headerHeight"] floatValue] : 0;

    
    hasCustomArtworkFrame = prefs[@"hasCustomArtworkFrame"] ? [prefs[@"hasCustomArtworkFrame"] boolValue] : NO;
    artworkX = prefs[@"artworkX"] ? [prefs[@"artworkX"] floatValue] : 0;
    artworkY = prefs[@"artworkY"] ? [prefs[@"artworkY"] floatValue] : 0;
    artworkWidth = prefs[@"artworkWidth"] ? [prefs[@"artworkWidth"] floatValue] : 0;
    artworkHeight = prefs[@"artworkHeight"] ? [prefs[@"artworkHeight"] floatValue] : 0;

    
    hasCustomPlayerHeight = prefs[@"hasCustomPlayerHeight"] ? [prefs[@"hasCustomPlayerHeight"] boolValue] : NO;
    playerHeight = prefs[@"playerHeight"] ? [prefs[@"playerHeight"] floatValue] : 0;
    
    hasCustomVolumeBarFrame = prefs[@"hasCustomVolumeBarFrame"] ? [prefs[@"hasCustomVolumeBarFrame"] boolValue]: NO;
    volumeX = prefs[@"volumeX"] ? [prefs[@"volumeX"] floatValue] : 0;
    volumeY = prefs[@"volumeY"] ? [prefs[@"volumeY"] floatValue] : 0;
    volumeWidth = prefs[@"volumeWidth"] ? [prefs[@"volumeWidth"] floatValue] : 0;
    volumeHeight = prefs[@"volumeHeight"] ? [prefs[@"volumeHeight"] floatValue] : 0;

    
    hasCustomScrubberFrame = prefs[@"hasCustomScrubberFrame"] ? [prefs [@"hasCustomScrubberFrame"] boolValue]: NO;
    scrubberX = prefs[@"scrubberX"] ? [prefs[@"scrubberX"] floatValue] : 0;
    scrubberY = prefs[@"scrubberY"] ? [prefs[@"scrubberY"] floatValue] : 0;
    scrubberWidth = prefs[@"scrubberWidth"] ? [prefs[@"scrubberWidth"] floatValue] : 0;
    scrubberHeight = prefs[@"scrubberHeight"] ? [prefs[@"scrubberHeight"] floatValue] : 0;
    
    hasCustomTransportFrame = prefs[@"hasCustomTransportFrame"] ? [prefs[@"hasCustomTransportFrame"] boolValue]: NO;
    transportX = prefs[@"transportX"] ? [prefs[@"transportX"] floatValue] : 0;
    transportY = prefs[@"transportY"] ? [prefs[@"transportY"] floatValue] : 0;
    transportWidth = prefs[@"transportWidth"] ? [prefs[@"transportWidth"] floatValue] : 0;
    transportHeight = prefs[@"transportHeight"] ? [prefs[@"transportHeight"] floatValue] : 0;
}

static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadPrefs();
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KumquatStyleChange" object:nil];
}

%ctor {
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)prefsChanged, CFSTR("com.galacticdev.kumquatprefs.changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    if(isEnabled) %init;
}
