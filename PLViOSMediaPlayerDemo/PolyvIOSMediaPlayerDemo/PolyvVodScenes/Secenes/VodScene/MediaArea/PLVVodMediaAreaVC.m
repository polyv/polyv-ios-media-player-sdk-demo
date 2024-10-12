//
//  PLVVodMediaPlayerVC.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/9.
//

#import "PLVVodMediaAreaVC.h"
#import "PLVVodMediaOrientationUtil.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVVodMediaMarqueeView.h"
#import "PLVMediaPlayerSubtitleModule.h"
#import <PLVTimer.h>
#import "PLVMediaPlayerConst.h"

/// UI View Hierarchy
///
/// (UIView) self.view
///  ├── (PLVVodMediaPlayer) player
///  ├── (PLVVodMediaPlayerSkinContainerView) skinContainer

@interface PLVVodMediaAreaVC ()<
PLVMediaPlayerCoreDelegate,
PLVVodMediaPlayerDelegate,
PLVVodMediaPlayerSkinContainerViewDelegate
>

@property (nonatomic, strong) PLVVodMediaMarqueeView *marqueeView; /// 跑马灯
@property (nonatomic, strong) PLVMediaPlayerSubtitleModule *subtitleModule; /// 字幕模块
@property (nonatomic, strong) PLVTimer *playbackTimer;     /// 播放过程定时器，用于UI相关实时更新
@property (nonatomic, strong) NSString *vid; /// 视频ID
@property (nonatomic, strong) PLVVodMediaVideo *videoModel; /// 视频数据模型

@end

@implementation PLVVodMediaAreaVC

#pragma mark 【Life Cycle】
- (void)dealloc{
    [self.player clearPlayer];
    [self.marqueeView stop];
    [self.playbackTimer cancel];
    self.playbackTimer = nil;
    NSLog(@"PLVVodMediaAreaVC %@", NSStringFromSelector(_cmd));
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    [self updateUI];
}

#pragma mark 【UI setup & update】
- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    
    // 绑定 播放器核心
    [self.player setupDisplaySuperview:self.view];
    
    // 添加 播放器皮肤
    [self.view addSubview:self.mediaSkinContainer];
    
    // 根据业务需要进行配置
    // 广告、片头
//    self.player.enableAd = YES;
//    self.player.enableTeaser = YES;
    
    // seek 类型 精准seek
    self.player.seekType = PLVVodMediaPlaySeekTypePrecise;
    
    // 设置新版跑马灯（2.0）
    [self initMarqueeView];
    
    // 设置刷新定时器
    [self setupPlaybackTimer];
    
//    // 加密视频，配置外部传递token 播放
//    [self.player setRequestCustomKeyTokenBlock:^NSString * _Nonnull(NSString * _Nonnull vid) {
//        // 同步请求获取到token
//        return @"token";
//    }];
}

- (void)initMarqueeView{
    self.marqueeView = [[PLVVodMediaMarqueeView alloc] init];
    PLVVodMediaMarqueeModel *marqueeModel = [[PLVVodMediaMarqueeModel alloc] init];
    self.marqueeView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.marqueeView.frame = self.view.bounds;
    [self.marqueeView setPLVVodMediaMarqueeModel:marqueeModel];
    [self.view addSubview:self.marqueeView];
}

- (void)updateUI {
    [self updateUIForOrientation];
}

#pragma mark [player timer]
- (void)setupPlaybackTimer{
    __weak typeof(self) weakSelf = self;
    self.playbackTimer = [PLVTimer repeatWithInterval:0.5 repeatBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // 网络加载速度更新
            [weakSelf updateLoadSpeed];
            
            // 同步更新字幕内容 字幕布局
            if(weakSelf.mediaPlayerState.subtitleConfig.subtitlesEnabled){
                [weakSelf.subtitleModule showSubtilesWithPlaytime:weakSelf.player.currentPlaybackTime];
                // 更新字幕位置
                [weakSelf.mediaSkinContainer updateSubtitleViewUIWithDouble:weakSelf.mediaPlayerState.subtitleConfig.isCurDouble];
            }
        });
    }];
}

- (void)updateLoadSpeed{
    if (self.player.playerLoadState == PLVPlayerLoadStateStalled){
        [self.mediaSkinContainer updateLoadingSpeed:self.player.tcpSpeed];
    }
}

#pragma mark 【Getter & Setter】
- (PLVVodMediaPlayer *)player{
    if (!_player){
        _player = [[PLVVodMediaPlayer alloc] init];
        _player.coreDelegate = self;
        _player.delegateVodMediaPlayer = self;
        _player.autoPlay = YES;
        _player.videoToolBox = NO;
        _player.rememberLastPosition = YES;
        _player.enablePIPInBackground = YES;
    }
    return _player;
}

- (PLVVodMediaPlayerSkinContainerView *)mediaSkinContainer{
    if (!_mediaSkinContainer){
        _mediaSkinContainer = [[PLVVodMediaPlayerSkinContainerView alloc] init];
        _mediaSkinContainer.backgroundColor = [UIColor clearColor];
        _mediaSkinContainer.containerDelegate = self;
    }
    return _mediaSkinContainer;
}

- (PLVMediaPlayerState *)mediaPlayerState{
    if (!_mediaPlayerState){
        _mediaPlayerState = [[PLVMediaPlayerState alloc] init];
    }
    return _mediaPlayerState;
}

- (PLVMediaPlayerSubtitleModule *)subtitleModule{
    if (!_subtitleModule){
        _subtitleModule = [[PLVMediaPlayerSubtitleModule alloc] init];
    }
    
    return _subtitleModule;
}

#pragma mark [Private Method]
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
}

- (void)playWithVideoModel:(PLVVodMediaVideo *)videoModel{
    [self.player setVideo:videoModel];
    [self syncPlayerStateWithModel:videoModel]; // 同步播放器状态
    
    // 保存视频信息
    self.videoModel = videoModel;
}

- (void)setPlayRate:(CGFloat)rate{
    [self synPlayRate:rate];
}

- (void)setPlayQuality:(NSInteger)qualityLevel{
    [self synPlayQuality:qualityLevel];
}

- (void)setPlaykMode:(PLVVodMediaPlaybackMode)playbackMode{
    [self.player setPlaybackMode:playbackMode];
    self.mediaPlayerState.isChangingPlaySource = YES;
    if (playbackMode == PLVVodMediaPlaybackModeAudio) {
        // 音频模式
        self.mediaPlayerState.curPlayMode = PLVMediaPlayerPlayModeAudio;
        [self.mediaSkinContainer showAudioModeUI];
    } else {
        // 视频模式
        self.mediaPlayerState.curPlayMode = PLVMediaPlayerPlayModeVideo;
        [self.mediaSkinContainer showVideoModeUI];
    }
}

- (void)replay {
    [self.player play];
}

- (void)showPlayFinishUI {
    [self.mediaSkinContainer showLoopPlayUI];
}

- (void)updateVideoSubtile{
    [self.subtitleModule updateSubtitleWithName:self.mediaPlayerState.subtitleConfig.selectedSubtitleKey
                                           show:self.mediaPlayerState.subtitleConfig.subtitlesEnabled];
}

#pragma mark 【Syn Method  同步 player、mediaState、mediaSkinContainer 之间的数据】
- (void)syncPlayerStateWithModel:(PLVVodMediaVideo *)videoModel{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 视频区域 对应 播放器 的 实时数据模型
        self.mediaPlayerState.curQualityLevel = videoModel.preferredQuality;
        self.mediaPlayerState.qualityCount = videoModel.qualityCount;
        self.mediaPlayerState.isSupportAudioMode = [videoModel canSwithPlaybackMode];
        self.mediaPlayerState.snapshot = videoModel.snapshot;
        self.mediaPlayerState.ratio = videoModel.ratio;
        self.mediaPlayerState.videoTitle = videoModel.title;
        self.mediaPlayerState.progressImageString = videoModel.progressImage;
        self.mediaPlayerState.duration = videoModel.duration;
        // 字幕信息配置
        self.mediaPlayerState.subtitleConfig = [[PLVMediaPlayerSubtitleConfigModel alloc] initWithVideoModel:videoModel];
        // 加载字幕信息
        [self.subtitleModule loadSubtitlsWithVideoModel:videoModel
                                                  label:self.mediaSkinContainer.subtitleView.subtitleLabel
                                               topLabel:self.mediaSkinContainer.subtitleView.subtitleTopLabel
                                                 label2:self.mediaSkinContainer.subtitleView.subtitleLabel2
                                              topLabel2:self.mediaSkinContainer.subtitleView.subtitleTopLabel2];
        
        // 视频区域 对应 播放器 的皮肤
        [self.mediaSkinContainer syncSkinWithMode:self.mediaPlayerState];
        [self updateUI];
    });
}

- (void)synPlayRate:(CGFloat)rate {
    // 播放器核心 - 裸播放器
    [self.player switchSpeedRate:rate];
    // 视频区域 对应 播放器 的 实时数据模型
    self.mediaPlayerState.curPlayRate = rate;
    // 视频区域 对应 播放器 的皮肤
    [self.mediaSkinContainer.landscapeFullSkinView updatePlayRate:rate];
    
}

- (void)synPlayQuality:(NSInteger)qualityLevel {
    // 播放器核心 - 裸播放器
    [self.player setPlayQuality:(PLVVodMediaQuality)qualityLevel];
    // 视频区域 对应 播放器 的 实时数据模型
    self.mediaPlayerState.curQualityLevel = qualityLevel;
    // 视频区域 对应 播放器 的皮肤
    [self.mediaSkinContainer.landscapeFullSkinView updateQualityLevel:qualityLevel];
    // 半屏皮肤需要隐藏
    [self.mediaSkinContainer.portraitHalfSkinView hiddenMediaPlayerPortraitHalSkinView:YES];
    // 显示清晰度切换状态
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mediaPlayerState.qualityState = PLVMediaPlayerQualityStateChanging;
        [self.mediaSkinContainer showDefinitionTipsView];
    });
    // 正在切换播放源
    self.mediaPlayerState.isChangingPlaySource = YES;
}

#pragma mark 【Orientation 横竖屏设置】
/// 切换到 横向-全屏皮肤
- (void)changeToLandscape{
    [PLVVodMediaOrientationUtil changeUIOrientation:UIDeviceOrientationLandscapeLeft];
}

/// 切换到 竖向-半屏皮肤
- (void)changeToProtrait{
    [PLVVodMediaOrientationUtil changeUIOrientation:UIDeviceOrientationPortrait];
}

/// 更新 播放器皮肤 —— 触发 竖向-半屏皮肤 和 横向-全屏皮肤 的切换
- (void)updateUIForOrientation{
    self.mediaSkinContainer.frame = self.view.bounds;
}

#pragma mark 【PictureInPicture 画中画功能】
- (void)changePictureInPictureStatus{
    if ([PLVMediaPlayerPictureInPictureManager sharedInstance].pictureInPictureActive) { // 暂停 画中画
        [self.player stopPictureInPicture];
    } else { // 启动 画中画
        // 横屏状态，需要先返回竖屏状态
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            [PLVVodMediaOrientationUtil changeUIOrientation:UIDeviceOrientationPortrait];
        }
        [self.player startPictureInPicture];
    }
}

#pragma mark 【PLVVodMediaPlayerSkinContainerView Delegate 皮肤容器的回调方法】
/// 竖向-半屏皮肤时，显示外部 moreview 视图
- (void)mediaPlayerSkinContainerView_ShowMoreView:(PLVVodMediaPlayerSkinContainerView *)skinContainer{
    if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(vodMediaAreaVC_ShowMoreView:)]){
        [self.mediaAreaVcDelegate vodMediaAreaVC_ShowMoreView:self];
    }
}

/// 返回 按钮事件 处理
- (void)mediaPlayerSkinContainerView_BackEvent:(PLVVodMediaPlayerSkinContainerView *)skinContainer{
    BOOL isFullScreen = [PLVVodMediaOrientationUtil isLandscape];
    if (isFullScreen) { // 横向-全屏
        // 切换到 竖向-半屏
        [self changeToProtrait];
    } else { // 竖向-半屏
        // 触发 页面返回
        if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(vodMediaAreaVC_BackEvent:)]){
            [self.mediaAreaVcDelegate vodMediaAreaVC_BackEvent:self];
        }
    }
}

/// 全屏 按钮事件 处理
- (void)mediaPlayerSkinContainerView_FullScreenEvent:(PLVVodMediaPlayerSkinContainerView *)skinContainer{
    [self changeToLandscape];
}

/// 切换到视频模式 按钮事件 处理
- (void)mediaPlayerSkinContainerView_SwitchToVideoMode:(PLVVodMediaPlayerSkinContainerView *)skinContainer{
    [self setPlaykMode:PLVVodMediaPlaybackModeVideo];
}

/// 切换到音频模式 按钮事件 处理
- (void)mediaPlayerSkinContainerView_SwitchToAudioMode:(PLVVodMediaPlayerSkinContainerView *)skinContainer{
    [self setPlaykMode:PLVVodMediaPlaybackModeAudio];
}

/// 画中画 按钮事件 处理
- (void)mediaPlayerSkinContainerView_StartPictureInPicture:(PLVVodMediaPlayerSkinContainerView *)skinContainer{
    [self changePictureInPictureStatus];
}

/// 切换清晰度  按钮事件 处理
- (void)mediaPlayerSkinContainerView_SwitchQualtiy:(PLVVodMediaPlayerSkinContainerView *)skinContainer qualityLevel:(NSInteger)qualityLevel{
    [self synPlayQuality:qualityLevel];
}

/// 切换播放速度  按钮事件 处理
- (void)mediaPlayerSkinContainerView_SwitchPlayRate:(PLVVodMediaPlayerSkinContainerView *)skinContainer playRate:(CGFloat)playRate{
    [self synPlayRate:playRate];
}

/// 播放/暂停  按钮事件 处理
- (void)mediaPlayerSkinContainerView_Play:(PLVVodMediaPlayerSkinContainerView *)skin willPlay:(BOOL)willPlay{
    if (willPlay) {
        [self.player play];
    } else {
        [self.player pause];
    }
}

/// 进度面板 手势事件 处理
- (void)mediaPlayerSkinContainerview_ProgressViewPan:(PLVVodMediaPlayerSkinContainerView *)skinContainer scrubTime:(NSTimeInterval)scrubTime{
    [self.player seekToTime:scrubTime];
    [self.player play];
}

/// 进度条 拖动事件 处理
- (void)mediaPlayerSkinContainerView_SliderDragEnd:(PLVVodMediaPlayerSkinContainerView *)skinContainer sliderValue:(CGFloat)sliderValue{
    NSTimeInterval currentTime = self.player.duration * sliderValue;
    [self.player seekToTime:currentTime];
    [self.player play];
}

/// 横屏 字幕选中事件
- (void)mediaPlayerSkinContainerView_SelectSubtitle:(PLVVodMediaPlayerSkinContainerView *)skinContainer{
    // 更新字幕
    [self updateVideoSubtile];
}

/// 横屏 开始下载
- (void)mediaPlayerSkinContainerView_StartDownload:(PLVVodMediaPlayerSkinContainerView *)skinContainer{
    if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(vodMediaAreaVC_StartDownloadEvent:)]){
        [self.mediaAreaVcDelegate vodMediaAreaVC_StartDownloadEvent:self];
    }
}

#pragma mark 【PLVMediaPlayerCore Delegate 播放器核心（播放状态时间）的回调方法】
/// 播放器 ’加载状态‘ 发生改变
-(void)plvMediaPlayerCore:(PLVMediaPlayerCore *)player playerLoadStateDidChange:(PLVPlayerLoadState)loadState{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // 加载速度显示
    if (loadState == PLVPlayerLoadStateStalled){
        [self.mediaSkinContainer showLoadingSpeed:self.player.tcpSpeed loading:YES];
    }
    else{
        [self.mediaSkinContainer showLoadingSpeed:self.player.tcpSpeed loading:NO];
    }
}

/// 播放器 已准备好播放
- (void)plvMediaPlayerCore:(PLVMediaPlayerCore *)player playerIsPreparedToPlay:(BOOL)prepared{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    // 同步播放速率
    [self synPlayRate:self.mediaPlayerState.curPlayRate];
    
    // 提示续播进度
    if (player.currentPlaybackTime > PLVMediaPlayerShowProgressTime && !self.mediaPlayerState.isChangingPlaySource){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mediaSkinContainer showPlayProgressToastView:player.currentPlaybackTime];
        });
    }
    // 播放源未切换或切换完成
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
    [self.mediaSkinContainer.portraitHalfSkinView setPlayButtonWithPlaying:isPlaying];
    
    if (isPlaying) {
        [self.mediaSkinContainer hideLoopPlayUI];
    }
    
    // 跑马灯控制
    [self marqueeControlWithState:playbackState];
    
    // 清晰度切换状态刷新
    if (self.mediaPlayerState.qualityState == PLVMediaPlayerQualityStateChanging){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mediaPlayerState.qualityState = PLVMediaPlayerQualityStateComplete;
            [self.mediaSkinContainer showDefinitionTipsView];
        });
    }
}

/// 播放器 播放结束
- (void)plvMediaPlayerCore:(PLVMediaPlayerCore *)player playerPlaybackDidFinish:(PLVPlayerFinishReason)finishReson{
    if (PLVPlayerFinishReasonPlaybackEnded == finishReson){
        if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(vodMediaAreaVC_PlayFinishEvent:)]){
            [self.mediaAreaVcDelegate vodMediaAreaVC_PlayFinishEvent:self];
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

/// 播放器首帧渲染
- (void)plvMediaPlayerCore:(PLVMediaPlayerCore *)player firstFrameRendered:(BOOL)rendered{
    NSLog(@"%@", NSStringFromSelector(_cmd));
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
    [self.mediaSkinContainer.portraitHalfSkinView setProgressWithCachedProgress:0
                                                        playedProgress:playedProgress
                                                          durationTime:vodMediaPlayer.duration
                                                     currentTimeString:playedTimeString
                                                        durationString:durationTimeString];
}

/// 画中画 状态回调
- (void)PLVVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer pictureInPictureChangeState:(PLVPictureInPictureState)pipState{
    if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(vodMediaAreaVC_PictureInPictureChangeState:state:)]){
        [self.mediaAreaVcDelegate vodMediaAreaVC_PictureInPictureChangeState:self state:pipState];
    }
    // 画中画结束
    if (pipState == PLVPictureInPictureStateDidEnd ||
        pipState == PLVPictureInPictureStateWillEnd ||
        pipState == PLVPictureInPictureStateError){
        // 恢复皮肤状态
        self.mediaPlayerState.curWindowMode = PLVMediaPlayerWindowModeDefault;
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
    if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(vodMediaAreaVC_StartPictureInPictureFailed:error:)]){
        [self.mediaAreaVcDelegate vodMediaAreaVC_StartPictureInPictureFailed:self error:error];
    }
    
    // 恢复皮肤状态
    self.mediaPlayerState.curWindowMode = PLVMediaPlayerWindowModeDefault;
    [self.mediaSkinContainer showPicInPicPlaceholderViewWithStatus:NO];
}

/// 当前网络状态不佳 回调状态
- (void)PLVVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer poorNetworkState:(BOOL)poorState {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mediaPlayerState.qualityState = PLVMediaPlayerQualityStatePrepare;
        [self.mediaSkinContainer showDefinitionTipsView];
    });
}

///  播放器播放错误回调
- (void)PLVVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer loadMainPlayerFailureWithError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", error);
    });
}

@end
