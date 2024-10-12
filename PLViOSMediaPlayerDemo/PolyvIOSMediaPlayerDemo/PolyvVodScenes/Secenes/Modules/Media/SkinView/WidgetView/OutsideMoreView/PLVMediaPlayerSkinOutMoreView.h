//
//  PLVMediaPlayerSkinOutMoreView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/10.
//

#import <UIKit/UIKit.h>
#import "PLVMediaPlayerState.h"
#import "PLVDownloadCircularProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaPlayerSkinOutMoreViewDelegate ;

@interface PLVMediaPlayerSkinOutMoreView : UIView

@property (nonatomic, weak) id<PLVMediaPlayerSkinOutMoreViewDelegate> skinOutMoreViewDelegate;

/// 播放器皮肤实时状态数据
@property (nonatomic, strong) PLVMediaPlayerState *mediaPlayerState;
/// 下载进度控件  涉及到动态交互  对外开放方便访问控制
/// 具体控制逻辑在 PLVVodMediaAreaVC 中
@property (nonatomic, strong) PLVDownloadCircularProgressView *downloadProgressView;


-(void)showMoreView;
-(void)showMoreViewWithModel:(PLVMediaPlayerState *)mediaPlayerState;
-(void)hideMoreView;

@end

@protocol PLVMediaPlayerSkinOutMoreViewDelegate <NSObject>

/// 切换播放速度
- (void)mediaPlayerSkinOutMoreView_SwitchPlayRate:(CGFloat )rate;
/// 切换清晰度
- (void)mediaPlayerSkinOutMoreView_SwitchQualityLevel:(NSInteger )qualityLevel;
/// 音视频模式切换
- (void)mediaPlayerSkinOutMoreView_SwitchPlayMode:(PLVMediaPlayerSkinOutMoreView *)outMoreView;
/// 画中画
- (void)mediaPlayerSkinOutMoreView_StartPictureInPicture;
/// 设置字幕
- (void)mediaPlayerSkinOutMoreView_SetSubtitle;
/// 开始下载
- (void)mediaPlayerSkinOutMoreView_StartDownload;

@end

NS_ASSUME_NONNULL_END
