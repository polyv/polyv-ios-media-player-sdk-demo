//
//  PLVVodMediaPlayerVC.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/9.
//

#import <UIKit/UIKit.h>
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVMediaPlayerState.h"
#import "PLVVodMediaPlayerSkinContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVVodMediaAreaVCDelegate;

/// 长视频 - 视频区域
///    不是完成的页面ViewController，而只是负责视频区域
///    media 前缀属性 代表是 视频区域 的模块，属于Demo层开源的场景代码
///    player 前缀属性 代表是 播放器 的模块，属于SDK层闭源的功能代码
@interface PLVVodMediaAreaVC : UIViewController

/// 播放器 - 核心的裸播放器，不包括皮肤层
@property (nonatomic, strong) PLVVodMediaPlayer *player;

/// 播放器 对应的 在 视频区域中显示 的皮肤容器
@property (nonatomic, strong) PLVVodMediaPlayerSkinContainerView *mediaSkinContainer;

/// 播放器 和 视频区域 之间 状态同步 所使用的 数据模型
@property (nonatomic, strong) PLVMediaPlayerState *mediaPlayerState;

/// 视频区域 代理回调
@property (nonatomic, weak) id<PLVVodMediaAreaVCDelegate> mediaAreaVcDelegate;

// vid 播放
- (void)playWithVid:(NSString *)vid;

// 播放
- (void)replay;

// 播放速度
- (void)setPlayRate:(CGFloat)rate;

// 切换清晰度
- (void)setPlayQuality:(NSInteger )qualityLevel;

// 切换音频、视频播放模式
- (void)setPlaykMode:(PLVVodMediaPlaybackMode )playbackMode;

// 显示播放完毕视图
- (void)showPlayFinishUI;

// 更新字幕
- (void)updateVideoSubtile;

@end

@protocol PLVVodMediaAreaVCDelegate <NSObject>

/// 更多菜单
- (void)vodMediaAreaVC_ShowMoreView:(PLVVodMediaAreaVC *)playerVC;

/// 返回事件
- (void)vodMediaAreaVC_BackEvent:(PLVVodMediaAreaVC *)playerVC;

/// 播放结束事件
- (void)vodMediaAreaVC_PlayFinishEvent:(PLVVodMediaAreaVC *)playerVC;

/// 画中画状态回调
- (void)vodMediaAreaVC_PictureInPictureChangeState:(PLVVodMediaAreaVC *)playerVC state:(PLVPictureInPictureState )state;

/// 画中画开启失败
- (void)vodMediaAreaVC_StartPictureInPictureFailed:(PLVVodMediaAreaVC *)playerVC error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
