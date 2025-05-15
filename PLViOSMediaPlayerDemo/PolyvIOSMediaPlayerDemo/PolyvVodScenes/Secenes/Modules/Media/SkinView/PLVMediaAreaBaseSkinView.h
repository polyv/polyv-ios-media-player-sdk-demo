//
//  PLVMediaPlayerBaseSkinView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/30.
//

#import <UIKit/UIKit.h>

#import "PLVVodMediaProgressSlider.h"
#import "PLVMediaProgressPreviewView.h"

#ifndef NormalPlayerViewScale
#define NormalPlayerViewScale (9.0 / 16.0)
#endif

NS_ASSUME_NONNULL_BEGIN

/// 枚举
/// 媒体播放器皮肤 场景类型
typedef NS_ENUM(NSUInteger, PLVMediaAreaBaseSkinViewType) {
    /// 点播播放器
    PLVMediaAreaBaseSkinViewType_Portrait_Full = 1,   // 竖向-全屏 皮肤
    PLVMediaAreaBaseSkinViewType_Portrait_Half = 2,  // 竖向-半屏 皮肤
    PLVMediaAreaBaseSkinViewType_Landscape_Full = 3   // 横向-全屏 皮肤
};

@protocol PLVMediaAreaBaseSkinViewDelegate;

@interface PLVMediaAreaBaseSkinView : UIView

@property (nonatomic, weak) id <PLVMediaAreaBaseSkinViewDelegate> baseDelegate;

// 具体皮肤的类型
@property (nonatomic, assign, readonly) PLVMediaAreaBaseSkinViewType skinViewType;

// 当前皮肤是否显示中
@property (nonatomic, assign) BOOL isSkinShowing;

// 顶部区域 控件
@property (nonatomic, strong) CAGradientLayer * topShadowLayer; // 顶部阴影背景 (负责展示 阴影背景)
@property (nonatomic, strong) UIButton * backButton; // 返回 按钮
@property (nonatomic, strong) UILabel * titleLabel;  // 标题 文本框
@property (nonatomic, strong) UIButton * moreButton; // 更多 按钮

// 底部区域 控件
@property (nonatomic, strong) CAGradientLayer * bottomShadowLayer; // 底部阴影背景 (负责展示 阴影背景)
@property (nonatomic, strong) UIButton * playButton;       // 播放/暂停 按钮
@property (nonatomic, strong) UIButton * fullScreenButton; // 全屏 按钮
@property (nonatomic, strong) UILabel * currentTimeLabel;  // 当前时间 文本框
@property (nonatomic, strong) UILabel * diagonalsLabel;    // 斜杆符号 文本框
@property (nonatomic, strong) UILabel * durationLabel;     // 视频总时 文本框
@property (nonatomic, strong) PLVVodMediaProgressSlider * progressSlider; // 播放进度条
@property (nonatomic, strong) PLVMediaProgressPreviewView *progressPreviewView; // 调整视频播放进度时 的预览视图，包括 时间预览文本框 和 视频预览图片

// 手势识别
@property (nonatomic, strong) UIPanGestureRecognizer * panGR;       // 拖拽 手势识别
@property (nonatomic, strong) UITapGestureRecognizer * tapGR;       // 单击 手势识别
@property (nonatomic, strong) UITapGestureRecognizer * doubleTapGR; // 双击 手势识别

@property (nonatomic, assign) BOOL isInited; // 是否已完成UI初始化

// 初始化皮肤
- (instancetype)initWithSkinType:(PLVMediaAreaBaseSkinViewType )skinType;

- (void)setupUI;

- (CGFloat)getLabelTextWidth:(UILabel *)label;

- (void)setTitleLabelWithText:(NSString *)titleText;

/// 可提供给子类重写
- (void)setPlayButtonWithPlaying:(BOOL)playing;

- (void)refreshPlayTimesLabelFrame;

/// 更新
- (void)refreshProgressViewFrame;

/// 播放进度、缓存进度更新
- (void)setProgressWithCachedProgress:(CGFloat)cachedProgress
                       playedProgress:(CGFloat)playedProgress
                         durationTime:(NSTimeInterval)durationTime
                    currentTimeString:(NSString *)currentTimeString
                       durationString:(NSString *)durationString;

/// 可提供给子类重写
- (void)controlsSwitchShowStatusWithAnimation:(BOOL)showStatus;

/// 2.5秒后自动隐藏皮肤
- (void)autoHideSkinView;

/// 工具方法 (与 PLVLCBasePlayerSkinView 类本身没有逻辑关联，仅业务上相关)
+ (BOOL)checkView:(UIView *)otherView canBeHandlerForTouchPoint:(CGPoint)point onSkinView:(nonnull PLVMediaAreaBaseSkinView *)skinView;

@end

@protocol PLVMediaAreaBaseSkinViewDelegate <NSObject>

/// 回退 按钮事件 回调方法
- (void)plvMediaAreaBaseSkinViewBackButtonClicked:(PLVMediaAreaBaseSkinView *)skinView;

/// 画中画 按钮事件 回调方法
- (void)plvMediaAreaBaseSkinViewPictureInPictureButtonClicked:(PLVMediaAreaBaseSkinView *)skinView;

/// 更多 按钮事件 回调方法
- (void)plvMediaAreaBaseSkinViewMoreButtonClicked:(PLVMediaAreaBaseSkinView *)skinView;

/// 播放/暂停 按钮事件 回调方法
- (void)plvMediaAreaBaseSkinViewPlayButtonClicked:(PLVMediaAreaBaseSkinView *)skinView wannaPlay:(BOOL)wannaPlay;

/// 全屏 按钮事件 回调方法
- (void)plvMediaAreaBaseSkinViewFullScreenOpenButtonClicked:(PLVMediaAreaBaseSkinView *)skinView;

/// 进度面板拖动结束 回调方法
- (void)plvMediaAreaBaseSkinViewProgressViewPaned:(PLVMediaAreaBaseSkinView *)skinView scrubTime:(NSTimeInterval)scrubTime;

@optional

/// 询问是否有其他视图处理此次触摸事件
///
/// @param skinView 媒体播放器皮肤视图
/// @param point 此次触摸事件的 CGPoint (相对于皮肤视图skinView)
///
/// @return BOOL 是否有其他视图处理 (YES:有，则skinView不再处理此触摸事件 NO:没有，则由skinView处理此触摸事件)
- (BOOL)plvMediaAreaBaseSkinView:(PLVMediaAreaBaseSkinView *)skinView askHandlerForTouchPointOnSkinView:(CGPoint)point;

/// 皮肤显示状态 改变 回调方法
- (void)plvMediaAreaBaseSkinView:(PLVMediaAreaBaseSkinView *)skinView didChangedSkinShowStatus:(BOOL)skinShow;

/// 进度条拖动结束 回调方法
- (void)plvMediaAreaBaseSkinView:(PLVMediaAreaBaseSkinView *)skinView sliderDragEnd:(CGFloat)currentSliderProgress;

/// 长按开始 手势事件 回调方法
- (void)plvMediaAreaBaseSkinView:(PLVMediaAreaBaseSkinView *)skinView longPressGestureStart:(UILongPressGestureRecognizer *)gesture;

/// 长按结束 手势事件 回调方法
- (void)plvMediaAreaBaseSkinView:(PLVMediaAreaBaseSkinView *)skinView longPressGestureEnd:(UILongPressGestureRecognizer *)gesture;

@end

NS_ASSUME_NONNULL_END
