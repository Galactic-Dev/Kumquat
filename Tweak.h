#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <RemoteLog.h>
#import <dlfcn.h>

//Preference Values
BOOL isEnabled;

NSInteger defaultLayout;
NSInteger layoutForNotifications;
BOOL switchIfNotifications;

BOOL hideRouteButton;
BOOL hideArtwork;
BOOL hideIconView;
BOOL hideVolumeBar;
BOOL hideScrubber;
BOOL disableHeaderViewTouches;
BOOL disableHeaderViewTouchesArtwork;
BOOL disableHeaderViewTouchesText;
BOOL removeBackground;
CGFloat customCornerRadius;

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

@interface MRUArtworkView : UIView
@property (strong, nonatomic) UIView *iconView;
@property (strong, nonatomic) UIView *iconShadowView;
@end

@interface MRUNowPlayingVolumeControlsView : UIView
@end

@interface MRUNowPlayingTimeControlsView : UIView
@end

@interface MRUNowPlayingTransportControlsView : UIView
@end

@interface MRUNowPlayingHeaderView : UIView
@property (strong, nonatomic) MRUArtworkView *artworkView;
@property (strong, nonatomic) UIView *labelView;
@property (nonatomic, assign) BOOL showArtworkView;
@end

@interface MRUNowPlayingControlsView : UIView
@property (strong, nonatomic) MRUNowPlayingHeaderView *headerView;
@property (strong, nonatomic) UIView *volumeControlsView;
@property (nonatomic, assign) BOOL showTimeControlsView;
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
