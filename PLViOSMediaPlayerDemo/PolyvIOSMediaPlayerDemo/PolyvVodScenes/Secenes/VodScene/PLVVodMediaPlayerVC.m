//
//  PLVVodMediaPlayerVC.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/9.
//

#import "PLVVodMediaPlayerVC.h"
#import "PLVVodMediaPlayerSkinContainer.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVMediaPlayerState.h"


@interface PLVVodMediaPlayerVC ()<
PLVPlayerCoreDelegate,
PLVVodMediaPlayerDelegate,
PLVVodMediaPlayerSkinContainerDelegate
>

/// 播放器皮肤
@property (nonatomic, strong) PLVVodMediaPlayerSkinContainer *skinContainer;
@property (nonatomic, strong) PLVMediaPlayerState *mediaPlayerState;

@end

@implementation PLVVodMediaPlayerVC

- (PLVVodMediaPlayer *)vodMediaPlayer{
    if (!_vodMediaPlayer){
        _vodMediaPlayer = [[PLVVodMediaPlayer alloc] init];
        _vodMediaPlayer.coreDelegate = self;
        _vodMediaPlayer.delegateVodMediaPlayer = self;
        _vodMediaPlayer.autoPlay = YES;
    }
    
    return _vodMediaPlayer;
}

- (PLVVodMediaPlayerSkinContainer *)skinContainer{
    if (!_skinContainer){
        _skinContainer = [[PLVVodMediaPlayerSkinContainer alloc] init];
        _skinContainer.containerDelegate = self;
    }
    
    return _skinContainer;
}

- (PLVMediaPlayerState *)mediaPlayerState{
    if (!_mediaPlayerState){
        _mediaPlayerState = [[PLVMediaPlayerState alloc] init];
    }
    
    return _mediaPlayerState;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.skinContainer.frame = self.view.bounds;
}

- (void)setupUI{
    self.view.backgroundColor = [UIColor blackColor];
    [self.vodMediaPlayer setupDisplaySuperview:self.view];
    
    [self.view addSubview:self.skinContainer];
    self.skinContainer.backgroundColor = [UIColor clearColor];
}

#pragma mark PLVVodMediaPlayerSkinContainerDelegate
/// 竖屏时显示外部moreview 视图
- (void)mediaPlayerSkinContainer_ShowMoreView:(PLVVodMediaPlayerSkinContainer *)skinContainer{
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(vodMediaPlayerVC_ShowMoreView:)]){
        [self.vcDelegate vodMediaPlayerVC_ShowMoreView:self];
    }
}

- (void)mediaPlayerSkinContainer_BackEvent:(PLVVodMediaPlayerSkinContainer *)skinContainer{
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(vodMediaPlayerVC_BackEvent:)]){
        [self.vcDelegate vodMediaPlayerVC_BackEvent:self];
    }
}

/// 切换到视频模式
- (void)mediaPlayerSkinContainer_SwitchVideoMode:(PLVVodMediaPlayerSkinContainer *)skinContainer{
    [self.vodMediaPlayer setPlaybackMode:PLVVodPlaybackModeVideo];
    [self.skinContainer showVideoModeUI];
}

/// 切换到音频模式
- (void)mediaPlayerSkinContainer_SwitchToAudioMode:(PLVVodMediaPlayerSkinContainer *)skinContainer{
    [self.vodMediaPlayer setPlaybackMode:PLVVodPlaybackModeAudio];
    self.mediaPlayerState.curPlayMode = 2;
    [self.skinContainer showAudioModeUI];
}

/// 开启画中画播放
- (void)mediaPlayerSkinContainer_StartPictureInPicture:(PLVVodMediaPlayerSkinContainer *)skinContainer{
    if ([PLVMediaPlayerPictureInPictureManager sharedInstance].pictureInPictureActive) {
        [self.vodMediaPlayer stopPictureInPicture];
    }else {
        // 横屏状态，需要先返回竖屏状态
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            [PLVVodFdUtil changeDeviceOrientation:UIDeviceOrientationPortrait];
        }
        [self.vodMediaPlayer startPictureInPicture];
    }
}

/// 切换清晰度
- (void)mediaPlayerSkinContainer_SwitchQualtiy:(PLVVodMediaPlayerSkinContainer *)skinContainer qualityLevel:(NSInteger)qualityLevel{
    [self.vodMediaPlayer setPlayQuality:(PLVVodQuality)qualityLevel];
    // 刷新皮肤
    [self.skinContainer.fullSkinView updateQualityLevel:qualityLevel];
    self.mediaPlayerState.curQualityLevel = qualityLevel;
}

/// 切换播放速度
- (void)mediaPlayerSkinContainer_SwitchPlayRate:(PLVVodMediaPlayerSkinContainer *)skinContainer playRate:(CGFloat)playRate{
    [self.vodMediaPlayer switchSpeedRate:playRate];
    // 刷新皮肤
    [self.skinContainer.fullSkinView updatePlayRate:playRate];
    self.mediaPlayerState.curPlayRate = playRate;
}

/// 播放、暂停事件
- (void)mediaPlayerSkinContainer_Play:(PLVVodMediaPlayerSkinContainer *)skin willPlay:(BOOL)willPlay{
    if (willPlay){
        [self.vodMediaPlayer play];
    }
    else{
        [self.vodMediaPlayer pause];
    }
}

/// 进度面板
- (void)mediaPlayerSkinContainer_ProgressViewPan:(PLVVodMediaPlayerSkinContainer *)skinContainer scrubTime:(NSTimeInterval)scrubTime{
    [self.vodMediaPlayer seekToTime:scrubTime];
}

/// 进度条
- (void)mediaPlayerSkinContainer_SliderDragEnd:(PLVVodMediaPlayerSkinContainer *)skinContainer sliderValue:(CGFloat)sliderValue{
    NSTimeInterval currentTime = self.vodMediaPlayer.duration * sliderValue;
    // 拖动进度条后，同步当前进度时间
    [self.vodMediaPlayer seekToTime:currentTime];
}

#pragma mark -- PLVPlayerCoreDelegate
-(void)plvPlayerCore:(PLVPlayerCore *)player playerLoadStateDidChange:(PLVPlayerLoadState)loadState{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)plvPlayerCore:(PLVPlayerCore *)player playerIsPreparedToPlay:(BOOL)prepared{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)plvPlayerCore:(PLVPlayerCore *)player playerPlaybackStateDidChange:(PLVPlaybackState)playbackState{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    BOOL isPlaying = (playbackState == PLVPlaybackStatePlaying);
    // 同步播放器皮肤
    self.mediaPlayerState.isPlaying = isPlaying;
    [self.skinContainer.fullSkinView setPlayButtonWithPlaying:isPlaying];
    [self.skinContainer.portraitSkinView setPlayButtonWithPlaying:isPlaying];
}

- (void)plvPlayerCore:(PLVPlayerCore *)player playerPlaybackDidFinish:(PLVPlayerFinishReason)finishReson{
    //
    if (PLVPlayerFinishReasonPlaybackEnded == finishReson){
        [self.skinContainer showLoopPlayUI];
    }
}

#pragma mark -- PLVVodMediaPlayerDelegate
- (void)plvVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer
           playedProgress:(CGFloat)playedProgress
         playedTimeString:(NSString *)playedTimeString
       durationTimeString:(NSString *)durationTimeString{
    //
    [self.skinContainer.fullSkinView setProgressWithCachedProgress:0
                                                    playedProgress:playedProgress
                                                      durationTime:vodMediaPlayer.duration
                                                 currentTimeString:playedTimeString
                                                    durationString:durationTimeString];
    [self.skinContainer.portraitSkinView setProgressWithCachedProgress:0
                                                        playedProgress:playedProgress
                                                          durationTime:vodMediaPlayer.duration
                                                     currentTimeString:playedTimeString
                                                        durationString:durationTimeString];
}

- (void)plvVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer pictureInPictureChangeState:(PLVPictureInPictureState)pipState{
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(vodMediaPlayerVC_PictureInPictureChangeState:state:)]){
        [self.vcDelegate vodMediaPlayerVC_PictureInPictureChangeState:self state:pipState];
    }
    
    // 画中画结束
    if (pipState == PLVPictureInPictureStateDidEnd || pipState == PLVPictureInPictureStateWillEnd){
        // 恢复皮肤状态
        self.mediaPlayerState.curWindowMode = 1;
    }
}

- (void)plvVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer startPictureInPictureWithError:(NSError *)error{
    // 画中画开启失败
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(vodMediaPlayerVC_StartPictureInPictureFailed:error:)]){
        [self.vcDelegate vodMediaPlayerVC_StartPictureInPictureFailed:self error:error];
    }
    
    // 恢复皮肤状态
    self.mediaPlayerState.curWindowMode = 1;
}

- (void)syncPlayerStateWithModel:(PLVVodVideo *)videoModel{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mediaPlayerState.curQualityLevel = videoModel.preferredQuality;
        self.mediaPlayerState.qualityCount = videoModel.qualityCount;
        self.mediaPlayerState.isSupportAudioMode = [videoModel canSwithPlaybackMode];
        
        self.mediaPlayerState.snapshot = videoModel.snapshot;
        self.mediaPlayerState.videoTitle = videoModel.title;
        
        // 同步播放器皮肤
        [self.skinContainer syncSkinWithMode:self.mediaPlayerState];
    });
}

#pragma mark public
- (void)playWithVid:(NSString *)vid{
    [PLVVodVideo requestVideoWithVid:vid completion:^(PLVVodVideo *video, NSError *error) {
        [self.vodMediaPlayer setVideo:video];
        
        // 同步播放器状态
        [self syncPlayerStateWithModel:video];
    }];
}

- (void)setPlayRate:(CGFloat)rate{
    [self.vodMediaPlayer switchSpeedRate:rate];
}

- (void)setPlayQuality:(NSInteger)qualityLevel{
    [self.vodMediaPlayer setPlayQuality:(PLVVodQuality)qualityLevel];
}

- (void)setPlaybackMode:(PLVVodPlaybackMode)playbackMode{
    [self.vodMediaPlayer setPlaybackMode:playbackMode];
}

- (void)showAudioModeUI{
    [self.skinContainer showAudioModeUI];
}

- (void)showVideoModeUI{
    [self.skinContainer showVideoModeUI];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
