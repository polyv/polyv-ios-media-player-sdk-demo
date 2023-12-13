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
#import "PLVToast.h"
#import "PLVVodErrorUtil.h"
#import "PLVOrientationUtil.h"
#import "UIImage+Tint.h"


/// UI View Hierarchy
///
/// (UIView) self
///  ├── (PLVVodMediaPlayer) player
///  ├── (PLVShortVideoMediaPlayerSkinContainer) mediaSkinContainer
///  ├── (PLVMediaPlayerSkinOutMoreView) skinOutMoreView
///  ├── (UIImageView) displayCoverView

@interface PLVShortVideoMediaAreaVC ()<
PLVPlayerCoreDelegate,
PLVVodMediaPlayerDelegate,
PLVShortVideoMediaPlayerSkinContainerDelegate,
PLVMediaPlayerSkinOutMoreViewDelegate
>

/// UI 部分
@property (nonatomic, strong) PLVMediaPlayerSkinOutMoreView *skinOutMoreView;
@property (nonatomic, strong) UIImageView *displayCoverView; // 视频封面图

// 布局 部分 - 用于 横竖屏切换
@property (nonatomic, strong) UIView *displayView; // 裸播放器对应的渲染View
@property (nonatomic, assign) CGRect originFrame;  // 视频区域原始尺寸
@property (nonatomic, assign) UIView *originSuperView; // 视频区域原始父视图

/// 状态控制 部分
@property (nonatomic, assign ) BOOL isSwitchingPlaySource; // 是否正在切换播放源
@property (nonatomic, assign) BOOL isShowInUIWindow;

@end

@implementation PLVShortVideoMediaAreaVC

@synthesize reuseIdentifier;

#pragma mark 【Life Cycle】
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
}

- (void)updateUI{
    BOOL isLandscape = [PLVOrientationUtil isLandscape];
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
            self.displayView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width/self.mediaPlayerState.ratio);
            self.displayView.center = self.center;
        }
        
        self.skinOutMoreView.frame = self.bounds;
    }
    
    self.displayCoverView.bounds = self.displayView.bounds;
    self.displayCoverView.center = self.center;
    self.mediaSkinContainer.frame = self.bounds;
    self.mediaSkinContainer.center = self.center;
}

#pragma mark 【Back 页面返回处理】

#pragma mark 【Getter & Setter】
- (PLVVodMediaPlayer *)player{
    if (!_player){
        _player = [[PLVVodMediaPlayer alloc] init];
        _player.delegateVodMediaPlayer = self;
        _player.coreDelegate = self;
        _player.autoPlay = NO;
        _player.rememberLastPosition = YES;
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
        _displayView = [[UIView alloc] init];
    }
    return _displayView;
}

#pragma mark 【Public Method】
- (void)playWithVid:(NSString *)vid{
    [PLVVodVideo requestVideoWithVid:vid completion:^(PLVVodVideo *video, NSError *error) {
        [self.player setVideo:video];
        
        // 同步播放器状态
        [self syncPlayerStateWithModel:video];
    }];
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

- (void)setPlayQuality:(NSInteger)qualityLevel{
    [self.player setPlayQuality:(PLVVodQuality)qualityLevel];
    self.isSwitchingPlaySource = YES;
}

- (void)setPlaybackMode:(PLVVodPlaybackMode)playbackMode{
    [self.player setPlaybackMode:playbackMode];
    self.isSwitchingPlaySource = YES;
}

- (void)showVideoModeUI{
    [self.mediaSkinContainer showVideoModeUI];
}

- (void)startActive{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self play];
    });
}

- (void)endActive{
    [self.player pause];
    self.mediaSkinContainer.portraitFullSkinView.playButton.selected = NO;
    
    // 关闭菜单
    [self.skinOutMoreView hideMoreView];
}

- (void)setPlayMode:(PLVVodPlaybackMode)playbackMode {
    if (playbackMode == PLVVodPlaybackModeAudio) {
        [self.player setPlaybackMode:PLVVodPlaybackModeAudio];
        self.mediaPlayerState.curPlayMode = 2;
        self.isSwitchingPlaySource = YES;
        [self.mediaSkinContainer showAudioModeUI];
    } else {
        [self.player setPlaybackMode:PLVVodPlaybackModeVideo];
        self.mediaPlayerState.curPlayMode = 1;
        self.isSwitchingPlaySource = YES;
        [self.mediaSkinContainer showVideoModeUI];
    }
}

- (void)hideProtraitBackButton {
    self.mediaSkinContainer.portraitFullSkinView.backButton.hidden = YES;
}

#pragma mark 【Syn Method  同步 player、mediaState、mediaSkinContainer 之间的数据】
- (void)syncPlayerStateWithModel:(PLVVodVideo *)videoModel{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mediaPlayerState.curQualityLevel = videoModel.preferredQuality;
        self.mediaPlayerState.qualityCount = videoModel.qualityCount;
        self.mediaPlayerState.isSupportAudioMode = [videoModel canSwithPlaybackMode];
        
        self.mediaPlayerState.snapshot = videoModel.snapshot;
        self.mediaPlayerState.ratio = videoModel.ratio;
        self.mediaPlayerState.videoTitle = videoModel.title;
        
        [self.displayCoverView sd_setImageWithURL:[NSURL URLWithString:videoModel.snapshot] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (image && [image isKindOfClass:[UIImage class]]){
                UIImage *blurimage = [UIImage boxblurImageWithBlur:0.2 image:image];
                self.displayCoverView.image = blurimage;
            }
        }];
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
    [self.player setPlayQuality:(PLVVodQuality)qualityLevel];
    self.isSwitchingPlaySource = YES;
    self.mediaPlayerState.curQualityLevel = qualityLevel;

    // 刷新皮肤
    [self.mediaSkinContainer.landscapeFullSkinView updateQualityLevel:qualityLevel];
}

#pragma mark 【Orientation 横竖屏设置】
/// 切换到 竖向-半屏皮肤
- (void)changeToProtrait{
    [PLVOrientationUtil changeUIOrientation:UIDeviceOrientationPortrait];
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

#pragma mark 【PLVPlayerCore Delegate 播放器核心（播放状态时间）的回调方法】
/// 播放器 ’加载状态‘ 发生改变
-(void)plvPlayerCore:(PLVPlayerCore *)player playerLoadStateDidChange:(PLVPlayerLoadState)loadState{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

/// 播放器 已准备好播放
- (void)plvPlayerCore:(PLVPlayerCore *)player playerIsPreparedToPlay:(BOOL)prepared{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (self.isSwitchingPlaySource){
        [player play];
        self.isSwitchingPlaySource = NO;
    }
    
    if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(shortVideoMediaAreaVC_playerIsPreparedToPlay:)]){
        [self.mediaAreaVcDelegate shortVideoMediaAreaVC_playerIsPreparedToPlay:self];
    }
}

/// 播放器 ‘播放状态’ 发生改变
- (void)plvPlayerCore:(PLVPlayerCore *)player playerPlaybackStateDidChange:(PLVPlaybackState)playbackState{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    BOOL isPlaying = (playbackState == PLVPlaybackStatePlaying);
    // 同步播放器皮肤
    self.mediaPlayerState.isPlaying = isPlaying;
    [self.mediaSkinContainer.landscapeFullSkinView setPlayButtonWithPlaying:isPlaying];
    [self.mediaSkinContainer.portraitFullSkinView setPlayButtonWithPlaying:isPlaying];
}

/// 播放器 播放结束
- (void)plvPlayerCore:(PLVPlayerCore *)player playerPlaybackDidFinish:(PLVPlayerFinishReason)finishReson{
    if (PLVPlayerFinishReasonPlaybackEnded == finishReson){
        [self.player play];
    }
}

- (void)plvPlayerCore:(PLVPlayerCore *)player firstFrameRendered:(BOOL)rendered{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.displayCoverView removeFromSuperview];
    });
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
    [self.mediaSkinContainer.portraitFullSkinView setProgressWithCachedProgress:0
                                                        playedProgress:playedProgress
                                                          durationTime:vodMediaPlayer.duration
                                                     currentTimeString:playedTimeString
                                                        durationString:durationTimeString];
}

/// 画中画 状态回调
- (void)plvVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer pictureInPictureChangeState:(PLVPictureInPictureState)pipState{
    if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(shortVideoMediaAreaVC_PictureInPictureChangeState:state:)]){
        [self.mediaAreaVcDelegate shortVideoMediaAreaVC_PictureInPictureChangeState:self state:pipState];
    }
    
    // 画中画结束
    if (pipState == PLVPictureInPictureStateDidEnd || pipState == PLVPictureInPictureStateWillEnd){
        // 恢复皮肤状态
        self.mediaPlayerState.curWindowMode = 1;
        [self.mediaSkinContainer syncSkinWithMode:self.mediaPlayerState];
    }
}

/// 画中画 开启失败
- (void)plvVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer startPictureInPictureWithError:(NSError *)error{
    // 画中画开启失败
    if (self.mediaAreaVcDelegate && [self.mediaAreaVcDelegate respondsToSelector:@selector(shortVideoMediaAreaVC_StartPictureInPictureFailed:error:)]){
        [self.mediaAreaVcDelegate shortVideoMediaAreaVC_StartPictureInPictureFailed:self error:error];
    }
    
    // 恢复皮肤状态
    self.mediaPlayerState.curWindowMode = 1;
    [self.mediaSkinContainer syncSkinWithMode:self.mediaPlayerState];

    // 抛出错误提示
    if ([error.domain isEqualToString:PLVVodErrorDomain]) {
        NSString *message = [NSString stringWithFormat:@"%@", [PLVVodErrorUtil getErrorMsgWithCode:error.code]];
        [PLVToast showMessage:message];
    }else {
        NSString *message = [NSString stringWithFormat:@"%@", error.localizedFailureReason];
        [PLVToast showMessage:message];
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
    [PLVOrientationUtil changeUIOrientation:UIDeviceOrientationLandscapeLeft];
}

/// 切换到视频模式 按钮事件 处理
- (void)mediaPlayerSkinContainer_SwitchVideoMode:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    [self setPlayMode:PLVVodPlaybackModeVideo];
}

/// 切换到音频模式 按钮事件 处理
- (void)mediaPlayerSkinContainer_SwitchToAudioMode:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    [self setPlayMode:PLVVodPlaybackModeAudio];
}

/// 画中画 按钮事件 处理
- (void)mediaPlayerSkinContainer_StartPictureInPicture:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    if ([PLVMediaPlayerPictureInPictureManager sharedInstance].pictureInPictureActive) {
        [self.player stopPictureInPicture];
    }else {
        // 横屏状态，需要先返回竖屏状态
        UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            [PLVOrientationUtil changeUIOrientation:UIDeviceOrientationPortrait];
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
}

/// 进度条 拖动事件 处理
- (void)mediaPlayerSkinContainer_SliderDragEnd:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer sliderValue:(CGFloat)sliderValue{
    NSTimeInterval currentTime = self.player.duration * sliderValue;
    // 拖动进度条后，同步当前进度时间
    [self.player seekToTime:currentTime];
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

#pragma mark 【PLVMediaPlayerSkinOutMoreView Delegate - 更多弹层 回调方法】
- (void)mediaPlayerSkinOutMoreView_SwitchPlayRate:(CGFloat)rate{
    [self synPlayRate:rate];
}

- (void)mediaPlayerSkinOutMoreView_SwitchQualityLevel:(NSInteger)qualityLevel{
    [self synPlayQuality:qualityLevel];
}

- (void)mediaPlayerSkinOutMoreView_SwitchToAudioMode{
    [self setPlayMode:PLVVodPlaybackModeAudio];
}

- (void)mediaPlayerSkinOutMoreView_StartPictureInPicture{
    [self.player startPictureInPicture];
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

@end
