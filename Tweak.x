#import "Tweak.h"

//Preference Values
NSInteger defaultLayout;
NSInteger layoutForNotifications;
BOOL switchIfNotifications;

%hook MRUNowPlayingView
-(void)setContext:(NSInteger)context {
    %orig;
    RLog(@"self.context %d", context);
    if(context == 2) {
        if(defaultLayout == 1) {
            self.layout = 2;
        }
        else if(defaultLayout == 2) {
            self.layout = 1;
            self.containerView.showSeparator = NO;
        }
        return;
    }
    %orig; 
}
%end

%hook CSAdjunctItemView
-(CGSize)intrinsicContentSize {
    CGSize oldSize = %orig;
    if(defaultLayout == 2) {
        UIView *embeddingView = [(MRUCoverSheetViewController *)[self.contentHost valueForKey:@"_platterViewController"] nowPlayingViewController].view.collapsedEmbeddingView;
        CGSize newSize = CGSizeMake(oldSize.width, oldSize.height - embeddingView.frame.size.height - 100 /*removes extra padding at bottom of player*/);
        return newSize;
    }
    else if (defaultLayout == 1) {
        return CGSizeMake(oldSize.width, oldSize.height + 255);
    }
    return oldSize;
}
%end

%hook MRUNowPlayingHeaderView
-(void)setArtworkOverrideFrame:(CGRect)arg1 {
    if(defaultLayout == 1) {
        MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
        CGFloat xvalue = (self.frame.size.width - 255) / 2;
        if(nowPlayingView.context == 2) %orig(CGRectMake(xvalue,0,255,255));
    }
    else %orig;
}
-(void)setUseArtworkOverrideFrame:(BOOL)arg1 {
    if(defaultLayout == 1) {
        MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
        if(nowPlayingView.context == 2) {
           %orig(YES);
        }
    }
    else %orig;
}
-(void)setFrame:(CGRect)frame {
    if(defaultLayout == 1) {
        MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
        if([nowPlayingView isKindOfClass:%c(MRUNowPlayingView)] && nowPlayingView.context == 2) %orig(CGRectMake(0,0,frame.size.width, frame.size.height + 255 + 10 /*just some extra padding between song title & album cover*/));
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

static void loadPrefs() {
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/com.galacticdev.kumquatprefs.plist"];
    defaultLayout = [prefs objectForKey:@"defaultStyle"] ? [[prefs objectForKey:@"defaultStyle"] intValue] : 0;
    layoutForNotifications = [prefs objectForKey:@"layoutForNotifications"] ? [[prefs objectForKey:@"layoutForNotifications"] intValue] : 0;
    switchIfNotifications = [prefs objectForKey:@"layoutForNotifications"] ? [[prefs objectForKey:@"layoutForNotifications"] boolValue] : FALSE;
}

%ctor {
    loadPrefs();
}
