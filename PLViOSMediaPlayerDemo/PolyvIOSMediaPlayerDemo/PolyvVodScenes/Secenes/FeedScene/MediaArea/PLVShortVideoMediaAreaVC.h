//
//  PLVSkinVodMediaPlayerVC.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/29.
//

#import <UIKit/UIKit.h>
#import "PLVFeedViewDefine.h"
#import "PLVFeedData.h"
#import "PLVShortVideoMediaPlayerSkinContainer.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>


NS_ASSUME_NONNULL_BEGIN

@protocol PLVShortVideoMediaAreaVCDelegate;

/// 短视频 - 视频区域
///    不是完成的页面ViewController，而只是负责视频区域
///    media 前缀属性 代表是 视频区域 的模块，属于Demo层开源的场景代码
///    player 前缀属性 代表是 播放器 的模块，属于SDK层闭源的功能代码
@interface PLVShortVideoMediaAreaVC : UIView <
PLVFeedItemCustomViewDelegate // 遵循该协议才能嵌
>

/// 播放器 - 核心的裸播放器，不包括皮肤层
@property (nonatomic, strong) PLVVodMediaPlayer *player;

/// 播放器 对应的 在 视频区域中显示 的皮肤容器
@property (nonatomic, strong) PLVShortVideoMediaPlayerSkinContainer *mediaSkinContainer;

/// 播放器 和 视频区域 之间 状态同步 所使用的 数据模型
@property (nonatomic, strong) PLVMediaPlayerState *mediaPlayerState;

/// 视频区域 代理回调
@property (nonatomic, weak) id<PLVShortVideoMediaAreaVCDelegate> mediaAreaVcDelegate;

/// 视频 vid
@property (nonatomic, copy) NSString *vid;

@property (nonatomic, strong) PLVFeedData *feedData;

@property (nonatomic, assign) BOOL isActive;

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

// 播放速度
- (void)setPlayRate:(CGFloat)rate;

/// 显示视频模式UI
- (void)showVideoModeUI;

/// 视图出现
- (void)startActive;

/// 视图消失
- (void)endActive;

/// 隐藏返回按钮
- (void)hideProtraitBackButton;

/// 横竖屏切换，手动适配UI
- (void)adaptUIForLandscape;


@end

@protocol PLVShortVideoMediaAreaVCDelegate <NSObject>

/// 返回事件
- (void)shortVideoMediaAreaVC_BackEvent:(PLVShortVideoMediaAreaVC *)playerVC;

/// 播放完毕
- (void)shortVideoMediaAreaVC_PlayFinishEvent:(PLVShortVideoMediaAreaVC *)mediaAreaVC;

/// 切换为激活状态
- (void)shortVideoMediaAreaVC_BecomeActive:(PLVShortVideoMediaAreaVC *)mediaAreaVC;

/// 切换为非激活状态
- (void)shortVideoMediaAreaVC_EndActive:(PLVShortVideoMediaAreaVC *)mediaAreaVC;

/// 画中画状态回调
- (void)shortVideoMediaAreaVC_PictureInPictureChangeState:(PLVShortVideoMediaAreaVC *)playerVC state:(PLVPictureInPictureState )state;

/// 画中画开启失败
- (void)shortVideoMediaAreaVC_StartPictureInPictureFailed:(PLVShortVideoMediaAreaVC *)playerVC error:(NSError *)error;

/// 即将开始播放
- (void)shortVideoMediaAreaVC_playerIsPreparedToPlay:(PLVShortVideoMediaAreaVC *)playerVC;

// 需要push/present新页面时触发，由页面容器类push/present新页面
- (BOOL)shortVideoMediaAreaVC:(PLVShortVideoMediaAreaVC *)mediaAreaVC pushController:(UIViewController *)vctrl;


@end

NS_ASSUME_NONNULL_END
