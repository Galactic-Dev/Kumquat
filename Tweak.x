#import "Tweak.h"


CSNotificationAdjunctListViewController *adjunctListController;

BOOL notifications = NO;

//Preference Values
NSInteger currentLayout;
NSInteger defaultLayout;
NSInteger layoutForNotifications;
BOOL switchIfNotifications;
CGFloat artworkHeight;

%group Main
%hook MRUNowPlayingView
-(void)setContext:(NSInteger)context {
    %orig;
    RLog(@"self.context %d", context);
    if(context == 2) {
        RLog(@"currentLayout %d", currentLayout);
        if(currentLayout == 1) {
            self.layout = 2;
        }
        else if(currentLayout == 2) {
            self.layout = 1;
            self.containerView.showSeparator = NO;
        }
        return;
    }
    %orig; 
}
-(instancetype)initWithFrame:(CGRect)frame {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kumquatNotificationsChanged) name:@"KumquatNotificationsChanged" object:nil];
    return %orig;
}
-(void)dealloc {
    %orig;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KumquatNotificationsChanged" object:nil];
}
%new
-(void)kumquatNotificationsChanged {
    RLog(@"CALLED");
    if(notifications) {
        currentLayout = layoutForNotifications;
        RLog(@"LAYOUT %d", currentLayout);
    }
    else {
        currentLayout = defaultLayout;
        RLog(@"LAYOUT :fr: %d", currentLayout);
    }
    if(self.context == 2) {
        RLog(@"currentLayout %d", currentLayout);
        switch(currentLayout) {
            case 0:
                self.layout = 4;
                break;
            case 1: {
                self.layout = 2;
                break;
            }
            case 2: {
                self.layout = 1;
                self.containerView.showSeparator = NO;
                break;
            }
            case 3:
                self.layout = 1;
                self.containerView.showSeparator = NO;
                break;
            case 4:
                self.layout = 1;
                self.containerView.showSeparator = NO;
                break;
            default:
                self.layout = 4;
                break;
        }
        id nowPlayingItem = [adjunctListController.identifiersToItems objectForKey:@"SBDashBoardNowPlayingAssertionIdentifier"];
        if(nowPlayingItem) {
            [adjunctListController _insertItem:nowPlayingItem animated:NO];
            RLog(@"firstObject %@", adjunctListController.stackView.arrangedSubviews.firstObject);
            [adjunctListController.stackView.arrangedSubviews.firstObject removeFromSuperview];
            [adjunctListController.view _layoutStackView];
        }
    }
}
%end

%hook CSMediaControlsViewController
-(instancetype)init {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_layoutMediaControls) name:@"KumquatNotificationsChanged" object:nil];
    return %orig;
}
-(void)dealloc {
    %orig;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"KumquatNotificationsChanged" object:nil];
}
-(CGRect)_suggestedFrameForMediaControls {
    CGRect oldSize = %orig;
    if(currentLayout == 2) {
        return CGRectMake(0, 0, oldSize.size.width, oldSize.size.height - 44);
    }
    else if (currentLayout == 1) {
        return CGRectMake(0, 0, oldSize.size.width, oldSize.size.height + artworkHeight);
    }
    return oldSize;
}
%end


%hook CSNotificationAdjunctListViewController
-(instancetype)init {
    adjunctListController = self;
    return %orig;
}
%end

%hook MRUNowPlayingHeaderView
-(void)setArtworkOverrideFrame:(CGRect)arg1 {
    if(currentLayout == 1) {
        MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
        CGFloat xvalue = (self.frame.size.width - artworkHeight) / 2;
        if(nowPlayingView.context == 2) %orig(CGRectMake(xvalue,0,artworkHeight,artworkHeight));
    }
    else %orig;
}
-(void)setUseArtworkOverrideFrame:(BOOL)arg1 {
    if(currentLayout == 1) {
        MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
        if(nowPlayingView.context == 2) {
           %orig(YES);
        }
    }
    else %orig;
}
-(void)setFrame:(CGRect)frame {
    if(currentLayout == 1) {
        MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
        if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2) %orig(CGRectMake(0,0,frame.size.width, frame.size.height + artworkHeight + 10 /*just some extra padding between song title & album cover*/));
    }
    else %orig;
}
%end

@implementation KumquatView
-(void)setFrame:(CGRect)frame {
    [super setFrame:self.rectToKeep];
}
@end

%hook MRUCoverSheetViewController
-(void)setView:(UIView *)arg1 {
    KumquatView *view = [[KumquatView alloc] initWithFrame:arg1.frame];
    %orig(view);
}
-(void)viewDidAppear:(BOOL)arg1 {
    %orig;
    UIView *viewThing = self.parentViewController.view.superview;
    self.view.rectToKeep = viewThing.frame;
    self.view.frame = CGRectZero;
}
%end
%end

%group Notifications
%hook NCNotificationMasterList
-(NSUInteger)notificationCount {
    NSUInteger retVal = %orig;
    if(!notifications && retVal > 0) {
        RLog(@"RET VAL %llu", retVal);
        notifications = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KumquatNotificationsChanged" object:self];
    }
    else if(notifications && retVal == 0) {
        RLog(@"RET VAL %llu", retVal);
        notifications = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KumquatNotificationsChanged" object:self];
    }
    return retVal;
}
%end
%end

%group Axon
%hook AXNView
-(void)refresh {
    RLog(@"REFERSHING");
    %orig;
    if(!notifications && self.collectionView.visibleCells.count > 0) {
        RLog(@"CONDESNEDS");
        notifications = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KumquatNotificationsChanged" object:self];
    }
    else if (notifications && self.collectionView.visibleCells.count == 0) {
        RLog(@"DSEXEPANDEDE");
        notifications = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KumquatNotificationsChanged" object:self];
    }
}
%end
%end

static void loadPrefs() {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist"];
    defaultLayout = [prefs objectForKey:@"defaultStyle"] ? [[prefs objectForKey:@"defaultStyle"] intValue] : 0;
    RLog(@"defaults layouts %d", defaultLayout);
    currentLayout = defaultLayout;
    RLog(@"LAYOUT BITCH %d", currentLayout);
    layoutForNotifications = [prefs objectForKey:@"layoutForNotifications"] ? [[prefs objectForKey:@"layoutForNotifications"] intValue] : 0;
    RLog(@"layoutfornotifs %d", layoutForNotifications);
    switchIfNotifications = [prefs objectForKey:@"switchIfNotficiations"] ? [[prefs objectForKey:@"switchIfNotficiations"] boolValue] : FALSE;
    artworkHeight = [prefs objectForKey:@"artworkHeight"] ? [[prefs objectForKey:@"artworkHeight"] floatValue] : 255;
}

%ctor {
    loadPrefs();
    if(switchIfNotifications) {
        if(dlopen("/Library/MobileSubstrate/DynamicLibraries/Axon.dylib", RTLD_LAZY)) {
            RLog(@"AXON AXON AXON ");
            %init(Axon);
        }
        else %init(Notifications);
    }
    %init(Main);
}
