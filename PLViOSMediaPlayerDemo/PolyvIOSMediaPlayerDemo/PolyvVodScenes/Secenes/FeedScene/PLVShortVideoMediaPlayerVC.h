//
//  PLVSkinVodMediaPlayerVC.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/29.
//

#import <UIKit/UIKit.h>
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>


NS_ASSUME_NONNULL_BEGIN

@protocol PLVShortVideoMediaPlayerVCDelegate;

@interface PLVShortVideoMediaPlayerVC : UIViewController

/// 播放器核心
@property (nonatomic, strong) PLVVodMediaPlayer *vodMediaPlayer;
/// 播放器代理回调
@property (nonatomic, weak) id<PLVShortVideoMediaPlayerVCDelegate> vcDelegate;

@property (nonatomic, copy) NSString *vid;

/// 设置VID 播放
- (void)playWithVid:(NSString *)vid;

// 播放
- (void)play;

// 暂停
- (void)pause;

// 销毁播放器
- (void)destroyPlayer;

// 正在播放
- (BOOL)isPlaying;

// 调整UI
- (void)setFrame:(CGRect )frame;

// 播放速度
- (void)setPlayRate:(CGFloat)rate;

// 切换清晰度
- (void)setPlayQuality:(NSInteger )qualityLevel;

// 切换音频、视频播放模式
- (void)setPlaybackMode:(PLVVodPlaybackMode )playbackMode;

/// 显示视频模式UI
- (void)showVideoModeUI;

/// 视图出现
- (void)startActive;
/// 视图消失
- (void)endActive;

@end

@protocol PLVShortVideoMediaPlayerVCDelegate <NSObject>

/// 返回事件
- (void)shortVideoMediaPlayerVC_BackEvent:(PLVShortVideoMediaPlayerVC *)playerVC;
/// 画中画状态回调
- (void)shortVideoMediaPlayerVC_PictureInPictureChangeState:(PLVShortVideoMediaPlayerVC *)playerVC state:(PLVPictureInPictureState )state;

/// 画中画开启失败
- (void)shortVideoMediaPlayerVC_StartPictureInPictureFailed:(PLVShortVideoMediaPlayerVC *)playerVC error:(NSError *)error;

/// 即将开始播放
- (void)shortVideoMediaPlayerVC_playerIsPreparedToPlay:(PLVShortVideoMediaPlayerVC *)playerVC;
@end

NS_ASSUME_NONNULL_END
