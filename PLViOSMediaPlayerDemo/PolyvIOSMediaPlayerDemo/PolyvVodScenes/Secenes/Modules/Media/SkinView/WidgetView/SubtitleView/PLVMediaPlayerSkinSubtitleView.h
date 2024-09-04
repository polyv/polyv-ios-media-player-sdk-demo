//
//  PLVMediaPlayerSkinSubtitleView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/8/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVMediaPlayerSkinSubtitleView : UIView

/// 字幕标签，单字幕模式-显示，双字幕模式下显示上层字幕
@property (nonatomic, strong)  UILabel *subtitleLabel;

/// 字幕标签2，单字幕模式-不显示，仅限双字幕模式显示下层字幕
@property (nonatomic, strong)  UILabel *subtitleLabel2;

/// 顶部字幕标签，单字幕模式-显示，双字幕模式下显示上层字幕
@property (nonatomic, strong)  UILabel *subtitleTopLabel;

/// 顶部字幕标签，单字幕模式-不显示，双字幕模式-显示下层字幕
@property (nonatomic, strong)  UILabel *subtitleTopLabel2;

/// 更新字幕参考点坐标
- (void)updateUIWithSubviewTargetPoint:(CGPoint)targetPoint;

/// 字幕内容实时刷新后，更新布局
/// @doubleSubtitle 是否双语字幕
- (void)freshUIWithDoubleSubtile:(BOOL)doubleSubtitle;

@end

NS_ASSUME_NONNULL_END
