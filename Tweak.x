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
%hook MRUNowPlayingView
-(void)setContext:(NSInteger)context {
    %orig;
    RLog(@"self.context %d", context);
    if(context == 2) {
        RLog(@" WHAT THE FUCKING FUCKITY FUCK");
        self.layout = 2;
	self.containerView.showSeparator = NO;
        return;
    }
    %orig; 
}
%end 

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

%hook CSAdjunctItemView
-(CGSize)intrinsicContentSize{
    UIView *embeddingView = [(MRUCoverSheetViewController *)[self.contentHost valueForKey:@"_platterViewController"] nowPlayingViewController].view.collapsedEmbeddingView;
    NSLog(@"[KMQT embeddingView %@", embeddingView);
    CGSize oldSize = %orig;
    CGSize newSize = CGSizeMake(oldSize.width, oldSize.height - embeddingView.frame.size.height);
    //return newSize;
    return CGSizeMake(oldSize.width, oldSize.height + 255);
}
%end

%hook MRUNowPlayingHeaderView
-(void)setArtworkOverrideFrame:(CGRect)arg1 {
    MRUNowPlayingView *nowPlayingView = (MRUNowPlayingView *)self.superview.superview;
    CGFloat xvalue = (self.frame.size.width - 255) / 2;
    if(nowPlayingView.context == 2) %orig(CGRectMake(xvalue,0,255,255));
    else %orig;
}
-(void)setUseArtworkOverrideFrame:(BOOL)arg1 {
    MRUNowPlayingView *nowPlayingView = self.superview.superview;
    RLog(@"NOW PLAYING VIEW %@", nowPlayingView);
    RLog(@"NOW PLAYING SUPERVIEW %@", nowPlayingView.superview.superview);
    RLog(@"NOW PALYING SSPOIDJFPS %@", nowPlayingView.superview);
    if(nowPlayingView.context == 2) {
       %orig(YES);
    }
    else %orig;
}
-(void)setFrame:(CGRect)frame {
    %orig(CGRectMake(0,0,frame.size.width, frame.size.height + 255 + 10));
}
%end 

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
%hook MRUCoverSheetViewController
-(void)setView:(UIView *)arg1 {
    KumquatView *view = [[KumquatView alloc] initWithFrame:CGRectZero];
    %orig(view);
}
-(void)viewDidAppear:(BOOL)arg1 {
    %orig;
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
%end 
