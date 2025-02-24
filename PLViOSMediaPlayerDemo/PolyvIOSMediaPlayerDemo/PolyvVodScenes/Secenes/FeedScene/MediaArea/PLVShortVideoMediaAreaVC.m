//
//  PLVSkinVodMediaPlayerVC.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/29.
//

#import "PLVShortVideoMediaAreaVC.h"
#import "PLVMediaAreaPortraitFullSkinView.h"
#import <PLVIJKPlayer/PLVIJKPlayer.h>
#import "PLVMediaPlayerSkinOutMoreView.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Accelerate/Accelerate.h>
#import "PLVVodMediaToast.h"
#import "PLVVodMediaErrorUtil.h"
#import "PLVVodMediaOrientationUtil.h"
#import "UIImage+PLVVodMediaTint.h"
#import "PLVVodMediaMarqueeView.h"
#import "PLVMediaPlayerConst.h"
#import "PLVMediaPlayerSubtitleModule.h"
#import "PLVDownloadCenterViewController.h"
#import "PLVSecureView.h"
#import <PLVTimer.h>


/// UI View Hierarchy
///
/// (UIView) self
///  ├── (PLVVodMediaPlayer) player
///  ├── (PLVShortVideoMediaPlayerSkinContainer) mediaSkinContainer
///  ├── (PLVMediaPlayerSkinOutMoreView) skinOutMoreView
///  ├── (UIImageView) displayCoverView

@interface PLVShortVideoMediaAreaVC ()<
PLVMediaPlayerCoreDelegate,
PLVVodMediaPlayerDelegate,
PLVShortVideoMediaPlayerSkinContainerDelegate,
PLVMediaPlayerSkinOutMoreViewDelegate
>

/// UI 部分
@property (nonatomic, strong) PLVMediaPlayerSkinOutMoreView *skinOutMoreView;
@property (nonatomic, strong) UIImageView *displayCoverView; // 视频封面图
@property (nonatomic, strong) PLVVodMediaMarqueeView *marqueeView; // 跑马灯
@property (nonatomic, strong) PLVMediaPlayerSubtitleModule *subtitleModule; /// 字幕模块


// 布局 部分 - 用于 横竖屏切换
@property (nonatomic, strong) UIView *displayView; // 裸播放器对应的渲染View，展示视频画面
@property (nonatomic, assign) CGRect originFrame;  // 视频区域原始尺寸
@property (nonatomic, assign) UIView *originSuperView; // 视频区域原始父视图

/// 状态控制 部分
@property (nonatomic, assign) BOOL isShowInUIWindow;

/// timer UI 相关刷新
@property (nonatomic, strong) PLVTimer *playbackTimer;     /// 播放过程定时器，用于UI相关实时更新


@end

@implementation PLVShortVideoMediaAreaVC

@synthesize reuseIdentifier;

#pragma mark 【Life Cycle】
- (void)dealloc{
    [self.player clearPlayer];
    [self.marqueeView stop];
    [self.playbackTimer cancel];
    self.playbackTimer = nil;
    self.displayCoverView = nil;
}

-(instancetype)init{
    if (self = [super init]){
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (!self.originSuperView) {
        self.originSuperView = self.superview;
        self.originFrame = self.originSuperView.bounds;
    }
    
    if (self.originSuperView) {
        [self updateUI];
    }
}

#pragma mark 【UI setup & update】
- (void)setupUI {
    self.backgroundColor = [UIColor colorWithRed:32/255.0 green:38/255.0 blue:57.0/255.0 alpha:1.0];
    
    [self addSubview:self.displayView];
    [self.player setupDisplaySuperview:self.displayView];
    
    [self addSubview:self.mediaSkinContainer];
    [self addSubview:self.skinOutMoreView];
    [self addSubview:self.displayCoverView];
    
    // 设置新版跑马灯（2.0）
    [self initMarqueeView];
    
    // 设置刷新定时器
    [self setupPlaybackTimer];
    
    // 设置下载事件
    [self initDownloadModule];
}

- (void)updateUI{
    BOOL isLandscape = [PLVVodMediaOrientationUtil isLandscape];
    if (isLandscape){ // 横向-全屏
        if (!self.isActive) { // 非当前feedView显示的item，不响应横屏切换
            return;
        }
        
        if (self.mediaPlayerState.ratio <= 1) { // 视频方向是竖向的，不支持横向-全屏切换
            return;
        }
        
        [self addToUIWindow];
        self.frame = [UIScreen mainScreen].bounds;
        
        self.displayView.frame = self.bounds;
        self.displayView.center = self.center;
    } else { // 竖屏-全屏
        [self removeFromUIWindow];
        self.frame = self.originFrame;
        
        if (self.mediaPlayerState.ratio != 0) {
            if (self.player.playbackMode == PLVVodMediaPlaybackModeAudio){
                CGFloat display_height = self.bounds.size.width*9/16;
                self.displayView.frame = CGRectMake(0, 0, self.bounds.size.width, display_height);
            }
            else{
                CGFloat display_height = self.bounds.size.width/self.mediaPlayerState.ratio;
                if (display_height <= self.bounds.size.height){
                    self.displayView.frame = CGRectMake(0, 0, self.bounds.size.width, display_height);
                }
                else{
                    // 全屏展示
                    self.displayView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
                }
            }
            self.displayView.center = self.center;
        }
        
        self.skinOutMoreView.frame = self.bounds;
    }
    
    self.displayCoverView.bounds = self.displayView.bounds;
    self.displayCoverView.center = self.center;
    self.mediaSkinContainer.frame = self.bounds;
    self.mediaSkinContainer.center = self.center;
}

- (void)initMarqueeView{
    self.marqueeView = [[PLVVodMediaMarqueeView alloc] init];
    PLVVodMediaMarqueeModel *marqueeModel = [[PLVVodMediaMarqueeModel alloc] init];
    self.marqueeView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.marqueeView.frame = self.displayView.bounds;
    [self.marqueeView setPLVVodMediaMarqueeModel:marqueeModel];
    [self.displayView addSubview:self.marqueeView];
}

#pragma mark [player timer]
- (void)setupPlaybackTimer{
    __weak typeof(self) weakSelf = self;
    self.playbackTimer = [PLVTimer repeatWithInterval:0.5 repeatBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // 同步更新字幕内容 字幕布局
            if(weakSelf.mediaPlayerState.subtitleConfig.subtitlesEnabled){
                [weakSelf.subtitleModule showSubtilesWithPlaytime:weakSelf.player.currentPlaybackTime];
                // 更新字幕位置
                [weakSelf.mediaSkinContainer updateSubtitleViewUIWithDouble:weakSelf.mediaPlayerState.subtitleConfig.isCurDouble];
                
            }
        });
    }];
}

#pragma mark 【Back 页面返回处理】

#pragma mark 【Getter & Setter】
- (PLVVodMediaPlayer *)player{
    if (!_player){
        _player = [[PLVVodMediaPlayer alloc] init];
        _player.delegateVodMediaPlayer = self;
        _player.coreDelegate = self;
        _player.autoPlay = NO;
        _player.videoToolBox = NO;
        _player.rememberLastPosition = YES;
        _player.enablePIPInBackground = YES;
        _player.keepPlay = NO;
        _player.seekType = PLVVodMediaPlaySeekTypePrecise;
    }
    return _player;
}

- (PLVShortVideoMediaPlayerSkinContainer *)mediaSkinContainer{
    if (!_mediaSkinContainer){
        _mediaSkinContainer = [[PLVShortVideoMediaPlayerSkinContainer alloc] init];
        _mediaSkinContainer.containerDelegate = self;
    }
    return _mediaSkinContainer;
}

- (PLVMediaPlayerSkinOutMoreView *)skinOutMoreView{
    if (!_skinOutMoreView){
        _skinOutMoreView = [[PLVMediaPlayerSkinOutMoreView alloc] init];
        _skinOutMoreView.hidden = YES;
        _skinOutMoreView.skinOutMoreViewDelegate = self;
    }
    return _skinOutMoreView;
}

- (UIImageView *)displayCoverView{
    if (!_displayCoverView){
        _displayCoverView = [[UIImageView alloc] init];
    }
    return _displayCoverView;
}

- (PLVMediaPlayerState *)mediaPlayerState{
    if (!_mediaPlayerState){
        _mediaPlayerState = [[PLVMediaPlayerState alloc] init];
    }
    return _mediaPlayerState;
}

- (UIView *)displayView{
    if (!_displayView){
        _displayView = [[UIView alloc] init];;
        _displayView.backgroundColor = [UIColor blackColor];
    }
    return _displayView;
}

- (PLVMediaPlayerSubtitleModule *)subtitleModule{
    if (!_subtitleModule){
        _subtitleModule = [[PLVMediaPlayerSubtitleModule alloc] init];
    }
    
    return _subtitleModule;
}

// 跑马灯播放控制
- (void)marqueeControlWithState:(PLVPlaybackState )playState{
    //新版跑马灯的启动暂停控制
    if (playState == PLVPlaybackStatePlaying) {
        [self.marqueeView start];
    }else if (playState == PLVPlaybackStatePaused) {
        [self.marqueeView pause];
    }else if (playState == PLVPlaybackStateStopped) {
        [self.marqueeView stop];
    }
}

- (void)setSysScreenShotProtect:(BOOL)sysScreenShotProtect{
    if (sysScreenShotProtect){
        [self.displayView removeFromSuperview];
        self.displayView = [[PLVSecureView alloc] init].secureView;
        [self insertSubview:self.displayView atIndex:0];
        [self.player setupDisplaySuperview:self.displayView];
    }
}

#pragma mark 【Public Method】
- (void)playWithVid:(NSString *)vid{
    self.vid = vid;
    if ([PLVVodMediaVideo isVideoCached:self.vid]){
        // 获取离线视频信息
        [PLVVodMediaVideo requestVideoPriorityCacheWithVid:self.vid completion:^(PLVVodMediaVideo *video, NSError *error) {
            [self playWithVideoModel:video];
        }];
    }
    else{
        [PLVVodMediaVideo requestVideoWithVid:vid completion:^(PLVVodMediaVideo *video, NSError *error) {
            [self playWithVideoModel:video];
        }];
    }
    
    /// 设置vid 的同时 配置下载回调逻辑
    [self initDownloadModule];
}

- (void)playWithVideoModel:(PLVVodMediaVideo *)videlModel{
    [self.player setVideo:videlModel];
    
    // 同步播放器状态
    [self syncPlayerStateWithModel:videlModel];
}

- (void)play{
    [self.player play];
}

- (void)pause{
    [self.player pause];
}

- (void)destroyPlayer{
    [self.player clearMainPlayer];
}

- (BOOL)isPlaying{
    return [self.player playing];
}

- (void)setPlayRate:(CGFloat)rate{
    [self.player switchSpeedRate:rate];
}

- (void)showVideoModeUI{
    [self.mediaSkinContainer showVideoModeUI];
}

- (void)startActive{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self play];
        
        // 刷新下载状态
        [self initDownloadModule];
    });
}

- (void)endActive{
    [self.player pause];
    self.mediaSkinContainer.portraitFullSkinView.playButton.selected = NO;
    self.mediaSkinContainer.portraitFullSkinView.playButton.hidden = YES;

    // 关闭菜单
    [self.skinOutMoreView hideMoreView];
}

- (void)setPlayMode:(PLVVodMediaPlaybackMode)playbackMode {
    // 播放源切换
    self.mediaPlayerState.isChangingPlaySource = YES;
    if (playbackMode == PLVVodMediaPlaybackModeAudio) {
        [self.player setPlaybackMode:PLVVodMediaPlaybackModeAudio];
        [self.displayView setHidden:YES];

        self.mediaPlayerState.curPlayMode = PLVMediaPlayerPlayModeAudio;
        [self.mediaSkinContainer showAudioModeUI];
    } else {
        [self.player setPlaybackMode:PLVVodMediaPlaybackModeVideo];
        [self.displayView setHidden:NO];

        self.mediaPlayerState.curPlayMode = PLVMediaPlayerPlayModeVideo;
        [self.mediaSkinContainer showVideoModeUI];
    }
}

- (void)hideProtraitBackButton {
    self.mediaSkinContainer.portraitFullSkinView.backButton.hidden = YES;
}

- (void)adaptUIForLandscape{
    if (!self.originSuperView) {
        self.originSuperView = self.superview;
        self.originFrame = self.originSuperView.bounds;
    }
    
    if (self.originSuperView) {
        [self updateUI];
    }
}

/// 更新字幕
- (void)updateVideoSubtile{
    [self.subtitleModule updateSubtitleWithName:self.mediaPlayerState.subtitleConfig.selectedSubtitleKey
                                         show:self.mediaPlayerState.subtitleConfig.subtitlesEnabled];
}

#pragma mark 【Syn Method  同步 player、mediaState、mediaSkinContainer 之间的数据】
- (void)syncPlayerStateWithModel:(PLVVodMediaVideo *)videoModel{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mediaPlayerState.curQualityLevel = videoModel.preferredQuality;
        self.mediaPlayerState.qualityCount = videoModel.qualityCount;
        self.mediaPlayerState.isSupportAudioMode = [videoModel canSwithPlaybackMode];
        
        self.mediaPlayerState.snapshot = videoModel.snapshot;
        self.mediaPlayerState.ratio = videoModel.ratio;
        self.mediaPlayerState.videoTitle = videoModel.title;
        
        self.mediaPlayerState.progressImageString = videoModel.progressImage;
        self.mediaPlayerState.duration = videoModel.duration;
        
        // 封面图设置
        __weak typeof(self) weakSelf = self;
        // 最大内存缓存 5张图片
        [SDWebImageManager sharedManager].imageCache.maxMemoryCost = 5;
        [self.displayCoverView sd_setImageWithURL:[NSURL URLWithString:videoModel.snapshot] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image && [image isKindOfClass:[UIImage class]]){
                UIImage *blurimage = [UIImage boxblurImageWithBlur:0.2 image:image];
                weakSelf.displayCoverView.image = blurimage;
            }
        }];
        
        // 字幕信息配置
        self.mediaPlayerState.subtitleConfig = [[PLVMediaPlayerSubtitleConfigModel alloc] initWithVideoModel:videoModel];
        // 加载字幕信息
        [self.subtitleModule loadSubtitlsWithVideoModel:videoModel
                                                  label:self.mediaSkinContainer.subtitleView.subtitleLabel
                                               topLabel:self.mediaSkinContainer.subtitleView.subtitleTopLabel
                                                 label2:self.mediaSkinContainer.subtitleView.subtitleLabel2
                                              topLabel2:self.mediaSkinContainer.subtitleView.subtitleTopLabel2];
        // 同步播放器皮肤
        [self.mediaSkinContainer syncSkinWithMode:self.mediaPlayerState];
        
        [self updateUI];
    });
}

- (void)synPlayRate:(CGFloat)rate {
    [self.player switchSpeedRate:rate];
    self.mediaPlayerState.curPlayRate = rate;

    // 刷新皮肤
    [self.mediaSkinContainer.landscapeFullSkinView updatePlayRate:rate];
}

- (void)synPlayQuality:(NSInteger)qualityLevel {
    [self.player setPlayQuality:(PLVVodMediaQuality)qualityLevel];
    self.mediaPlayerState.isChangingPlaySource = YES;
    self.mediaPlayerState.curQualityLevel = qualityLevel;

    // 刷新皮肤
    [self.mediaSkinContainer.landscapeFullSkinView updateQualityLevel:qualityLevel];
    // 显示清晰度切换状态
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mediaPlayerState.qualityState = PLVMediaPlayerQualityStateChanging;
        [self.mediaSkinContainer showDefinitionTipsView];
    });
}

#pragma mark 【Orientation 横竖屏设置】
/// 切换到 竖向-半屏皮肤
- (void)changeToProtrait{
    [PLVVodMediaOrientationUtil changeUIOrientation:UIDeviceOrientationPortrait];
}

/// 切换到 横向时，把当前 mediaArea 整体View 从 originSuperView 移动到 UIWindow
- (void)addToUIWindow {
    if (!self.isShowInUIWindow) {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        if (!keyWindow) {
            keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
        }
        [keyWindow addSubview:self];
        self.isShowInUIWindow = YES;
    }
}

/// 切换到 竖向时，把当前 mediaArea 整体View 从 UIWindow 移回到 originSuperView
- (void)removeFromUIWindow{
    if (self.isShowInUIWindow) {
        [self removeFromSuperview];
        [self.originSuperView addSubview:self];
        self.isShowInUIWindow = NO;
    }
}

#pragma mark 【PLVMediaPlayerCore Delegate 播放器核心（播放状态时间）的回调方法】
/// 播放器 ’加载状态‘ 发生改变
-(void)plvMediaPlayerCore:(PLVMediaPlayerCore *)player playerLoadStateDidChange:(PLVPlayerLoadState)loadState{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

/// 播放器 已准备好播放
- (void)plvMediaPlayerCore:(PLVMediaPlayerCore *)player playerIsPreparedToPlay:(BOOL)prepared{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // 同步播放速率
    [self synPlayRate:self.mediaPlayerState.curPlayRate];

    // 短视频场景，切换播放源后需要自动播放
    if (self.mediaPlayerState.isChangingPlaySource){
        [player play];
    }
    
    // 提示续播进度
    if (player.currentPlaybackTime > PLVMediaPlayerShowProgressTime && !self.mediaPlayerState.isChangingPlaySource){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mediaSkinContainer showPlayProgressToastView:player.currentPlaybackTime];
        });
    }
    
    // 代理回调
    if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(shortVideoMediaAreaVC_playerIsPreparedToPlay:)]){
        [self.mediaAreaVcDelegate shortVideoMediaAreaVC_playerIsPreparedToPlay:self];
    }
    
    // 未切换或切换成功
    self.mediaPlayerState.isChangingPlaySource = NO;
}

/// 播放器 ‘播放状态’ 发生改变
- (void)plvMediaPlayerCore:(PLVMediaPlayerCore *)player playerPlaybackStateDidChange:(PLVPlaybackState)playbackState{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    BOOL isPlaying = (playbackState == PLVPlaybackStatePlaying ||
                      playbackState == PLVPlaybackStateSeekingForward ||
                      playbackState == PLVPlaybackStateSeekingBackward);
    // 同步播放器皮肤
    self.mediaPlayerState.isPlaying = isPlaying;
    [self.mediaSkinContainer.landscapeFullSkinView setPlayButtonWithPlaying:isPlaying];
    [self.mediaSkinContainer.portraitFullSkinView setPlayButtonWithPlaying:isPlaying];
    
    // 跑马灯控制
    [self marqueeControlWithState:playbackState];
    
    // 清晰度切换状态刷新
    if (self.mediaPlayerState.qualityState == PLVMediaPlayerQualityStateChanging){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mediaPlayerState.qualityState = PLVMediaPlayerQualityStateComplete;
            [self.mediaSkinContainer showDefinitionTipsView];
        });
    }
    
    //
}

/// 播放器 播放结束
- (void)plvMediaPlayerCore:(PLVMediaPlayerCore *)player playerPlaybackDidFinish:(PLVPlayerFinishReason)finishReson{
    if (PLVPlayerFinishReasonPlaybackEnded == finishReson){
        if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(shortVideoMediaAreaVC_PlayFinishEvent:)]){
            [self.mediaAreaVcDelegate shortVideoMediaAreaVC_PlayFinishEvent:self];
        }
    }
    // 清理播放器UI 浮动控件
    if (self.mediaPlayerState.qualityState != PLVMediaPlayerQualityStateDefault){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mediaPlayerState.qualityState = PLVMediaPlayerQualityStateDefault;
            [self.mediaSkinContainer showDefinitionTipsView];
        });
    }
}

- (void)plvMediaPlayerCore:(PLVMediaPlayerCore *)player firstFrameRendered:(BOOL)rendered{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 封面图移除
        [self.displayCoverView removeFromSuperview];
    });
}

#pragma mark 【PLVVodMediaPlayerDelegate 播放器的回调方法】
/// 播放器 定时返回当前播放进度
- (void)PLVVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer
           playedProgress:(CGFloat)playedProgress
         playedTimeString:(NSString *)playedTimeString
       durationTimeString:(NSString *)durationTimeString{
    [self.mediaSkinContainer.landscapeFullSkinView setProgressWithCachedProgress:0
                                                    playedProgress:playedProgress
                                                      durationTime:vodMediaPlayer.duration
                                                 currentTimeString:playedTimeString
                                                    durationString:durationTimeString];
    [self.mediaSkinContainer.portraitFullSkinView setProgressWithCachedProgress:0
                                                        playedProgress:playedProgress
                                                          durationTime:vodMediaPlayer.duration
                                                     currentTimeString:playedTimeString
                                                        durationString:durationTimeString];
}

/// 画中画 状态回调
- (void)PLVVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer pictureInPictureChangeState:(PLVPictureInPictureState)pipState{
    if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(shortVideoMediaAreaVC_PictureInPictureChangeState:state:)]){
        [self.mediaAreaVcDelegate shortVideoMediaAreaVC_PictureInPictureChangeState:self state:pipState];
    }
   
    // 画中画结束
    if (pipState == PLVPictureInPictureStateDidEnd ||
        pipState == PLVPictureInPictureStateWillEnd ||
        pipState == PLVPictureInPictureStateError){
        // 恢复皮肤状态
        self.mediaPlayerState.curWindowMode = PLVMediaPlayerWindowModeDefault;
        [self.mediaSkinContainer syncSkinWithMode:self.mediaPlayerState];
        if (pipState != PLVPictureInPictureStateWillEnd){
            [self.mediaSkinContainer showPicInPicPlaceholderViewWithStatus:NO];
        }
    }
    else if (pipState == PLVPictureInPictureStateWillStart){
        [self.mediaSkinContainer showPicInPicPlaceholderViewWithStatus:YES];
    }
}

/// 画中画 开启失败
- (void)PLVVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer startPictureInPictureWithError:(NSError *)error{
    // 画中画开启失败
    if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(shortVideoMediaAreaVC_StartPictureInPictureFailed:error:)]){
        [self.mediaAreaVcDelegate shortVideoMediaAreaVC_StartPictureInPictureFailed:self error:error];
    }
    
    // 恢复皮肤状态
    self.mediaPlayerState.curWindowMode = PLVMediaPlayerWindowModeDefault;
    [self.mediaSkinContainer showPicInPicPlaceholderViewWithStatus:NO];
    [self.mediaSkinContainer syncSkinWithMode:self.mediaPlayerState];

    // 抛出错误提示
    if ([error.domain isEqualToString:PLVVodMediaErrorDomain]) {
        NSString *message = [NSString stringWithFormat:@"%@", [PLVVodMediaErrorUtil getErrorMsgWithCode:error.code]];
        [PLVVodMediaToast showMessage:message];
    }else {
        NSString *message = [NSString stringWithFormat:@"%@", error.localizedFailureReason];
        [PLVVodMediaToast showMessage:message];
    }
}

- (void)PLVVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer poorNetworkState:(BOOL)poorState {
    if (poorState) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mediaPlayerState.qualityState = PLVMediaPlayerQualityStatePrepare;
            [self.mediaSkinContainer showDefinitionTipsView];
        });
    }
}

#pragma mark 【PLVShortVideoMediaPlayerSkinContainer Delegate 皮肤容器的回调方法】
/// 竖向-全屏皮肤时，显示外部 moreview 视图
- (void)mediaPlayerSkinContainer_ShowMoreView:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    [self bringSubviewToFront:self.skinOutMoreView];
    [self.skinOutMoreView showMoreViewWithModel:self.mediaPlayerState];
}

/// 返回 按钮事件 处理
- (void)mediaPlayerSkinContainer_BackEvent:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    if (self.isShowInUIWindow) { // 横向-全屏
        // 切换到 竖向-半屏
        [self changeToProtrait];
    } else { // 竖向-半屏
        // 触发 页面返回
        if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(shortVideoMediaAreaVC_BackEvent:)]){
            [self.mediaAreaVcDelegate shortVideoMediaAreaVC_BackEvent:self];
        }
    }
}

/// 全屏 按钮事件 处理
- (void)mediaPlayerSkinContainer_FullScreenClick:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    [PLVVodMediaOrientationUtil changeUIOrientation:UIDeviceOrientationLandscapeLeft];
}

/// 切换到视频模式 按钮事件 处理
- (void)mediaPlayerSkinContainer_SwitchToVideoMode:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    [self setPlayMode:PLVVodMediaPlaybackModeVideo];
}

/// 切换到音频模式 按钮事件 处理
- (void)mediaPlayerSkinContainer_SwitchToAudioMode:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    [self setPlayMode:PLVVodMediaPlaybackModeAudio];
}

/// 画中画 按钮事件 处理
- (void)mediaPlayerSkinContainer_StartPictureInPicture:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    if ([PLVMediaPlayerPictureInPictureManager sharedInstance].pictureInPictureActive) {
        [self.player stopPictureInPicture];
    }else {
        // 横屏状态，需要先返回竖屏状态
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            [PLVVodMediaOrientationUtil changeUIOrientation:UIDeviceOrientationPortrait];
        }
        [self.player startPictureInPicture];
    }
}

/// 切换清晰度  按钮事件 处理
- (void)mediaPlayerSkinContainer_SwitchQualtiy:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer qualityLevel:(NSInteger)qualityLevel{
    [self synPlayQuality:qualityLevel];
}

/// 切换播放速度  按钮事件 处理
- (void)mediaPlayerSkinContainer_SwitchPlayRate:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer playRate:(CGFloat)playRate{
    [self synPlayRate:playRate];
}

/// 播放/暂停  按钮事件 处理
- (void)mediaPlayerSkinContainer_Play:(PLVShortVideoMediaPlayerSkinContainer *)skin willPlay:(BOOL)willPlay{
    if (willPlay){
        [self play];
    }
    else{
        [self.player pause];
    }
}

/// 进度面板 手势事件 处理
- (void)mediaPlayerSkinContainer_ProgressViewPan:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer scrubTime:(NSTimeInterval)scrubTime{
    [self.player seekToTime:scrubTime];
    [self.player play];
}

/// 进度条 拖动事件 处理
- (void)mediaPlayerSkinContainer_SliderDragEnd:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer sliderValue:(CGFloat)sliderValue{
    NSTimeInterval currentTime = self.player.duration * sliderValue;
    // 拖动进度条后，同步当前进度时间
    [self.player seekToTime:currentTime];
    [self.player play];
}

- (void)removeDisplayCoverView{
    if (!self.displayCoverView.hidden){
        UIVisualEffectView *visualView = nil;
        for (UIView *item in self.displayCoverView.subviews){
            if ([item isKindOfClass:[UIVisualEffectView class]]){
                visualView = (UIVisualEffectView*)item;
            }
        }
        [UIView animateWithDuration:0.3 animations:^{
            visualView.alpha = 0.8;
        } completion:^(BOOL finished) {
        }];
    }
}

/// 横屏 字幕选中事件
- (void)mediaPlayerSkinContainerView_SelectSubtitle:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    // 更新字幕
    [self updateVideoSubtile];
}

/// 横屏 开始下载
- (void)mediaPlayerSkinContainerView_StartDownload:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    [self startDownload];
}

#pragma mark 【PLVMediaPlayerSkinOutMoreView Delegate - 更多弹层 回调方法】
- (void)mediaPlayerSkinOutMoreView_SwitchPlayRate:(CGFloat)rate{
    [self synPlayRate:rate];
}

- (void)mediaPlayerSkinOutMoreView_SwitchQualityLevel:(NSInteger)qualityLevel{
    [self synPlayQuality:qualityLevel];
}

- (void)mediaPlayerSkinOutMoreView_SwitchPlayMode:(PLVMediaPlayerSkinOutMoreView *)outMoreView{
    if (PLVMediaPlayerPlayModeAudio == outMoreView.mediaPlayerState.curPlayMode){
        [self setPlayMode:PLVVodMediaPlaybackModeAudio];
    }
    else if (PLVMediaPlayerPlayModeVideo == outMoreView.mediaPlayerState.curPlayMode){
        [self setPlayMode:PLVVodMediaPlaybackModeVideo];
    }
}

/// 开始画中画
- (void)mediaPlayerSkinOutMoreView_StartPictureInPicture{
    [self.player startPictureInPicture];
}

/// 设置字幕
- (void)mediaPlayerSkinOutMoreView_SetSubtitle{
    [self updateVideoSubtile];
}

/// 开始下载
- (void)mediaPlayerSkinOutMoreView_StartDownload{
    [self startDownload];
}

#pragma mark 【PLVFeedItemCustomView Delegate】
- (void)setActive:(BOOL)active {
    if (active) {
        [self notifySceneViewBecomeActive];
    } else {
        [self notifySceneViewEndActive];
    }
}

- (void)notifySceneViewBecomeActive {
    if (self.mediaAreaVcDelegate &&
        [self.mediaAreaVcDelegate respondsToSelector:@selector(shortVideoMediaAreaVC_BecomeActive:)]) {
        [self.mediaAreaVcDelegate shortVideoMediaAreaVC_BecomeActive:self];
    }
    
    // 播放器视图展示
    self.isActive = YES;
    [self startActive];
}

- (void)notifySceneViewEndActive {
    if (self.mediaAreaVcDelegate &&
        [self.mediaAreaVcDelegate respondsToSelector:@selector(shortVideoMediaAreaVC_EndActive:)]) {
        [self.mediaAreaVcDelegate shortVideoMediaAreaVC_EndActive:self];
    }
    
    // 播放器视图消失
    self.isActive = NO;
    [self endActive];
}

#pragma mark [下载相关业务逻辑处理]
- (void)startDownload{
    PLVDownloadInfo *downloadItem = [[PLVDownloadMediaManager sharedManager] getDownloadInfo:self.vid
                                                                               fileType:PLVDownloadFileTypeVideo];
    if (downloadItem){
        // 已经创建下载任务
        switch (downloadItem.state) {
            case PLVVodDownloadStatePreparing:
            case PLVVodDownloadStatePreparingTask:
            case PLVVodDownloadStateReady:
            case PLVVodDownloadStateStopping:
            case PLVVodDownloadStateStopped:{
                // 等待中 不处理 or (跳转下载中列表)
                [self pushToDownloadCenter:1];

            } break;
            case PLVVodDownloadStateRunning:{
                // 下载中 跳转下载中列表
                [self pushToDownloadCenter:1];

            } break;
            case PLVVodDownloadStateSuccess:{
                // 已完成 跳转完成列表
                [self pushToDownloadCenter:0];

            } break;
            case PLVVodDownloadStateFailed:{
                // 下载失败或者暂停 重新下载
                [self restartDownloadTask:downloadItem];

            } break;
        }
    }
    else{
        __weak typeof(self) weakSelf = self;
        // 调用可以缓存video 数据的方法
        [PLVVodMediaVideo requestVideoPriorityCacheWithVid:self.vid completion:^(PLVVodMediaVideo *video, NSError *error) {
            // 添加下载任务
            PLVDownloadInfo *downloadItem = [[PLVDownloadMediaManager sharedManager] addVideoTask:video
                                                                                     quality:weakSelf.mediaPlayerState.curQualityLevel];
            [weakSelf setDownloadEventWithItem:downloadItem];
        }];
    }
}

- (void)setDownloadEventWithItem:(PLVDownloadInfo *)downloadItem{
    __weak typeof(self) weakSelf = self;
    downloadItem.stateDidChangeBlock = ^(PLVDownloadInfo *info) {
        // 下载状态
        [weakSelf.skinOutMoreView.downloadProgressView updateDownloadState:info.state];
        [weakSelf.mediaSkinContainer.skinMoreView.downloadProgressView updateDownloadState:info.state];
    };
    downloadItem.progressDidChangeBlock = ^(PLVDownloadInfo *info) {
        // 下载进度
        [weakSelf.skinOutMoreView.downloadProgressView.progressView setProgress:info.progress];
        [weakSelf.mediaSkinContainer.skinMoreView.downloadProgressView.progressView setProgress:info.progress];
    };
}

- (void)initDownloadModule{
    PLVDownloadInfo *downloadItem = [[PLVDownloadMediaManager sharedManager] getDownloadInfo:self.vid
                                                                               fileType:PLVDownloadFileTypeVideo];
    if (downloadItem){
        [self setDownloadEventWithItem:downloadItem];
        // 更新一次下载状态
        [self.skinOutMoreView.downloadProgressView updateDownloadState:downloadItem.state];
        [self.mediaSkinContainer.skinMoreView.downloadProgressView updateDownloadState:downloadItem.state];
    }
    else{
        [self.skinOutMoreView.downloadProgressView resetProgressView];
        [self.mediaSkinContainer.skinMoreView.downloadProgressView resetProgressView];
    }
}

- (void)restartDownloadTask:(PLVDownloadInfo *)downloadInfo{
    [[PLVDownloadMediaManager sharedManager] startDownloadTask:downloadInfo highPriority:NO];
}

- (void)pushToDownloadCenter:(NSInteger )selectIndex{
    // 竖屏模式才跳转
    if (![PLVVodMediaOrientationUtil isLandscape]){
        PLVDownloadCenterViewController *center = [[PLVDownloadCenterViewController alloc] init];
        center.selectedIndex = selectIndex;
        if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(shortVideoMediaAreaVC:pushController:)]){
            [self.mediaAreaVcDelegate shortVideoMediaAreaVC:self pushController:center];
        }
    }
}


@end
