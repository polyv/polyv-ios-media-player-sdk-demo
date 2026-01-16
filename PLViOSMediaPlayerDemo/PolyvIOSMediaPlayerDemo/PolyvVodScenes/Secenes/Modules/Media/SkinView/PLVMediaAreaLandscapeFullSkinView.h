//
//  PLVMediaPlayerFullSkinView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/30.
//

#import "PLVMediaAreaBaseSkinView.h"
#import "PLVMediaPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaAreaLandscapeFullSkinViewDelegate;

/// 媒体播放器皮肤视图 (用于 横向-全屏 显示)
@interface PLVMediaAreaLandscapeFullSkinView : PLVMediaAreaBaseSkinView

@property (nonatomic, strong) UIButton *playRateButton;   // 倍速
@property (nonatomic, strong) UIButton *qualityButton;    // 清晰度切换
@property (nonatomic, strong) UIButton *knowledgeButton;  // 知识点清单
@property (nonatomic, strong) UIButton *scaleResetButton; // 还原屏幕

/// 是否需要显示皮肤控件，当通过外部控件 调用 hiddenMediaPlayerFullSkinView 关闭皮肤时内部会记录此皮肤当前显示状态
@property (nonatomic, assign) BOOL needShowSkin;

/// 弹幕是否开启
@property (nonatomic, assign) BOOL enableDanmu;
/// 是否显示弹幕开关
@property (nonatomic, assign) BOOL showDanmuSwitch;

@property (nonatomic, weak) id<PLVMediaAreaLandscapeFullSkinViewDelegate> fullSkinDelegate;

/// 隐藏和显示皮肤视图 控件
/// @param isHidden YES 隐藏控件，NO显示控件
- (void)hiddenMediaPlayerFullSkinView:(BOOL)isHidden;

/// 更新清晰度
- (void)updateQualityLevel:(NSInteger)qualityLevel;

/// 更新倍速
- (void)updatePlayRate:(CGFloat)playRate;

/// 音频、视频模式切换更新
- (void)updateWithMediaPlayerState:(PLVMediaPlayerState *)playerState;

/// 更新知识点按钮显示状态
/// @param show 是否显示
/// @param title 按钮标题
- (void)updateKnowledgeButton:(BOOL)show title:(NSString *)title;

/// 更新还原屏幕按钮显示状态
/// @param show 是否显示（当播放器缩放时显示，还原后隐藏）
- (void)updateScaleResetButton:(BOOL)show;

@end

@protocol PLVMediaAreaLandscapeFullSkinViewDelegate <NSObject>

/// 锁屏事件
- (void)mediaAreaLandscapeFullSkinView_LockSceenEvent:(PLVMediaAreaLandscapeFullSkinView *)fullSkinView;

/// 倍速切换
- (void)mediaAreaLandscapeFullSkinView_SwitchPlayRate:(PLVMediaAreaLandscapeFullSkinView *)fullSkinView;

/// 清晰度切换
- (void)mediaAreaLandscapeFullSkinView_SwitchQuality:(PLVMediaAreaLandscapeFullSkinView *)fullSkinView;

/// 知识点按钮点击
- (void)mediaAreaLandscapeFullSkinView_KnowledgeButtonClick:(PLVMediaAreaLandscapeFullSkinView *)fullSkinView;

/// 弹幕开关切换
- (void)mediaAreaLandscapeFullSkinView_DanmuSwitch:(PLVMediaAreaLandscapeFullSkinView *)fullSkinView enable:(BOOL)enable;

/// 弹幕输入按钮点击
- (void)mediaAreaLandscapeFullSkinView_DanmuEnter:(PLVMediaAreaLandscapeFullSkinView *)fullSkinView;

/// 还原屏幕按钮点击
- (void)mediaAreaLandscapeFullSkinView_ScaleResetButtonClick:(PLVMediaAreaLandscapeFullSkinView *)fullSkinView;

@end

NS_ASSUME_NONNULL_END
