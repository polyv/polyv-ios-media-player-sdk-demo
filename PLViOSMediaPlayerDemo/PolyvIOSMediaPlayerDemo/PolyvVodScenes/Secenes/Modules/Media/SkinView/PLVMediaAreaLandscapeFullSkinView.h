//
//  PLVMediaPlayerFullSkinView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/30.
//

#import "PLVMediaAreaBaseSkinView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaAreaLandscapeFullSkinViewDelegate;

/// 媒体播放器皮肤视图 (用于 横向-全屏 显示)
@interface PLVMediaAreaLandscapeFullSkinView : PLVMediaAreaBaseSkinView

@property (nonatomic, strong) UIButton *playRateButton;   // 倍速
@property (nonatomic, strong) UIButton *qualityButton;    // 清晰度切换

/// 是否需要显示皮肤控件，当通过外部控件 调用 hiddenMediaPlayerFullSkinView 关闭皮肤时内部会记录此皮肤当前显示状态
@property (nonatomic, assign) BOOL needShowSkin;

@property (nonatomic, strong) id<PLVMediaAreaLandscapeFullSkinViewDelegate> fullSkinDelegate;

/// 隐藏和显示皮肤视图 控件
/// @param isHidden YES 隐藏控件，NO显示控件
- (void)hiddenMediaPlayerFullSkinView:(BOOL)isHidden;

/// 更新清晰度
- (void)updateQualityLevel:(NSInteger)qualityLevel;

/// 更新倍速
- (void)updatePlayRate:(CGFloat)playRate;

@end

@protocol PLVMediaAreaLandscapeFullSkinViewDelegate <NSObject>

/// 锁屏事件
- (void)mediaAreaLandscapeFullSkinView_LockSceenEvent:(PLVMediaAreaLandscapeFullSkinView *)fullSkinView;

/// 倍速切换
- (void)mediaAreaLandscapeFullSkinView_SwitchPlayRate:(PLVMediaAreaLandscapeFullSkinView *)fullSkinView;

/// 清晰度切换
- (void)mediaAreaLandscapeFullSkinView_SwitchQuality:(PLVMediaAreaLandscapeFullSkinView *)fullSkinView;

@end

NS_ASSUME_NONNULL_END
