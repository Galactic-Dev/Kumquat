#line 1 "Tweak.x"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <RemoteLog.h>

@interface MRUNowPlayingHeaderView : UIView 
@property (nonatomic, assign) CGRect artworkOverrideFrame;
@property (nonatomic, assign) BOOL useArtworkOverrideFrame;
@property (strong, nonatomic) UIView *labelView;
@property (strong, nonatomic) UIView *artworkView;
@end 

@interface MRUNowPlayingControlsView : UIView 
@property (strong, nonatomic) MRUNowPlayingHeaderView *headerView;
@end 


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class CSAdjunctItemView; @class MRUCoverSheetViewController; @class MRUNowPlayingHeaderView; @class MRUNowPlayingView; 
static void (*_logos_orig$_ungrouped$MRUNowPlayingView$setContext$)(_LOGOS_SELF_TYPE_NORMAL MRUNowPlayingView* _LOGOS_SELF_CONST, SEL, NSInteger); static void _logos_method$_ungrouped$MRUNowPlayingView$setContext$(_LOGOS_SELF_TYPE_NORMAL MRUNowPlayingView* _LOGOS_SELF_CONST, SEL, NSInteger); static CGSize (*_logos_orig$_ungrouped$CSAdjunctItemView$intrinsicContentSize)(_LOGOS_SELF_TYPE_NORMAL CSAdjunctItemView* _LOGOS_SELF_CONST, SEL); static CGSize _logos_method$_ungrouped$CSAdjunctItemView$intrinsicContentSize(_LOGOS_SELF_TYPE_NORMAL CSAdjunctItemView* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$MRUNowPlayingHeaderView$setArtworkOverrideFrame$)(_LOGOS_SELF_TYPE_NORMAL MRUNowPlayingHeaderView* _LOGOS_SELF_CONST, SEL, CGRect); static void _logos_method$_ungrouped$MRUNowPlayingHeaderView$setArtworkOverrideFrame$(_LOGOS_SELF_TYPE_NORMAL MRUNowPlayingHeaderView* _LOGOS_SELF_CONST, SEL, CGRect); static void (*_logos_orig$_ungrouped$MRUNowPlayingHeaderView$setUseArtworkOverrideFrame$)(_LOGOS_SELF_TYPE_NORMAL MRUNowPlayingHeaderView* _LOGOS_SELF_CONST, SEL, BOOL); static void _logos_method$_ungrouped$MRUNowPlayingHeaderView$setUseArtworkOverrideFrame$(_LOGOS_SELF_TYPE_NORMAL MRUNowPlayingHeaderView* _LOGOS_SELF_CONST, SEL, BOOL); static void (*_logos_orig$_ungrouped$MRUNowPlayingHeaderView$setFrame$)(_LOGOS_SELF_TYPE_NORMAL MRUNowPlayingHeaderView* _LOGOS_SELF_CONST, SEL, CGRect); static void _logos_method$_ungrouped$MRUNowPlayingHeaderView$setFrame$(_LOGOS_SELF_TYPE_NORMAL MRUNowPlayingHeaderView* _LOGOS_SELF_CONST, SEL, CGRect); static void (*_logos_orig$_ungrouped$MRUCoverSheetViewController$setView$)(_LOGOS_SELF_TYPE_NORMAL MRUCoverSheetViewController* _LOGOS_SELF_CONST, SEL, UIView *); static void _logos_method$_ungrouped$MRUCoverSheetViewController$setView$(_LOGOS_SELF_TYPE_NORMAL MRUCoverSheetViewController* _LOGOS_SELF_CONST, SEL, UIView *); static void (*_logos_orig$_ungrouped$MRUCoverSheetViewController$viewDidAppear$)(_LOGOS_SELF_TYPE_NORMAL MRUCoverSheetViewController* _LOGOS_SELF_CONST, SEL, BOOL); static void _logos_method$_ungrouped$MRUCoverSheetViewController$viewDidAppear$(_LOGOS_SELF_TYPE_NORMAL MRUCoverSheetViewController* _LOGOS_SELF_CONST, SEL, BOOL); 

#line 16 "Tweak.x"
@interface MRUNowPlayingContainerView : UIView 
@property (nonatomic, assign) BOOL showSeparator;
@end
@interface MRUNowPlayingView : UIView
@property (nonatomic, assign) BOOL supportsHorizontalLayout;
@property (strong, nonatomic) UIView *collapsedEmbeddingView;
@property (strong, nonatomic) MRUNowPlayingContainerView *containerView;
@property (strong, nonatomic) MRUNowPlayingControlsView *controlsView;
@property (nonatomic, assign) NSInteger context;
@property (nonatomic, assign) NSInteger layout;
@end 

static void _logos_method$_ungrouped$MRUNowPlayingView$setContext$(_LOGOS_SELF_TYPE_NORMAL MRUNowPlayingView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSInteger context) {
    _logos_orig$_ungrouped$MRUNowPlayingView$setContext$(self, _cmd, context);
    RLog(@"self.context %d", context);
    if(context == 2) {
        RLog(@" WHAT THE FUCKING FUCKITY FUCK");
        self.layout = 2;
	self.containerView.showSeparator = NO;
        return;
    }
    _logos_orig$_ungrouped$MRUNowPlayingView$setContext$(self, _cmd, context); 
}
 

@interface CSMediaControlsViewController : UIViewController
@end 

@interface MRUNowPlayingViewController : UIViewController
@property (strong, nonatomic) MRUNowPlayingView *view;
@end 

@interface MRUCoverSheetViewController : UIViewController
@property (strong, nonatomic) MRUNowPlayingViewController *nowPlayingViewController;
@end

@interface CSAdjunctItemView : UIView
-(CGSize)intrinsicContentSize;
@property (strong, nonatomic) CSMediaControlsViewController *contentHost;
@end


static CGSize _logos_method$_ungrouped$CSAdjunctItemView$intrinsicContentSize(_LOGOS_SELF_TYPE_NORMAL CSAdjunctItemView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd){
    UIView *embeddingView = [(MRUCoverSheetViewController *)[self.contentHost valueForKey:@"_platterViewController"] nowPlayingViewController].view.collapsedEmbeddingView;
    NSLog(@"[KMQT embeddingView %@", embeddingView);
    CGSize oldSize = _logos_orig$_ungrouped$CSAdjunctItemView$intrinsicContentSize(self, _cmd);
    CGSize newSize = CGSizeMake(oldSize.width, oldSize.height - embeddingView.frame.size.height);
    
    return CGSizeMake(oldSize.width, oldSize.height + 255);
}



static void _logos_method$_ungrouped$MRUNowPlayingHeaderView$setArtworkOverrideFrame$(_LOGOS_SELF_TYPE_NORMAL MRUNowPlayingHeaderView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, CGRect arg1) {
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
    CGFloat xvalue = (self.frame.size.width - 255) / 2;
    if(nowPlayingView.context == 2) _logos_orig$_ungrouped$MRUNowPlayingHeaderView$setArtworkOverrideFrame$(self, _cmd, CGRectMake(xvalue,0,255,255));
    else _logos_orig$_ungrouped$MRUNowPlayingHeaderView$setArtworkOverrideFrame$(self, _cmd, arg1);
}
static void _logos_method$_ungrouped$MRUNowPlayingHeaderView$setUseArtworkOverrideFrame$(_LOGOS_SELF_TYPE_NORMAL MRUNowPlayingHeaderView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BOOL arg1) {
    MRUNowPlayingView *nowPlayingView = self.superview.superview;
    RLog(@"NOW PLAYING VIEW %@", nowPlayingView);
    RLog(@"NOW PLAYING SUPERVIEW %@", nowPlayingView.superview.superview);
    RLog(@"NOW PALYING SSPOIDJFPS %@", nowPlayingView.superview);
    if(nowPlayingView.context == 2) {
       _logos_orig$_ungrouped$MRUNowPlayingHeaderView$setUseArtworkOverrideFrame$(self, _cmd, YES);
    }
    else _logos_orig$_ungrouped$MRUNowPlayingHeaderView$setUseArtworkOverrideFrame$(self, _cmd, arg1);
}
static void _logos_method$_ungrouped$MRUNowPlayingHeaderView$setFrame$(_LOGOS_SELF_TYPE_NORMAL MRUNowPlayingHeaderView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, CGRect frame) {
    _logos_orig$_ungrouped$MRUNowPlayingHeaderView$setFrame$(self, _cmd, CGRectMake(0,0,frame.size.width, frame.size.height + 255 + 10));
}
 

@interface KumquatView : UIView
@property (nonatomic, assign) CGRect rectToKeep;
@end 

@implementation KumquatView
-(void)setFrame:(CGRect)frame {
    [super setFrame:self.rectToKeep];
}
@end 
@interface MRUCoverSheetViewController ()
@property (strong, nonatomic) KumquatView *view;
@end

static void _logos_method$_ungrouped$MRUCoverSheetViewController$setView$(_LOGOS_SELF_TYPE_NORMAL MRUCoverSheetViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIView * arg1) {
    KumquatView *view = [[KumquatView alloc] initWithFrame:CGRectZero];
    _logos_orig$_ungrouped$MRUCoverSheetViewController$setView$(self, _cmd, view);
}
static void _logos_method$_ungrouped$MRUCoverSheetViewController$viewDidAppear$(_LOGOS_SELF_TYPE_NORMAL MRUCoverSheetViewController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BOOL arg1) {
    _logos_orig$_ungrouped$MRUCoverSheetViewController$viewDidAppear$(self, _cmd, arg1);
    RLog(@"%@", self.parentViewController.view.superview.frame);
    RLog(@"%@", self.parentViewController);
    RLog(@"%@", self.parentViewController.view);
    RLog(@"%@", self.parentViewController.view.superview);
    UIView *viewThing = self.parentViewController.view.superview;
    RLog(@"VIEW THING %@", viewThing);
    RLog(@"VIEW THING FRAME %@", NSStringFromCGRect(viewThing.frame));
    self.view.rectToKeep = viewThing.frame;
    self.view.frame = CGRectZero;
}
 
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$MRUNowPlayingView = objc_getClass("MRUNowPlayingView"); { MSHookMessageEx(_logos_class$_ungrouped$MRUNowPlayingView, @selector(setContext:), (IMP)&_logos_method$_ungrouped$MRUNowPlayingView$setContext$, (IMP*)&_logos_orig$_ungrouped$MRUNowPlayingView$setContext$);}Class _logos_class$_ungrouped$CSAdjunctItemView = objc_getClass("CSAdjunctItemView"); { MSHookMessageEx(_logos_class$_ungrouped$CSAdjunctItemView, @selector(intrinsicContentSize), (IMP)&_logos_method$_ungrouped$CSAdjunctItemView$intrinsicContentSize, (IMP*)&_logos_orig$_ungrouped$CSAdjunctItemView$intrinsicContentSize);}Class _logos_class$_ungrouped$MRUNowPlayingHeaderView = objc_getClass("MRUNowPlayingHeaderView"); { MSHookMessageEx(_logos_class$_ungrouped$MRUNowPlayingHeaderView, @selector(setArtworkOverrideFrame:), (IMP)&_logos_method$_ungrouped$MRUNowPlayingHeaderView$setArtworkOverrideFrame$, (IMP*)&_logos_orig$_ungrouped$MRUNowPlayingHeaderView$setArtworkOverrideFrame$);}{ MSHookMessageEx(_logos_class$_ungrouped$MRUNowPlayingHeaderView, @selector(setUseArtworkOverrideFrame:), (IMP)&_logos_method$_ungrouped$MRUNowPlayingHeaderView$setUseArtworkOverrideFrame$, (IMP*)&_logos_orig$_ungrouped$MRUNowPlayingHeaderView$setUseArtworkOverrideFrame$);}{ MSHookMessageEx(_logos_class$_ungrouped$MRUNowPlayingHeaderView, @selector(setFrame:), (IMP)&_logos_method$_ungrouped$MRUNowPlayingHeaderView$setFrame$, (IMP*)&_logos_orig$_ungrouped$MRUNowPlayingHeaderView$setFrame$);}Class _logos_class$_ungrouped$MRUCoverSheetViewController = objc_getClass("MRUCoverSheetViewController"); { MSHookMessageEx(_logos_class$_ungrouped$MRUCoverSheetViewController, @selector(setView:), (IMP)&_logos_method$_ungrouped$MRUCoverSheetViewController$setView$, (IMP*)&_logos_orig$_ungrouped$MRUCoverSheetViewController$setView$);}{ MSHookMessageEx(_logos_class$_ungrouped$MRUCoverSheetViewController, @selector(viewDidAppear:), (IMP)&_logos_method$_ungrouped$MRUCoverSheetViewController$viewDidAppear$, (IMP*)&_logos_orig$_ungrouped$MRUCoverSheetViewController$viewDidAppear$);}} }
#line 120 "Tweak.x"
