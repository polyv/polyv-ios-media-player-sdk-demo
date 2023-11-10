//
//  PLVMediaPlayerBaseSkinView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/30.
//

#import <UIKit/UIKit.h>

#import "PLVProgressSlider.h"
#import "PLVLCMediaProgressView.h"

#ifndef NormalPlayerViewScale
#define NormalPlayerViewScale (9.0 / 16.0)
#endif

NS_ASSUME_NONNULL_BEGIN

/// 枚举
/// 媒体播放器皮肤 场景类型
typedef NS_ENUM(NSUInteger, PLVMediaPlayerBaseSkinViewType) {
    /// 点播播放器
    PLVMediaPlayerBaseSkinViewType_ShortPlayerPortrait = 1,  // 短视频竖屏皮肤
    PLVMediaPlayerBaseSkinViewType_LongPlayerPortrailt = 2,  // 长视频竖屏皮肤
    PLVMediaPlayerBaseSkinViewType_PlayerFull = 3            // 横屏全屏皮肤
};

@protocol PLVMediaPlayerBaseSkinViewDelegate;

@interface PLVMediaPlayerBaseSkinView : UIView

@property (nonatomic, weak) id <PLVMediaPlayerBaseSkinViewDelegate> baseDelegate;

@property (nonatomic, assign, readonly) PLVMediaPlayerBaseSkinViewType skinViewType;

@property (nonatomic, assign) BOOL skinShow;

@property (nonatomic, strong) UITapGestureRecognizer * tapGR;
@property (nonatomic, strong) UIPanGestureRecognizer * panGR;
@property (nonatomic, strong) UITapGestureRecognizer * doubleTapGR;

@property (nonatomic, strong) CAGradientLayer * topShadowLayer; // 顶部阴影背景 (负责展示 阴影背景)
@property (nonatomic, strong) UIButton * backButton;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UIButton * moreButton;

@property (nonatomic, strong) CAGradientLayer * bottomShadowLayer; // 底部阴影背景 (负责展示 阴影背景)
@property (nonatomic, strong) UIButton * playButton;
@property (nonatomic, strong) UIButton * fullScreenButton;
@property (nonatomic, strong) UILabel * currentTimeLabel; // 当前时间
@property (nonatomic, strong) UILabel * diagonalsLabel;   // 斜杆符号文本框
@property (nonatomic, strong) UILabel * durationLabel;    // 视频总时长
@property (nonatomic, strong) PLVProgressSlider * progressSlider; // 播放进度
@property (nonatomic, strong) PLVLCMediaProgressView *progressView; // seek 进度

// 初始化皮肤
- (instancetype)initWithSkinType:(PLVMediaPlayerBaseSkinViewType )skinType;

- (CGFloat)getLabelTextWidth:(UILabel *)label;

- (void)setTitleLabelWithText:(NSString *)titleText;

/// 可提供给子类重写
- (void)setPlayButtonWithPlaying:(BOOL)playing;

/// 播放进度、缓存进度更新
- (void)setProgressWithCachedProgress:(CGFloat)cachedProgress
                       playedProgress:(CGFloat)playedProgress
                         durationTime:(NSTimeInterval)durationTime
                    currentTimeString:(NSString *)currentTimeString
                       durationString:(NSString *)durationString;

/// 可提供给子类重写
- (void)controlsSwitchShowStatusWithAnimation:(BOOL)showStatus;

- (void)setupUI;

- (void)refreshPlayTimesLabelFrame;

- (void)refreshProgressViewFrame;

/// 工具方法 (与 PLVLCBasePlayerSkinView 类本身没有逻辑关联，仅业务上相关)
+ (BOOL)checkView:(UIView *)otherView canBeHandlerForTouchPoint:(CGPoint)point onSkinView:(nonnull PLVMediaPlayerBaseSkinView *)skinView;

/// 2.5秒后自动隐藏皮肤
- (void)autoHideSkinView;

@end

@protocol PLVMediaPlayerBaseSkinViewDelegate <NSObject>

- (void)plvLCBasePlayerSkinViewBackButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView currentFullScreen:(BOOL)currentFullScreen;

- (void)plvLCBasePlayerSkinViewPictureInPictureButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView;

- (void)plvLCBasePlayerSkinViewMoreButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView;

- (void)plvLCBasePlayerSkinViewPlayButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView wannaPlay:(BOOL)wannaPlay;

- (void)plvLCBasePlayerSkinViewProgressViewPaned:(PLVMediaPlayerBaseSkinView *)skinView scrubTime:(NSTimeInterval)scrubTime;

- (void)plvLCBasePlayerSkinViewFullScreenOpenButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView;

@optional

/// 询问是否有其他视图处理此次触摸事件
///
/// @param skinView 媒体播放器皮肤视图
/// @param point 此次触摸事件的 CGPoint (相对于皮肤视图skinView)
///
/// @return BOOL 是否有其他视图处理 (YES:有，则skinView不再处理此触摸事件 NO:没有，则由skinView处理此触摸事件)
- (BOOL)plvLCBasePlayerSkinView:(PLVMediaPlayerBaseSkinView *)skinView askHandlerForTouchPointOnSkinView:(CGPoint)point;

- (void)plvLCBasePlayerSkinView:(PLVMediaPlayerBaseSkinView *)skinView didChangedSkinShowStatus:(BOOL)skinShow;

- (void)plvLCBasePlayerSkinView:(PLVMediaPlayerBaseSkinView *)skinView sliderDragEnd:(CGFloat)currentSliderProgress;

/// 长按手势
- (void)plvLCBasePlayerSkinView:(PLVMediaPlayerBaseSkinView *)skinView longPressGestureStart:(UILongPressGestureRecognizer *)gesture;
- (void)plvLCBasePlayerSkinView:(PLVMediaPlayerBaseSkinView *)skinView longPressGestureEnd:(UILongPressGestureRecognizer *)gesture;

@end

NS_ASSUME_NONNULL_END
