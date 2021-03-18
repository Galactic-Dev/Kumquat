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

BOOL hasCustomHeaderFrame;
CGFloat headerX;
CGFloat headerY;
CGFloat headerWidth;
CGFloat headerHeight;

BOOL hasCustomArtworkFrame;
CGFloat artworkX;
CGFloat artworkY;
CGFloat artworkWidth;
CGFloat artworkHeight;

BOOL hasCustomPlayerHeight;
CGFloat playerHeight;

BOOL hasCustomVolumeBarFrame;
CGFloat volumeX;
CGFloat volumeY;
CGFloat volumeWidth;
CGFloat volumeHeight;

BOOL hasCustomScrubberFrame;
CGFloat scrubberX;
CGFloat scrubberY;
CGFloat scrubberWidth;
CGFloat scrubberHeight;

BOOL hasCustomTransportFrame;
CGFloat transportX;
CGFloat transportY;
CGFloat transportWidth;
CGFloat transportHeight;

@interface MRUArtworkView : UIView
@end

@interface MRUNowPlayingVolumeControlsView : UIView
@end

@interface MRUNowPlayingTimeControlsView : UIView
@end

@interface MRUNowPlayingTransportControlsView : UIView
@end

@interface MRUNowPlayingHeaderView : UIView
@property (nonatomic, assign) CGRect artworkOverrideFrame;
@property (nonatomic, assign) BOOL useArtworkOverrideFrame;
@property (strong, nonatomic) UIView *labelView;
@property (strong, nonatomic) MRUArtworkView *artworkView;
@property (nonatomic, assign) NSInteger layout;
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
@property (nonatomic, assign) BOOL supportsHorizontalLayout;
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

//Notification stuff
@interface NCNotificationMasterList : NSObject
@property (nonatomic, assign) NSUInteger notificationCount;
@property (strong, nonatomic) NSObject *delegate;
@end

@interface CSAdjunctListView : UIView
-(void)_layoutStackView;
@end

@interface CSNotificationAdjunctListViewController : UIViewController
-(void)_removeItem:(id)arg1 animated:(BOOL)arg2;
-(void)_insertItem:(id)arg1 animated:(BOOL)arg2;
@property (nonatomic,retain) NSMutableDictionary * identifiersToItems;
@property (strong, nonatomic) UIStackView *stackView;
@property (strong, nonatomic) CSAdjunctListView *view;
@end

@interface NCNotificationStructuredListViewController : UIViewController
@property (strong, nonatomic) NCNotificationMasterList *masterList;

//axon specific
-(NSOrderedSet *)axnNotificationRequests;
@end

@interface AXNView : UIView
@property (strong, nonatomic) UICollectionView *collectionView;
-(void)refresh;
@end

@interface AXNManager : NSObject
+(instancetype)sharedInstance;
@property (nonatomic, weak) AXNView *view;
@end
