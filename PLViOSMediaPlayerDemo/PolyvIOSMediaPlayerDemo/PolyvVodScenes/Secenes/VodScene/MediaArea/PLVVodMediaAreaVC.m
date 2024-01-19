//
//  PLVVodMediaPlayerVC.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/9.
//

#import "PLVVodMediaAreaVC.h"
#import "PLVOrientationUtil.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVMarqueeView.h"

/// UI View Hierarchy
///
/// (UIView) self.view
///  ├── (PLVVodMediaPlayer) player
///  ├── (PLVVodMediaPlayerSkinContainerView) skinContainer

@interface PLVVodMediaAreaVC ()<
PLVPlayerCoreDelegate,
PLVVodMediaPlayerDelegate,
PLVVodMediaPlayerSkinContainerViewDelegate
>

@property (nonatomic, strong) PLVMarqueeView *marqueeView; /// 跑马灯

@end

@implementation PLVVodMediaAreaVC

#pragma mark 【Life Cycle】
- (void)dealloc{
    [self.player clearPlayer];
    [self.marqueeView stop];
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
    self.player.enableTeaser = YES;
    
    // seek 类型 精准seek
    self.player.seekType = PLVVodPlaySeekTypePrecise;
    
    // 设置新版跑马灯（2.0）
    [self initMarqueeView];
}

- (void)initMarqueeView{
    self.marqueeView = [[PLVMarqueeView alloc] init];
    PLVMarqueeModel *marqueeModel = [[PLVMarqueeModel alloc] init];
    self.marqueeView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.marqueeView.frame = self.view.bounds;
    [self.marqueeView setPLVMarqueeModel:marqueeModel];
    [self.view addSubview:self.marqueeView];
}

- (void)updateUI {
    [self updateUIForOrientation];
}

#pragma mark 【Getter & Setter】
- (PLVVodMediaPlayer *)player{
    if (!_player){
        _player = [[PLVVodMediaPlayer alloc] init];
        _player.coreDelegate = self;
        _player.delegateVodMediaPlayer = self;
        _player.autoPlay = YES;
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
    [PLVVodVideo requestVideoWithVid:vid completion:^(PLVVodVideo *video, NSError *error) {
        [self.player setVideo:video];
        [self syncPlayerStateWithModel:video]; // 同步播放器状态
    }];
}

- (void)setPlayRate:(CGFloat)rate{
    [self synPlayRate:rate];
}

- (void)setPlayQuality:(NSInteger)qualityLevel{
    [self synPlayQuality:qualityLevel];
}

- (void)setPlaykMode:(PLVVodPlaybackMode)playbackMode{
    [self.player setPlaybackMode:playbackMode];
    if (playbackMode == PLVVodPlaybackModeAudio) { // 音频模式
        self.mediaPlayerState.curPlayMode = 2;
        [self.mediaSkinContainer showAudioModeUI];
    } else { // 视频模式
        self.mediaPlayerState.curPlayMode = 1;
        [self.mediaSkinContainer showVideoModeUI];
    }
}

- (void)replay {
    [self.player play];
}

- (void)showPlayFinishUI {
    [self.mediaSkinContainer showLoopPlayUI];
}

#pragma mark 【Syn Method  同步 player、mediaState、mediaSkinContainer 之间的数据】
- (void)syncPlayerStateWithModel:(PLVVodVideo *)videoModel{
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
    [self.player setPlayQuality:(PLVVodQuality)qualityLevel];
    // 视频区域 对应 播放器 的 实时数据模型
    self.mediaPlayerState.curQualityLevel = qualityLevel;
    // 视频区域 对应 播放器 的皮肤
    [self.mediaSkinContainer.landscapeFullSkinView updateQualityLevel:qualityLevel];
}

#pragma mark 【Orientation 横竖屏设置】
/// 切换到 横向-全屏皮肤
- (void)changeToLandscape{
    [PLVOrientationUtil changeUIOrientation:UIDeviceOrientationLandscapeLeft];
}

/// 切换到 竖向-半屏皮肤
- (void)changeToProtrait{
    [PLVOrientationUtil changeUIOrientation:UIDeviceOrientationPortrait];
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
            [PLVOrientationUtil changeUIOrientation:UIDeviceOrientationPortrait];
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
    BOOL isFullScreen = [PLVOrientationUtil isLandscape];
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
- (void)mediaPlayerSkinContainerView_SwitchVideoMode:(PLVVodMediaPlayerSkinContainerView *)skinContainer{
    [self setPlaykMode:PLVVodPlaybackModeVideo];
}

/// 切换到音频模式 按钮事件 处理
- (void)mediaPlayerSkinContainerView_SwitchToAudioMode:(PLVVodMediaPlayerSkinContainerView *)skinContainer{
    [self setPlaykMode:PLVVodPlaybackModeAudio];
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
}

/// 进度条 拖动事件 处理
- (void)mediaPlayerSkinContainerView_SliderDragEnd:(PLVVodMediaPlayerSkinContainerView *)skinContainer sliderValue:(CGFloat)sliderValue{
    NSTimeInterval currentTime = self.player.duration * sliderValue;
    [self.player seekToTime:currentTime];
}

#pragma mark 【PLVPlayerCore Delegate 播放器核心（播放状态时间）的回调方法】
/// 播放器 ’加载状态‘ 发生改变
-(void)plvPlayerCore:(PLVPlayerCore *)player playerLoadStateDidChange:(PLVPlayerLoadState)loadState{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

/// 播放器 已准备好播放
- (void)plvPlayerCore:(PLVPlayerCore *)player playerIsPreparedToPlay:(BOOL)prepared{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

/// 播放器 ‘播放状态’ 发生改变
- (void)plvPlayerCore:(PLVPlayerCore *)player playerPlaybackStateDidChange:(PLVPlaybackState)playbackState{
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
}

/// 播放器 播放结束
- (void)plvPlayerCore:(PLVPlayerCore *)player playerPlaybackDidFinish:(PLVPlayerFinishReason)finishReson{
    if (PLVPlayerFinishReasonPlaybackEnded == finishReson){
        if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(vodMediaAreaVC_PlayFinishEvent:)]){
            [self.mediaAreaVcDelegate vodMediaAreaVC_PlayFinishEvent:self];
        }
    }
}

#pragma mark 【PLVVodMediaPlayerDelegate 播放器的回调方法】
/// 播放器 定时返回当前播放进度
- (void)plvVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer
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
- (void)plvVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer pictureInPictureChangeState:(PLVPictureInPictureState)pipState{
    if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(vodMediaAreaVC_PictureInPictureChangeState:state:)]){
        [self.mediaAreaVcDelegate vodMediaAreaVC_PictureInPictureChangeState:self state:pipState];
    }
    
    // 画中画结束
    if (pipState == PLVPictureInPictureStateDidEnd || pipState == PLVPictureInPictureStateWillEnd){
        // 恢复皮肤状态
        self.mediaPlayerState.curWindowMode = 1;
    }
}

/// 画中画 开启失败
- (void)plvVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer startPictureInPictureWithError:(NSError *)error{
    // 画中画开启失败
    if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(vodMediaAreaVC_StartPictureInPictureFailed:error:)]){
        [self.mediaAreaVcDelegate vodMediaAreaVC_StartPictureInPictureFailed:self error:error];
    }
    
    // 恢复皮肤状态
    self.mediaPlayerState.curWindowMode = 1;
}

/// 当前网络状态不佳 回调状态
- (void)plvVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer poorNetworkState:(BOOL)poorState {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mediaSkinContainer showDefinitionTipsView];
    });
}


@end
