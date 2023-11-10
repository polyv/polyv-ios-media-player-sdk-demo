//
//  PLVVodMediaPlayerSkinContainer.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/9.
//

#import <UIKit/UIKit.h>
#import "PLVMediaPlayerPortraitSkinView.h"
#import "PLVMediaPlayerFullSkinView.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVMediaPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVVodMediaPlayerSkinContainerDelegate;

@interface PLVVodMediaPlayerSkinContainer : UIView

@property (nonatomic, weak) id<PLVVodMediaPlayerSkinContainerDelegate> containerDelegate;

@property (nonatomic, strong) PLVMediaPlayerPortraitSkinView *portraitSkinView;
@property (nonatomic, strong) PLVMediaPlayerFullSkinView *fullSkinView;
@property (nonatomic, strong) PLVMediaPlayerState *mediaPlayerState;

/// 同步播放器皮肤
- (void)syncSkinWithMode:(PLVMediaPlayerState *)mediaPlayerState;

/// 显示音频模式UI
- (void)showAudioModeUI;

/// 显示视频模式UI
- (void)showVideoModeUI;

/// 显示循环播放UI
- (void)showLoopPlayUI;

@end

@protocol PLVVodMediaPlayerSkinContainerDelegate <NSObject>

/// 展示竖屏时候的moreview 视图
- (void)mediaPlayerSkinContainer_ShowMoreView:(PLVVodMediaPlayerSkinContainer *)skinContainer;
/// 切回视频模式
- (void)mediaPlayerSkinContainer_SwitchVideoMode:(PLVVodMediaPlayerSkinContainer *)skinContainer;

/// 切换到音频模式
- (void)mediaPlayerSkinContainer_SwitchToAudioMode:(PLVVodMediaPlayerSkinContainer *)skinContainer;
/// 开启画中画播放
- (void)mediaPlayerSkinContainer_StartPictureInPicture:(PLVVodMediaPlayerSkinContainer *)skinContainer;

/// 切换清晰度
- (void)mediaPlayerSkinContainer_SwitchQualtiy:(PLVVodMediaPlayerSkinContainer *)skinContainer qualityLevel:(NSInteger)qualityLevel;
/// 切换播放速度
- (void)mediaPlayerSkinContainer_SwitchPlayRate:(PLVVodMediaPlayerSkinContainer *)skinContainer playRate:(CGFloat)playRate;

/// 皮肤按钮返回事件
- (void)mediaPlayerSkinContainer_BackEvent:(PLVVodMediaPlayerSkinContainer *)skinContainer;

/// 皮肤播放按钮事件
- (void)mediaPlayerSkinContainer_Play:(PLVVodMediaPlayerSkinContainer *)skin willPlay:(BOOL)willPlay;

/// 拖动进度条事件
- (void)mediaPlayerSkinContainer_SliderDragEnd:(PLVVodMediaPlayerSkinContainer *)skinContainer sliderValue:(CGFloat)sliderValue;

/// 推动进度面板事件
- (void)mediaPlayerSkinContainer_ProgressViewPan:(PLVVodMediaPlayerSkinContainer *)skinContainer scrubTime:(NSTimeInterval)scrubTime;


@end

NS_ASSUME_NONNULL_END
