//
//  PLVMediaPlayerContentScaleView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created on 2026/1/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVMediaPlayerContentScaleView;

@protocol PLVMediaPlayerContentScaleViewDelegate <NSObject>

@optional
/// 缩放状态改变回调
/// @param scaleView 缩放视图
/// @param scale 当前缩放比例 (1.0 表示原始大小)
- (void)mediaPlayerContentScaleView:(PLVMediaPlayerContentScaleView *)scaleView didChangeScale:(CGFloat)scale;

@end

/// 播放器内容缩放视图
/// 支持双指捏合缩放
@interface PLVMediaPlayerContentScaleView : UIView

/// 代理
@property (nonatomic, weak) id<PLVMediaPlayerContentScaleViewDelegate> delegate;

/// 是否启用缩放功能 (默认 NO)
@property (nonatomic, assign) BOOL zoomEnabled;

/// 当前缩放比例 (只读)
@property (nonatomic, assign, readonly) CGFloat currentScale;

/// 缩放范围限制
@property (nonatomic, assign) CGFloat minScale;  // 默认 1.0
@property (nonatomic, assign) CGFloat maxScale;  // 默认 3.0

/// 重置缩放到原始大小
- (void)resetZoom;

/// 重置缩放并带动画
- (void)resetZoomWithAnimation:(BOOL)animated;

/// 将手势添加到指定视图上（用于解决视图遮挡问题）
- (void)attachGesturesToView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
