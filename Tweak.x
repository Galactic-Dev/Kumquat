#import "Tweak.h"

CSNotificationAdjunctListViewController *adjunctListController;
BOOL notifications = NO;
NSInteger currentLayout;

static CGRect rectWithValues(NSArray *values, NSArray *originalValues, NSInteger frameOption) {
    NSMutableArray *mutableValues = values.mutableCopy;
    for(int i = 0; i < values.count; i++) {
        NSNumber *value = values[i];
        if([value intValue] == -1) {
            [mutableValues replaceObjectAtIndex:i withObject:originalValues[i]];
        }
        if(frameOption == 1 /*relative option*/) {
            CGFloat originalValue = [originalValues[i] floatValue];
            CGFloat valueToAdd = [values[i] floatValue];
            [mutableValues replaceObjectAtIndex:i withObject:@(originalValue + valueToAdd)];
        }
    }
    values = mutableValues.copy;
    return CGRectMake([values[0] floatValue], [values[1] floatValue], [values[2] floatValue], [values[3] floatValue]);
}

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
-(CGRect)_suggestedFrameForMediaControls {
    CGRect oldRect = %orig;
    UIViewController *platterViewController = [self valueForKey:@"_platterViewController"];
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)platterViewController.childViewControllers[0].view;
    nowPlayingView.contentEdgeInsets = UIEdgeInsetsMake(16,16,16,16);
    if (hasCustomPlayerFrame) {
        NSArray *rect = @[@(playerX), @(playerY), @(playerWidth), @(playerHeight)];
        NSArray *originalRect;
        switch (currentLayout) {
            case 0: {
                originalRect = @[@(oldRect.origin.x), @(oldRect.origin.y), @(oldRect.size.width), @(oldRect.size.height)];
                break;
            }
            case 1: {
                originalRect = @[@(oldRect.origin.x + 24), @(oldRect.origin.y), @(oldRect.size.width - 48), @(oldRect.size.height + 298)];
                break;
            }
            case 2: {
                originalRect = @[@(oldRect.origin.x), @(oldRect.origin.y), @(oldRect.size.width), @(oldRect.size.height - 44)];
                break;
            }
            case 3: {
                originalRect = @[@(oldRect.origin.x), @(oldRect.origin.y), @(oldRect.size.width ), @(oldRect.size.height - 44 - 44)];
                break;
            }
            case 4: {
                originalRect = @[@(oldRect.origin.x), @(oldRect.origin.y), @(oldRect.size.width ), @(oldRect.size.height - 44 - 44)];
                break;
            }
        }
        CGRect newRect = rectWithValues(rect, originalRect, playerFrameOption);
        self.view.superview.superview.frame = newRect;
        return CGRectMake(0, 0, newRect.size.width, newRect.size.height);
    }
    switch (currentLayout) {
        case 0:
            return oldRect;
        case 1: {
            self.view.superview.superview.frame = CGRectMake(24, 0, oldRect.size.width - 48, oldRect.size.height + 298);
            return CGRectMake(0, 0, oldRect.size.width - 48, oldRect.size.height + 298);
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

//temporary fix just testing trying to get stuff to work with other media player tweaks
-(void)viewDidLayoutSubviews {
    %orig;
    UIViewController *platterViewController = [self valueForKey:@"_platterViewController"];
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)platterViewController.childViewControllers[0].view;
    switch (currentLayout) {
        case 1: {
            [(UIView *)[self.view.superview.superview valueForKey:@"_backgroundView"] layer].cornerRadius = 42;
            nowPlayingView.contentEdgeInsets = UIEdgeInsetsMake(24,24,24,24);
        }
    }
    if(customCornerRadius != -1) {
        [(UIView *)[self.view.superview.superview valueForKey:@"_backgroundView"] layer].cornerRadius = customCornerRadius;
    }
    if(removeBackground) {
        [(UIView *)[self.view.superview.superview valueForKey:@"_backgroundView"] setHidden:YES];
    }
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
                NSArray *rect = @[@(headerX), @(headerY), @(headerWidth), @(headerHeight)];
                NSArray *originalRect = @[@(frame.origin.x), @(frame.origin.y), @(frame.size.width), @(frame.size.height)];
                %orig(rectWithValues(rect, originalRect, headerFrameOption));
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
    else {
        %orig;
    }
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if(disableHeaderViewTouches) {
        CGPoint artworkPoint = [self convertPoint:point toView:self.artworkView];
        CGPoint textPoint = [self convertPoint:point toView:self.labelView];
        
        if(disableHeaderViewTouchesArtwork && CGRectContainsPoint(self.artworkView.bounds, artworkPoint)) {
            return nil;
        }
        if(disableHeaderViewTouchesText && CGRectContainsPoint(self.labelView.bounds, textPoint)) {
            return nil;
        }
    }
    return %orig;
}
%end

%hook MRUArtworkView
//I would use the artworkOverrideFrame property of MRUNowPlayingHeaderView, but the frame only applies when using the Large layout
-(void)setFrame:(CGRect)frame {
    CGRect newFrame = frame;
    CGFloat xvalue = (self.superview.superview.frame.size.width - 298) / 2;
    
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview.superview;
    if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2) {
        if(hasCustomArtworkFrame) {
            NSArray *rect = @[@(artworkX), @(artworkY), @(artworkWidth), @(artworkHeight)];
            NSArray *originalRect = @[@(frame.origin.x), @(frame.origin.y), @(frame.size.width), @(frame.size.height)];
            newFrame = rectWithValues(rect, originalRect, artworkFrameOption);
        }
        else if(nowPlayingView.layout == 2) {
            newFrame = CGRectMake(xvalue,0,298,298);
        }
        if(hasCustomHeaderFrame) {
            newFrame = CGRectMake(newFrame.origin.x - headerX, newFrame.origin.y - headerY, newFrame.size.width, newFrame.size.height);
        }
        if(hideIconView) {
            self.iconShadowView.hidden = YES;
            self.iconView.hidden = YES;
        }
    }
    %orig(newFrame);
}
%end

%hook MRUNowPlayingVolumeControlsView
-(void)setFrame:(CGRect)frame {
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
    if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2 && hasCustomVolumeBarFrame) {
        NSArray *rect = @[@(volumeX), @(volumeY), @(volumeWidth), @(volumeHeight)];
        NSArray *originalRect = @[@(frame.origin.x), @(frame.origin.y), @(frame.size.width), @(frame.size.height)];
        %orig(rectWithValues(rect, originalRect, volumeFrameOption));
    }
    else %orig;
}
%end

%hook MRUNowPlayingTimeControlsView
-(void)setFrame:(CGRect)frame {
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
    if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2 && hasCustomScrubberFrame) {
        NSArray *rect = @[@(scrubberX), @(scrubberY), @(scrubberWidth), @(scrubberHeight)];
        NSArray *originalRect = @[@(frame.origin.x), @(frame.origin.y), @(frame.size.width), @(frame.size.height)];
        %orig(rectWithValues(rect, originalRect, scrubberFrameOption));
    }
    else %orig;
}
%end

%hook MRUNowPlayingTransportControlsView
-(void)setFrame:(CGRect)frame {
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
    if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2 && hasCustomTransportFrame) {
        NSArray *rect = @[@(transportX), @(transportY), @(transportWidth), @(transportHeight)];
        NSArray *originalRect = @[@(frame.origin.x), @(frame.origin.y), @(frame.size.width), @(frame.size.height)];
        %orig(rectWithValues(rect, originalRect, transportFrameOption));
    }
    else %orig;
}
%end

%hook MRUNowPlayingControlsView
-(void)setFrame:(CGRect)frame {
    %orig;
    if(hideVolumeBar) {
        self.volumeControlsView.hidden = YES;
    }
    if(hideScrubber) {
        self.showTimeControlsView = NO;
    }
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
    hideIconView = prefs[@"hideIconView"] ? [prefs[@"hideIconView"] boolValue] : NO;
    hideVolumeBar = prefs[@"hideVolumeBar"] ? [prefs[@"hideVolumeBar"] boolValue] : NO;
    hideScrubber = prefs[@"hideScrubber"] ? [prefs[@"hideScrubber"] boolValue] : NO;
    disableHeaderViewTouches = prefs[@"disableHeaderViewTouches"] ? [prefs[@"disableHeaderViewTouches"] boolValue] : NO;
    disableHeaderViewTouchesArtwork = prefs[@"disableHeaderViewTouchesArtwork"] ? [prefs[@"disableHeaderViewTouchesArtwork"] boolValue] : YES;
    disableHeaderViewTouchesText = prefs[@"disableHeaderViewTouchesText"] ? [prefs[@"disableHeaderViewTouchesText"] boolValue] : YES;

    removeBackground = prefs[@"removeBackground"] ? [prefs[@"removeBackground"] boolValue] : NO;
    customCornerRadius = prefs[@"customCornerRadius"] && ![prefs[@"customCornerRadius"] isEqualToString:@""]? [prefs[@"customCornerRadius"] floatValue] : -1;
    
    hasCustomHeaderFrame = prefs[@"hasCustomHeaderFrame"] ? [prefs[@"hasCustomHeaderFrame"] boolValue] : NO;
    headerFrameOption = prefs[@"headerFrameOption"] ? [prefs[@"headerFrameOption"] intValue] : 0;
    headerX = prefs[@"headerX"] ? [prefs[@"headerX"] floatValue] : 0;
    headerY = prefs[@"headerY"] ? [prefs[@"headerY"] floatValue] : 0;
    headerWidth = prefs[@"headerWidth"] ? [prefs[@"headerWidth"] floatValue] : 0;
    headerHeight = prefs[@"headerHeight"] ? [prefs[@"headerHeight"] floatValue] : 0;

    
    hasCustomArtworkFrame = prefs[@"hasCustomArtworkFrame"] ? [prefs[@"hasCustomArtworkFrame"] boolValue] : NO;
    artworkFrameOption = prefs[@"artworkFrameOption"] ? [prefs[@"artworkFrameOption"] intValue] : 0;
    artworkX = prefs[@"artworkX"] ? [prefs[@"artworkX"] floatValue] : 0;
    artworkY = prefs[@"artworkY"] ? [prefs[@"artworkY"] floatValue] : 0;
    artworkWidth = prefs[@"artworkWidth"] ? [prefs[@"artworkWidth"] floatValue] : 0;
    artworkHeight = prefs[@"artworkHeight"] ? [prefs[@"artworkHeight"] floatValue] : 0;

    
    hasCustomPlayerFrame = prefs[@"hasCustomPlayerFrame"] ? [prefs[@"hasCustomPlayerFrame"] boolValue] : NO;
    playerFrameOption = prefs[@"playerFrameOption"] ? [prefs[@"playerFrameOption"] intValue] : 0;
    playerX = prefs[@"playerX"] ? [prefs[@"playerX"] floatValue] : 0;
    playerY = prefs[@"playerY"] ? [prefs[@"playerY"] floatValue] : 0;
    playerWidth = prefs[@"playerWidth"] ? [prefs[@"playerWidth"] floatValue] : 0;
    playerHeight = prefs[@"playerHeight"] ? [prefs[@"playerHeight"] floatValue] : 0;
    
    hasCustomVolumeBarFrame = prefs[@"hasCustomVolumeBarFrame"] ? [prefs[@"hasCustomVolumeBarFrame"] boolValue]: NO;
    volumeFrameOption = prefs[@"volumeFrameOption"] ? [prefs[@"volumeFrameOption"] intValue] : 0;
    volumeX = prefs[@"volumeX"] ? [prefs[@"volumeX"] floatValue] : 0;
    volumeY = prefs[@"volumeY"] ? [prefs[@"volumeY"] floatValue] : 0;
    volumeWidth = prefs[@"volumeWidth"] ? [prefs[@"volumeWidth"] floatValue] : 0;
    volumeHeight = prefs[@"volumeHeight"] ? [prefs[@"volumeHeight"] floatValue] : 44;

    
    hasCustomScrubberFrame = prefs[@"hasCustomScrubberFrame"] ? [prefs [@"hasCustomScrubberFrame"] boolValue]: NO;
    scrubberFrameOption = prefs[@"scrubberFrameOption"] ? [prefs[@"scrubberFrameOption"] intValue] : 0;
    scrubberX = prefs[@"scrubberX"] ? [prefs[@"scrubberX"] floatValue] : 0;
    scrubberY = prefs[@"scrubberY"] ? [prefs[@"scrubberY"] floatValue] : 0;
    scrubberWidth = prefs[@"scrubberWidth"] ? [prefs[@"scrubberWidth"] floatValue] : 0;
    scrubberHeight = prefs[@"scrubberHeight"] ? [prefs[@"scrubberHeight"] floatValue] : 44;
    
    hasCustomTransportFrame = prefs[@"hasCustomTransportFrame"] ? [prefs[@"hasCustomTransportFrame"] boolValue]: NO;
    transportFrameOption = prefs[@"transportFrameOption"] ? [prefs[@"transportFrameOption"] intValue] : 0;
    transportX = prefs[@"transportX"] ? [prefs[@"transportX"] floatValue] : 0;
    transportY = prefs[@"transportY"] ? [prefs[@"transportY"] floatValue] : 0;
    transportWidth = prefs[@"transportWidth"] ? [prefs[@"transportWidth"] floatValue] : 0;
    transportHeight = prefs[@"transportHeight"] ? [prefs[@"transportHeight"] floatValue] : 44;
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

%dtor {
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, CFSTR("com.galacticdev.kumquatprefs.changed"), NULL);
}
