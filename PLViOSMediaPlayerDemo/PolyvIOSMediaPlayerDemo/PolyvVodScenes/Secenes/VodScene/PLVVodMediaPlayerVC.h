//
//  PLVVodMediaPlayerVC.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/9.
//

#import <UIKit/UIKit.h>
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVMediaPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVVodMediaPlayerVCDelegate;

@interface PLVVodMediaPlayerVC : UIViewController

/// 播放器核心
@property (nonatomic, strong) PLVVodMediaPlayer *vodMediaPlayer;
/// 播放器代理回调
@property (nonatomic, weak) id<PLVVodMediaPlayerVCDelegate> vcDelegate;

// vid 播放
- (void)playWithVid:(NSString *)vid;

// 播放速度
- (void)setPlayRate:(CGFloat)rate;

// 切换清晰度
- (void)setPlayQuality:(NSInteger )qualityLevel;

// 切换音频、视频播放模式
- (void)setPlaybackMode:(PLVVodPlaybackMode )playbackMode;

/// 显示视频模式UI
- (void)showVideoModeUI;

/// 显示音频模式UI
- (void)showAudioModeUI;

/// 播放器状态信息
- (PLVMediaPlayerState *)mediaPlayerState;

@end

@protocol PLVVodMediaPlayerVCDelegate <NSObject>

/// 更多菜单
- (void)vodMediaPlayerVC_ShowMoreView:(PLVVodMediaPlayerVC *)playerVC;
/// 返回事件
- (void)vodMediaPlayerVC_BackEvent:(PLVVodMediaPlayerVC *)playerVC;
/// 画中画状态回调
- (void)vodMediaPlayerVC_PictureInPictureChangeState:(PLVVodMediaPlayerVC *)playerVC state:(PLVPictureInPictureState )state;
/// 画中画开启失败
- (void)vodMediaPlayerVC_StartPictureInPictureFailed:(PLVVodMediaPlayerVC *)playerVC error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
