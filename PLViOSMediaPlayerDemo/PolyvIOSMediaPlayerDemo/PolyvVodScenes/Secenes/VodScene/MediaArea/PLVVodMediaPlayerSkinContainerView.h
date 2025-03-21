//
//  PLVVodMediaPlayerSkinContainer.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/9.
//

#import <UIKit/UIKit.h>
#import "PLVMediaAreaPortraitHalfSkinView.h"
#import "PLVMediaAreaLandscapeFullSkinView.h"
#import "PLVMediaPlayerSkinSubtitleView.h"

#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVMediaPlayerState.h"
#import "PLVMediaPlayerSkinMoreView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVVodMediaPlayerSkinContainerViewDelegate;

/// 长视频 - 播放器皮肤容器
///     内部包含 竖向-半屏皮肤 和 横向-全屏皮肤 ，并同步显示 播放器的实时播放状态
@interface PLVVodMediaPlayerSkinContainerView : UIView

@property (nonatomic, weak) id<PLVVodMediaPlayerSkinContainerViewDelegate> containerDelegate;

@property (nonatomic, strong) PLVMediaAreaPortraitHalfSkinView *portraitHalfSkinView;
@property (nonatomic, strong) PLVMediaAreaLandscapeFullSkinView *landscapeFullSkinView;
@property (nonatomic, strong) PLVMediaPlayerSkinSubtitleView *subtitleView;
@property (nonatomic, strong) PLVMediaPlayerSkinMoreView *skinMoreView;

@property (nonatomic, strong) PLVMediaPlayerState *mediaPlayerState;

/// 同步播放器皮肤
- (void)syncSkinWithMode:(PLVMediaPlayerState *)mediaPlayerState;

/// 显示音频模式UI
- (void)showAudioModeUI;

/// 显示视频模式UI
- (void)showVideoModeUI;

/// 显示循环播放UI
- (void)showLoopPlayUI;

/// 隐藏循环播放UI
- (void)hideLoopPlayUI;

/// 显示弱网切换清晰度提示
- (void)showDefinitionTipsView;

/// 视频加载速率显示
///  @param speed 加载速度
///  @param loading 正在加载
- (void)showLoadingSpeed:(NSString *)speed loading:(BOOL)loading;

/// 更新视频加载速率
/// @param speed 加载速度
- (void)updateLoadingSpeed:(NSString *)speed;

/// 提示续播进度
/// @param curTime 当前播放时间
- (void)showPlayProgressToastView:(NSInteger)curTime;

/// 显示、隐藏画中画占位图
/// @param status  YES,显示 NO 隐藏
- (void)showPicInPicPlaceholderViewWithStatus:(BOOL)status;

/// 更新字幕显示布局
/// @param doubleSubtitle YES  双语字幕 NO 单语字幕
- (void)updateSubtitleViewUIWithDouble:(BOOL)doubleSubtitle;

@end

@protocol PLVVodMediaPlayerSkinContainerViewDelegate <NSObject>

/// 展示竖屏时候的 外部 moreview 视图
- (void)mediaPlayerSkinContainerView_ShowMoreView:(PLVVodMediaPlayerSkinContainerView *)skinContainer;

/// 切回视频模式
- (void)mediaPlayerSkinContainerView_SwitchToVideoMode:(PLVVodMediaPlayerSkinContainerView *)skinContainer;

/// 切换到音频模式
- (void)mediaPlayerSkinContainerView_SwitchToAudioMode:(PLVVodMediaPlayerSkinContainerView *)skinContainer;

/// 开启画中画播放
- (void)mediaPlayerSkinContainerView_StartPictureInPicture:(PLVVodMediaPlayerSkinContainerView *)skinContainer;

/// 切换清晰度
- (void)mediaPlayerSkinContainerView_SwitchQualtiy:(PLVVodMediaPlayerSkinContainerView *)skinContainer qualityLevel:(NSInteger)qualityLevel;

/// 切换播放速度
- (void)mediaPlayerSkinContainerView_SwitchPlayRate:(PLVVodMediaPlayerSkinContainerView *)skinContainer playRate:(CGFloat)playRate;

/// 皮肤按钮返回事件
- (void)mediaPlayerSkinContainerView_BackEvent:(PLVVodMediaPlayerSkinContainerView *)skinContainer;

/// 皮肤按钮全屏事件
- (void)mediaPlayerSkinContainerView_FullScreenEvent:(PLVVodMediaPlayerSkinContainerView *)skinContainer;

/// 皮肤播放按钮事件
- (void)mediaPlayerSkinContainerView_Play:(PLVVodMediaPlayerSkinContainerView *)skin willPlay:(BOOL)willPlay;

/// 拖动进度条事件
- (void)mediaPlayerSkinContainerView_SliderDragEnd:(PLVVodMediaPlayerSkinContainerView *)skinContainer sliderValue:(CGFloat)sliderValue;

/// 推动进度面板事件
- (void)mediaPlayerSkinContainerview_ProgressViewPan:(PLVVodMediaPlayerSkinContainerView *)skinContainer scrubTime:(NSTimeInterval)scrubTime;

/// 横屏 - 字幕选中事件
- (void)mediaPlayerSkinContainerView_SelectSubtitle:(PLVVodMediaPlayerSkinContainerView *)skinContainer;

/// 横屏 - 开始下载
- (void)mediaPlayerSkinContainerView_StartDownload:(PLVVodMediaPlayerSkinContainerView *)skinContainer;


@end

NS_ASSUME_NONNULL_END
