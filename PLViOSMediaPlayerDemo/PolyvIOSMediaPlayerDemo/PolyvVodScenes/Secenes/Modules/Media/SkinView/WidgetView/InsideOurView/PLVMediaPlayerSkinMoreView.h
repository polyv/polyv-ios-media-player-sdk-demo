//
//  PLVMediaPlayerSkinMoreView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/10.
//

#import <UIKit/UIKit.h>
#import "PLVMediaPlayerState.h"
#import "PLVDownloadCircularProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaPlayerSkinMoreViewDelegate ;

@interface PLVMediaPlayerSkinMoreView : UIView

@property (nonatomic, weak) id<PLVMediaPlayerSkinMoreViewDelegate> delegate;
@property (nonatomic, strong) PLVMediaPlayerState *mediaPlayerState;

-(void)showMoreViewWithModel:(PLVMediaPlayerState *)mediaPlayerState;
/// 下载进度控件  涉及到动态交互  对外开放方便访问控制
/// 具体控制逻辑在 PLVVodMediaAreaVC 中
@property (nonatomic, strong) PLVDownloadCircularProgressView *downloadProgressView;

@end

@protocol PLVMediaPlayerSkinMoreViewDelegate <NSObject>

/// 音频/ 视频播放模式切换
- (void)mediaPlayerSkinMoreView_SwitchPlayMode:(PLVMediaPlayerSkinMoreView *)moreView;
/// 开启画中画
- (void)mediaPlayerSkinMoreView_StartPictureInPicture:(PLVMediaPlayerSkinMoreView *)moreView;
/// 设置字幕
- (void)mediaPlayerSkinMoreView_SetSubtitle:(PLVMediaPlayerSkinMoreView *)moreView;
/// 开始下载
- (void)mediaPlayerSkinMoreView_StartDownload;

@end

NS_ASSUME_NONNULL_END
