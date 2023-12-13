//
//  PLVMediaPlayerSkinPlaybackRateView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/11.
//

#import <UIKit/UIKit.h>
#import "PLVMediaPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaPlayerSkinPlaybackRateViewDelegate ;

@interface PLVMediaPlayerSkinPlaybackRateView : UIView

@property (nonatomic, weak) id<PLVMediaPlayerSkinPlaybackRateViewDelegate> delegate;

- (void)showPlayRateViewWithModel:(PLVMediaPlayerState *)mediaState;

@end

@protocol PLVMediaPlayerSkinPlaybackRateViewDelegate <NSObject>

- (void)mediaPlayerSkinPlaybackRateView_SwitchPlayRate:(CGFloat)playRate;

@end

NS_ASSUME_NONNULL_END
