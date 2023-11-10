//
//  PLVShortVideoMediaPlayerSkinContainer.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/14.
//

#import <UIKit/UIKit.h>
#import "PLVMediaPlayerShortPortraitSkinView.h"
#import "PLVMediaPlayerFullSkinView.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVMediaPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVShortVideoMediaPlayerSkinContainerDelegate;

@interface PLVShortVideoMediaPlayerSkinContainer : UIView

@property (nonatomic, weak) id<PLVShortVideoMediaPlayerSkinContainerDelegate> containerDelegate;

@property (nonatomic, strong) PLVMediaPlayerShortPortraitSkinView *portraitSkinView;
@property (nonatomic, strong) PLVMediaPlayerFullSkinView *fullSkinView;
@property (nonatomic, strong) PLVMediaPlayerState *mediaPlayerState;

/// 同步播放器皮肤
- (void)syncSkinWithMode:(PLVMediaPlayerState *)mediaPlayerState;

/// 显示音频模式UI
- (void)showAudioModeUI;

/// 显示视频模式UI
- (void)showVideoModeUI;

@end

@protocol PLVShortVideoMediaPlayerSkinContainerDelegate <NSObject>

/// 展示竖屏时候的moreview 视图
- (void)mediaPlayerSkinContainer_ShowMoreView:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer;
/// 切回视频模式
- (void)mediaPlayerSkinContainer_SwitchVideoMode:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer;

/// 切换到音频模式
- (void)mediaPlayerSkinContainer_SwitchToAudioMode:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer;
/// 开启画中画播放
- (void)mediaPlayerSkinContainer_StartPictureInPicture:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer;

/// 切换清晰度
- (void)mediaPlayerSkinContainer_SwitchQualtiy:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer qualityLevel:(NSInteger)qualityLevel;
/// 切换播放速度
- (void)mediaPlayerSkinContainer_SwitchPlayRate:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer playRate:(CGFloat)playRate;

/// 皮肤按钮返回事件
- (void)mediaPlayerSkinContainer_BackEvent:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer;

/// 皮肤播放按钮事件
- (void)mediaPlayerSkinContainer_Play:(PLVShortVideoMediaPlayerSkinContainer *)skin willPlay:(BOOL)willPlay;

/// 拖动进度条事件
- (void)mediaPlayerSkinContainer_SliderDragEnd:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer sliderValue:(CGFloat)sliderValue;

/// 推动进度面板事件
- (void)mediaPlayerSkinContainer_ProgressViewPan:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer scrubTime:(NSTimeInterval)scrubTime;


@end

NS_ASSUME_NONNULL_END
