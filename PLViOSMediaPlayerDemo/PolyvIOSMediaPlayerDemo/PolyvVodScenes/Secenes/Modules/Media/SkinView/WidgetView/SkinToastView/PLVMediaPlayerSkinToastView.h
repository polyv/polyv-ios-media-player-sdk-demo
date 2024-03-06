//
//  PLVMediaPlayerSkinToastView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/3/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger){
    PLVMediaPlayerSkinToastViewUIStyleShortVideo = 1,
    PLVMediaPlayerSkinToastViewUIStyleLongVideo = 2
} PLVMediaPlayerSkinToastViewUIStyle;

@interface PLVMediaPlayerSkinToastView : UIView

/// 是否已经提示过  一般同一个视频只提示一次
@property (nonatomic, assign) BOOL isShowned;

/// 视频续播，进度提示
/// @param curTime 当前播放时间，单位秒
/// @param targetPoint 提示控件展示位置，左下角参考点坐标
- (void)showCurrentPlayTimeTips:(NSInteger )curTime targetPoint:(CGPoint)targetPoint uiStyle:(PLVMediaPlayerSkinToastViewUIStyle)uiStyle;

/// 横竖屏切换，适配位置
- (void)updateWithTargetPoint:(CGPoint)targetPoint;

@end

NS_ASSUME_NONNULL_END
