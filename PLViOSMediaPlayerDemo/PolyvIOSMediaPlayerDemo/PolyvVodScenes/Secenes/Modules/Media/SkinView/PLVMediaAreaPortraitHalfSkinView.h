//
//  PLVMediaPlayerSkinView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/30.
//

#import "PLVMediaAreaBaseSkinView.h"

NS_ASSUME_NONNULL_BEGIN

/// 媒体播放器皮肤视图 (用于 竖向-半屏 显示)
@interface PLVMediaAreaPortraitHalfSkinView : PLVMediaAreaBaseSkinView

/// 隐藏和显示皮肤视图 控件
/// @param isHidden YES 隐藏控件，NO显示控件
- (void)hiddenMediaPlayerPortraitHalSkinView:(BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
