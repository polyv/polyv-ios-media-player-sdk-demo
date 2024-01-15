//
//  PLVMediaPlayerSkinDefinitionTipsView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by Dhan on 2024/1/4.
//

#import <UIKit/UIKit.h>
#import "PLVMediaPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaPlayerSkinDefinitionTipsViewDelegate;

/// 弱网清晰度切换提示
@interface PLVMediaPlayerSkinDefinitionTipsView : UIView

/// 是否正在展示
@property (nonatomic, assign, readonly) BOOL isShowing;

@property (nonatomic, weak) id<PLVMediaPlayerSkinDefinitionTipsViewDelegate> delegate;

/// 自定义弱网文案
/// @note 该部分可替换"您的网络环境较差，可尝试"部分
@property (nonatomic, copy) NSString *customPoorNetworkTips;

/// 更新布局
- (void)updateUIWithTargetPoint:(CGPoint)targetPoint abovePoint:(BOOL)above;

/// 展示切换清晰度的提示
/// @param mediaState 当前播放状态
- (void)showSwitchQualityWithModel:(PLVMediaPlayerState *)mediaState targetPoint:(CGPoint)targetPoint abovePoint:(BOOL)above;

/// 隐藏提示view
- (void)hide;

@end

@protocol PLVMediaPlayerSkinDefinitionTipsViewDelegate <NSObject>

- (void)mediaPlayerSkinDefinitionTipsView_SwitchQuality:(NSInteger)qualityLevel;

@end

NS_ASSUME_NONNULL_END
