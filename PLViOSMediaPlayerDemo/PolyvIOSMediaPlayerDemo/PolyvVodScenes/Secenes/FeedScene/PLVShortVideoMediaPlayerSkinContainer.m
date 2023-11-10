//
//  PLVShortVideoMediaPlayerSkinContainer.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/14.
//

#import "PLVShortVideoMediaPlayerSkinContainer.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

#import "PLVMediaPlayerSkinMoreView.h"
#import "PLVMediaPlayerSkinAudioModeView.h"
#import "PLVMediaPlayerSkinLockScreenView.h"
#import "PLVMediaPlayerSkinMoreView.h"
#import "PLVMediaPlayerSkinDefinitionView.h"
#import "PLVMediaPlayerSkinPlaybackRateView.h"
#import "PLVMediaPlayerSkinFastForwardView.h"

@interface PLVShortVideoMediaPlayerSkinContainer()<
PLVMediaPlayerBaseSkinViewDelegate,
PLVMediaPlayerSkinAudioModeViewDelegate,
PLVMediaPlayerFullSkinViewDelegate,
PLVMediaPlayerSkinLockScreenViewDelegate,
PLVMediaPlayerSkinMoreViewDelegate,
PLVMediaPlayerSkinDefinitionViewDelegate,
PLVMediaPlayerSkinPlaybackRateViewDelegate
>

@property (nonatomic, strong) PLVMediaPlayerSkinMoreView *skinMoreView;
@property (nonatomic, strong) PLVMediaPlayerSkinAudioModeView *audioModeView;
@property (nonatomic, strong) PLVMediaPlayerSkinLockScreenView *lockScreenView;
@property (nonatomic, strong) PLVMediaPlayerSkinDefinitionView *definitionView;
@property (nonatomic, strong) PLVMediaPlayerSkinPlaybackRateView *playbackRateView;
@property (nonatomic, strong) PLVMediaPlayerSkinFastForwardView *fastForwardView;


@end

@implementation PLVShortVideoMediaPlayerSkinContainer

- (void)layoutSubviews{
    [super layoutSubviews];
    [self updateUI];
}

-(instancetype)init{
    if (self = [super initWithFrame:CGRectZero]){
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI{
    [self addSubview:self.portraitSkinView];

    [self addSubview:self.fullSkinView];
    self.fullSkinView.hidden = YES;
}

- (void)updateUI{
    BOOL fullScreen = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;
    
    if (fullScreen){
        self.portraitSkinView.hidden = YES;
        self.fullSkinView.hidden = NO;
        self.lockScreenView.hidden = NO;

        self.fullSkinView.frame = self.bounds;
        self.audioModeView.frame = self.bounds;
        self.lockScreenView.frame = self.bounds;
        if(!self.skinMoreView.hidden){
            self.skinMoreView.frame = self.bounds;
        }
        if(!self.definitionView.hidden){
            self.definitionView.frame = self.bounds;
        }
        if(!self.playbackRateView.hidden){
            self.playbackRateView.frame = self.bounds;
        }
        if (!self.fastForwardView.hidden){
            self.fastForwardView.frame = self.bounds;
        }
    }
    else{
        self.fullSkinView.hidden = YES;
        self.lockScreenView.hidden = YES;
        self.skinMoreView.hidden = YES;
        self.definitionView.hidden = YES;
        self.playbackRateView.hidden = YES;
        self.portraitSkinView.hidden = NO;
        self.portraitSkinView.frame = self.bounds;
        self.audioModeView.bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width*9/16);
        self.audioModeView.center = self.center;
        
        if (!self.fastForwardView.hidden){
            self.fastForwardView.frame = self.bounds;
        }
    }
}

- (PLVMediaPlayerShortPortraitSkinView *)portraitSkinView{
    if (!_portraitSkinView){
        _portraitSkinView = [[PLVMediaPlayerShortPortraitSkinView alloc] initWithSkinType:PLVMediaPlayerBaseSkinViewType_ShortPlayerPortrait];
        _portraitSkinView.baseDelegate = self;
    }
    
    return _portraitSkinView;
}

- (PLVMediaPlayerFullSkinView *)fullSkinView{
    if (!_fullSkinView){
        _fullSkinView = [[PLVMediaPlayerFullSkinView alloc] initWithSkinType:PLVMediaPlayerBaseSkinViewType_PlayerFull];
        _fullSkinView.baseDelegate = self;
        _fullSkinView.fullSkinDelegate = self;
    }
    
    return _fullSkinView;
}

- (PLVMediaPlayerSkinAudioModeView *)audioModeView{
    if (!_audioModeView){
        _audioModeView = [[PLVMediaPlayerSkinAudioModeView alloc] init];
        _audioModeView.delegate = self;
    }
    
    return _audioModeView;
}

- (PLVMediaPlayerSkinLockScreenView *)lockScreenView{
    if (!_lockScreenView){
        _lockScreenView = [[PLVMediaPlayerSkinLockScreenView alloc] init];
        _lockScreenView.delegate = self;
    }
    
    return _lockScreenView;
}

- (PLVMediaPlayerSkinMoreView *)skinMoreView{
    if (!_skinMoreView){
        _skinMoreView = [[PLVMediaPlayerSkinMoreView alloc] init];
        _skinMoreView.delegate = self;
    }
    
    return _skinMoreView;
}

- (PLVMediaPlayerSkinDefinitionView *)definitionView{
    if (!_definitionView){
        _definitionView = [[PLVMediaPlayerSkinDefinitionView alloc] init];
        _definitionView.delegate = self;
    }
    
    return _definitionView;
}

- (PLVMediaPlayerSkinPlaybackRateView *)playbackRateView{
    if (!_playbackRateView){
        _playbackRateView = [[PLVMediaPlayerSkinPlaybackRateView alloc] init];
        _playbackRateView.delegate = self;
    }
    
    return _playbackRateView;
}

- (PLVMediaPlayerSkinFastForwardView *)fastForwardView{
    if (!_fastForwardView){
        _fastForwardView = [[PLVMediaPlayerSkinFastForwardView alloc] init];
    }
    
    return _fastForwardView;
}

#pragma mark [PLVMediaPlayerBaseSkinViewDelegate]
- (void)plvLCBasePlayerSkinViewBackButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView currentFullScreen:(BOOL)currentFullScreen{
    if (currentFullScreen){
        // 返回竖屏
        [PLVVodFdUtil changeDeviceOrientation:UIDeviceOrientationPortrait];
    }
    else{
        // 返回事件
        if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainer_BackEvent:)]){
            [self.containerDelegate mediaPlayerSkinContainer_BackEvent:self];
        }
    }
}

-(void)plvLCBasePlayerSkinViewPictureInPictureButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView {
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainer_StartPictureInPicture:)]){
        [self.containerDelegate mediaPlayerSkinContainer_StartPictureInPicture:self];
    }
}

- (void)plvLCBasePlayerSkinViewMoreButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView{
    if ([skinView isKindOfClass:[PLVMediaPlayerFullSkinView class]]){
        // 横屏模式
        [self showMoreView];
    }
    else{
        // 竖屏模式
        if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainer_ShowMoreView:)]){
            [self.containerDelegate mediaPlayerSkinContainer_ShowMoreView:self];
        }
    }
}

- (void)showMoreView{
    [self.fullSkinView hiddenMediaPlayerFullSkinView:YES];
    [self addSubview:self.skinMoreView];
    [self bringSubviewToFront:self.skinMoreView];
    [self.skinMoreView showMoreViewWithModel:self.mediaPlayerState];
    
    [self layoutIfNeeded];
}

- (void)plvLCBasePlayerSkinViewPlayButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView wannaPlay:(BOOL)wannaPlay{
    if ([PLVMediaPlayerPictureInPictureManager sharedInstance].pictureInPictureActive) {
        return; // 开启画中画的时候不响应皮肤播放按钮
    }
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainer_Play:willPlay:)]){
        [self.containerDelegate mediaPlayerSkinContainer_Play:self willPlay:wannaPlay];
    }
}

- (void)plvLCBasePlayerSkinViewProgressViewPaned:(PLVMediaPlayerBaseSkinView *)skinView scrubTime:(NSTimeInterval)scrubTime {
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainer_ProgressViewPan:scrubTime:)]){
        [self.containerDelegate mediaPlayerSkinContainer_ProgressViewPan:self scrubTime:scrubTime];
    }
}

- (void)plvLCBasePlayerSkinView:(PLVMediaPlayerBaseSkinView *)skinView sliderDragEnd:(CGFloat)currentSliderProgress{
//    NSTimeInterval currentTime = self.mediaPlayer.duration * currentSliderProgress;
//    // 拖动进度条后，同步当前进度时间
//    [self.mediaPlayer seekToTime:currentTime];
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainer_SliderDragEnd:sliderValue:)]){
        [self.containerDelegate mediaPlayerSkinContainer_SliderDragEnd:self sliderValue:currentSliderProgress];
    }
}

- (void)plvLCBasePlayerSkinViewFullScreenOpenButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView{
    [PLVVodFdUtil changeDeviceOrientation:UIDeviceOrientationLandscapeLeft];
}

- (BOOL)plvLCBasePlayerSkinView:(PLVMediaPlayerBaseSkinView *)skinView askHandlerForTouchPointOnSkinView:(CGPoint)point{
    if ([PLVMediaPlayerBaseSkinView checkView:self.audioModeView.switchButton canBeHandlerForTouchPoint:point onSkinView:skinView]){
        /// 判断触摸事件是否应由 ‘音频模式按钮’ 处理
        return YES;
    }
    
    return NO;
}

- (void)plvLCBasePlayerSkinView:(PLVMediaPlayerBaseSkinView *)skinView longPressGestureStart:(UILongPressGestureRecognizer *)gesture{
    //
    if (!self.mediaPlayerState.isPlaying) return;
    
    [self addSubview:self.fastForwardView];
    [self bringSubviewToFront:self.fastForwardView];
    [self.fastForwardView show];
    // 更新播放速度
    if (self.mediaPlayerState.curPlayRate == 2.0) return;
    
    self.mediaPlayerState.origPlayRate = self.mediaPlayerState.curPlayRate;
    self.mediaPlayerState.curPlayRate = 2.0;
    [self mediaPlayerSkinPlaybackRateView_SwitchPlayRate:self.mediaPlayerState.curPlayRate];
}

- (void)plvLCBasePlayerSkinView:(PLVMediaPlayerBaseSkinView *)skinView longPressGestureEnd:(UILongPressGestureRecognizer *)gesture{
    //
    [self.fastForwardView hide];
    // 还原播放速率
    self.mediaPlayerState.curPlayRate = self.mediaPlayerState.origPlayRate;
    [self mediaPlayerSkinPlaybackRateView_SwitchPlayRate:self.mediaPlayerState.curPlayRate];
}

#pragma mark -- PLVMediaPlayerSkinAudioModeViewDelegate
- (void)mediaPlayerSkinAudioModeView_switchVideoMode:(PLVMediaPlayerSkinAudioModeView *)audioModeView{
    //
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainer_SwitchVideoMode:)]){
        [self.containerDelegate mediaPlayerSkinContainer_SwitchVideoMode:self];
    }
}

#pragma mark -- PLVMediaPlayerFullSkinViewDelegate
- (void)mediaPlayerFullSkinView_LockSceenEvent:(PLVMediaPlayerFullSkinView *)fullSkinView{
    [self showLockscreenUI];
}

- (void)showLockscreenUI{
    [self addSubview:self.lockScreenView];
    [self bringSubviewToFront:self.lockScreenView];
    
    [self.fullSkinView hiddenMediaPlayerFullSkinView:YES];
}

// 显示切换清晰度
- (void)mediaPlayerFullSkinView_SwitchQuality:(PLVMediaPlayerFullSkinView *)fullSkinView{
    [self addSubview:self.definitionView];
    [self bringSubviewToFront:self.definitionView];
    [self.definitionView showDefinitionViewWithModel:self.mediaPlayerState];
    [self.fullSkinView hiddenMediaPlayerFullSkinView:YES];
}

// 显示切换播放速度
- (void)mediaPlayerFullSkinView_SwitchPlayRate:(PLVMediaPlayerFullSkinView *)fullSkinView{
    [self addSubview:self.playbackRateView];
    [self bringSubviewToFront:self.playbackRateView];
    [self.playbackRateView showPlayRateViewWithModel:self.mediaPlayerState];
    [self.fullSkinView hiddenMediaPlayerFullSkinView:YES];
}

#pragma mark -- PLVMediaPlayerSkinMoreViewDelegate
- (void)mediaPlayerSkinMoreView_SwitchToAudioMode:(PLVMediaPlayerSkinMoreView *)moreView{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainer_SwitchToAudioMode:)]){
        [self.containerDelegate mediaPlayerSkinContainer_SwitchToAudioMode:self];
    }
}

- (void)mediaPlayerSkinMoreView_StartPictureInPicture:(PLVMediaPlayerSkinMoreView *)moreView{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainer_StartPictureInPicture:)]){
        [self.containerDelegate mediaPlayerSkinContainer_StartPictureInPicture:self];
    }
}

#pragma mark -- PLVMediaPlayerSkinDefinitionViewDelegate
- (void)mediaPlayerSkinDefinitionView_SwitchQualtiy:(NSInteger)qualityLevel{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainer_SwitchQualtiy:qualityLevel:)]){
        [self.containerDelegate mediaPlayerSkinContainer_SwitchQualtiy:self qualityLevel:qualityLevel];
    }
}

#pragma mark -- PLVMediaPlayerSkinPlaybackRateViewDelegate
- (void)mediaPlayerSkinPlaybackRateView_SwitchPlayRate:(CGFloat)playRate{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainer_SwitchPlayRate:playRate:)]){
        [self.containerDelegate mediaPlayerSkinContainer_SwitchPlayRate:self playRate:playRate];
    }
}

#pragma mark -- PLVMediaPlayerSkinLockScreenViewDelegate
- (void)mediaPlayerSkinLockScreenView_unlockScreenEvent:(PLVMediaPlayerSkinLockScreenView *)lockScreenView{
    [self recoveryFromLockScreenView];
}

- (void)recoveryFromLockScreenView{
    [self.lockScreenView removeFromSuperview];
}

#pragma mark -- public
- (void)syncSkinWithMode:(PLVMediaPlayerState *)mediaPlayerState{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mediaPlayerState = mediaPlayerState;
        // 横屏皮肤
        self.fullSkinView.qualityButton.hidden = mediaPlayerState.qualityCount > 1? NO:YES ;
        self.fullSkinView.titleLabel.text = mediaPlayerState.videoTitle;
        // 竖屏皮肤
        self.portraitSkinView.titleLabel.text = mediaPlayerState.videoTitle;
        self.portraitSkinView.fullScreenButton.hidden = mediaPlayerState.ratio > 1? NO:YES;
    });
}

- (void)showAudioModeUI{
    // 显示音频模式UI
    [self insertSubview:self.audioModeView belowSubview:self.portraitSkinView];
    [self layoutIfNeeded];
    
    // 配置封面图
    [self.audioModeView setMediaPlayerState:self.mediaPlayerState];
    [self.audioModeView startRotate];
}

- (void)showVideoModeUI{
    [self.audioModeView removeFromSuperview];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
