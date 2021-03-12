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

@interface KumquatView : UIView
@property (nonatomic, assign) CGRect rectToKeep;
@end

@interface MRUCoverSheetViewController ()
@property (strong, nonatomic) KumquatView *view;
@end

