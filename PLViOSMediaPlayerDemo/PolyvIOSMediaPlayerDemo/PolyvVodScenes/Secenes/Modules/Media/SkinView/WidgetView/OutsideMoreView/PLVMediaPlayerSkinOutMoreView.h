//
//  PLVMediaPlayerSkinOutMoreView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/10.
//

#import <UIKit/UIKit.h>
#import "PLVMediaPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaPlayerSkinOutMoreViewDelegate ;

@interface PLVMediaPlayerSkinOutMoreView : UIView

@property (nonatomic, weak) id<PLVMediaPlayerSkinOutMoreViewDelegate> skinOutMoreViewDelegate;

@property (nonatomic, strong) PLVMediaPlayerState *mediaPlayerState;


-(void)showMoreView;
-(void)showMoreViewWithModel:(PLVMediaPlayerState *)mediaPlayerState;
-(void)hideMoreView;

@end

@protocol PLVMediaPlayerSkinOutMoreViewDelegate <NSObject>

- (void)mediaPlayerSkinOutMoreView_SwitchPlayRate:(CGFloat )rate;
- (void)mediaPlayerSkinOutMoreView_SwitchQualityLevel:(NSInteger )qualityLevel;
- (void)mediaPlayerSkinOutMoreView_SwitchToAudioMode;
- (void)mediaPlayerSkinOutMoreView_StartPictureInPicture;

@end

NS_ASSUME_NONNULL_END
