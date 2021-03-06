#import "Tweak.h"

CSNotificationAdjunctListViewController *adjunctListController;
UIViewController *quickActionsViewController;

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
-(void)setShowSuggestionsView:(BOOL)arg1 {
    %orig(NO);
}
-(void)setContext:(NSInteger)context {
    %orig;
    if(context == 2) {
        self.controlsView.headerView.artworkView.hidden = hideArtwork;
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
                break;
            case 3:
                self.layout = 1;
                self.containerView.showSeparator = NO;
                self.controlsView.showTimeControlsView = NO;
                self.controlsView.volumeControlsView.hidden = NO;
                break;
            case 4:
                self.layout = 1;
                self.containerView.showSeparator = NO;
                self.controlsView.volumeControlsView.hidden = YES;
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
    updatePreset();
    self.controlsView.headerView.artworkView.hidden = hideArtwork;
    self.controlsView.headerView.showRoutingButton = !hideRouteButton;
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
                break;
            }
            case 3:
                self.layout = 1;
                self.containerView.showSeparator = NO;
                self.controlsView.showTimeControlsView = NO;
                self.controlsView.volumeControlsView.hidden = NO;
                break;
            case 4:
                self.layout = 1;
                self.containerView.showSeparator = NO;
                self.controlsView.showTimeControlsView = YES;
                self.controlsView.volumeControlsView.hidden = YES;
                break;
            default:
                self.layout = 4;
                break;
        }
        if(hideQuickActionButtons) {
            quickActionsViewController.view.hidden = YES;
        }
        else {
            quickActionsViewController.view.hidden = NO;
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

%hook CSQuickActionsViewController
-(instancetype)init {
    quickActionsViewController = (UIViewController *)self;
    return %orig;
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
    [(UIView *)[self.view.superview.superview valueForKey:@"_backgroundView"] setAlpha:backgroundAlpha];
}
%end


%hook CSNotificationAdjunctListViewController
-(instancetype)init {
    adjunctListController = self;
    return %orig;
}
%end

NSInteger previousAlignment1;
NSInteger previousAlignment2;
%hook MPUMarqueeView
-(void)setFrame:(CGRect)frame {
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview.superview.superview;
    if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2) {
        
        /*This is a really weird way to get this to work but it does work. The reason there are 2 previous alignment variables is because there are two MPUMarqueeView's. So when the first marquee view's frame is set it goes through the first if statement, and then when the second marquee view's frame is set it goes through the second one. This is really dumb but whatever.
         */
        if(previousAlignment1 != headerTextAlignment) {
            UIView *superview = self.superview;
            [self removeFromSuperview];
            [superview addSubview:self];
            previousAlignment1 = headerTextAlignment;
        }
        else if(previousAlignment2 != headerTextAlignment) {
            UIView *superview = self.superview;
            [self removeFromSuperview];
            [superview addSubview:self];
            previousAlignment2 = headerTextAlignment;
        }

        switch (headerTextAlignment) {
            case 0: { //left
                self.translatesAutoresizingMaskIntoConstraints = NO;
                [self.leadingAnchor constraintEqualToAnchor:self.superview.leadingAnchor].active = YES;

                %orig(CGRectMake(self.frame.origin.x, frame.origin.y, self.frame.size.width, self.frame.size.height));
                break;
            }
            case 1: { //center
                self.translatesAutoresizingMaskIntoConstraints = NO;
                [self.centerXAnchor constraintEqualToAnchor:self.superview.centerXAnchor].active = YES;

                %orig(CGRectMake(self.frame.origin.x, frame.origin.y, self.frame.size.width, self.frame.size.height));
                break;
            }
            case 2: { //right
                self.translatesAutoresizingMaskIntoConstraints = NO;
                [self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor].active = YES;

                %orig(CGRectMake(self.frame.origin.x, frame.origin.y, self.frame.size.width, self.frame.size.height));
                break;
            }
            default: {
                %orig;
                break;
            }
        }
    }
    else {
        %orig;
    }
}
%end

%hook MRUNowPlayingHeaderView
-(void)setFrame:(CGRect)frame {
        MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
        if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2) {
            if(hideRouteButton) self.showRoutingButton = NO;
            else self.showRoutingButton = YES;
            
            if(hideArtwork) self.showArtworkView = NO;
            else self.showArtworkView = YES;
            
            self.labelView.routeLabel.hidden = hideRouteLabel;
            
            if(hasCustomHeaderFrame) {
                NSArray *rect = @[@(headerX), @(headerY), @(headerWidth), @(headerHeight)];
                NSArray *originalRect = @[@(frame.origin.x), @(frame.origin.y), @(frame.size.width), @(frame.size.height)];
                %orig(rectWithValues(rect, originalRect, headerFrameOption));
                return;
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
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
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
        if(backgroundAlpha < 1) {
            self.artworkShadowView.hidden = YES;
        }
    }
    %orig(newFrame);
}
-(void)setArtworkImage:(id)arg1 {
    %orig;
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview.superview;
    if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2) {
        if(hideIconView) {
            self.iconShadowView.hidden = YES;
            self.iconView.hidden = YES;
        }
        if(customArtworkCornerRadius != -1) {
            self.artworkImageView.layer.cornerRadius = customArtworkCornerRadius;
            self.artworkShadowView.hidden = YES; //easier than dealing w/ changing its corner radius bc for some reason that glitched super hard;
        }
    }
}
%end

%hook MRUNowPlayingVolumeControlsView
-(void)setFrame:(CGRect)frame {
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
    if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2) {
        _UISliderVisualElement *visualElement = [self.slider valueForKey:@"_visualElement"];
        UIImageView *minView = [visualElement valueForKey:@"_minValueImageView"];
        UIImageView *maxView = [visualElement valueForKey:@"_maxValueImageView"];
        minView.hidden = removeSpeakerIcons;
        maxView.hidden = removeSpeakerIcons;
                
        if(hasCustomVolumeBarFrame) {
            NSArray *rect = @[@(volumeX), @(volumeY), @(volumeWidth), @(volumeHeight)];
            NSArray *originalRect = @[@(frame.origin.x), @(frame.origin.y), @(frame.size.width), @(frame.size.height)];
            %orig(rectWithValues(rect, originalRect, volumeFrameOption));
            return;
        }
    }
    %orig;
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
    if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2) {
        if(hasCustomTransportFrame) {
            NSArray *rect = @[@(transportX), @(transportY), @(transportWidth), @(transportHeight)];
            NSArray *originalRect = @[@(frame.origin.x), @(frame.origin.y), @(frame.size.width), @(frame.size.height)];
            %orig(rectWithValues(rect, originalRect, transportFrameOption));
            return;
        }
    }
    %orig;
}
%end

%hook MRUNowPlayingControlsView
-(void)setFrame:(CGRect)frame {
    %orig;
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview;
    if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2) {
        if(hideVolumeBar) {
            self.volumeControlsView.hidden = YES;
        }
        if(hideScrubber) {
            self.showTimeControlsView = NO;
        }
    }
}
%end

//makes marquee views actually scroll. idk which ios versions the scrolling doesn't work on but i've seen in on 14.2-14.3
%hook MPUMarqueeView
-(void)setContentGap:(CGFloat)arg1 {
    %orig(0);
}
-(void)setViewForContentSize:(UILabel *)view {
    %orig;
    [view setMarqueeEnabled:YES];
    [view setMarqueeRunning:YES];
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
