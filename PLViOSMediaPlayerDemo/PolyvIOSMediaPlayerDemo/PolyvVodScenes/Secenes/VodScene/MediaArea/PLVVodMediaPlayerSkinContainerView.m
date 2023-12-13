//
//  PLVVodMediaPlayerSkinContainer.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/9.
//


#import "PLVVodMediaPlayerSkinContainerView.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

#import "PLVMediaPlayerSkinMoreView.h"
#import "PLVMediaPlayerSkinAudioModeView.h"
#import "PLVMediaPlayerSkinLockScreenView.h"
#import "PLVMediaPlayerSkinMoreView.h"
#import "PLVMediaPlayerSkinDefinitionView.h"
#import "PLVMediaPlayerSkinPlaybackRateView.h"
#import "PLVMediaPlayerSkinLoopPlayView.h"
#import "PLVMediaPlayerSkinFastForwardView.h"
#import "PLVOrientationUtil.h"

/// UI View Hierarchy
///
/// (UIView) self
///  ├── (PLVMediaPlayerPortraitHalfSkinView) portraitHalfSkinView
///  ├── (PLVMediaAreaLandscapeFullSkinView) landscapeFullSkinView

@interface PLVVodMediaPlayerSkinContainerView()<
PLVMediaAreaBaseSkinViewDelegate,
PLVMediaPlayerSkinAudioModeViewDelegate,
PLVMediaAreaLandscapeFullSkinViewDelegate,
PLVMediaPlayerSkinLockScreenViewDelegate,
PLVMediaPlayerSkinMoreViewDelegate,
PLVMediaPlayerSkinDefinitionViewDelegate,
PLVMediaPlayerSkinPlaybackRateViewDelegate,
PLVMediaPlayerSkinLoopPlayViewDelegate
>

@property (nonatomic, strong) PLVMediaPlayerSkinMoreView *skinMoreView;
@property (nonatomic, strong) PLVMediaPlayerSkinAudioModeView *audioModeView;
@property (nonatomic, strong) PLVMediaPlayerSkinLockScreenView *lockScreenView;
@property (nonatomic, strong) PLVMediaPlayerSkinDefinitionView *definitionView;
@property (nonatomic, strong) PLVMediaPlayerSkinPlaybackRateView *playbackRateView;
@property (nonatomic, strong) PLVMediaPlayerSkinLoopPlayView *loopPlayView;
@property (nonatomic, strong) PLVMediaPlayerSkinFastForwardView *fastForwardView;

@end

@implementation PLVVodMediaPlayerSkinContainerView

#pragma mark 【Life Cycle】
-(instancetype)init{
    if (self = [super initWithFrame:CGRectZero]){
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateUI];
}

#pragma mark 【UI setup & update】
- (void)setupUI {
    [self addSubview:self.portraitHalfSkinView];
    [self addSubview:self.landscapeFullSkinView];
}

- (void)updateUI {
    BOOL isLandscape = [PLVOrientationUtil isLandscape];
    
    if (isLandscape) { // 横向-全屏
        self.portraitHalfSkinView.hidden = YES;
        self.landscapeFullSkinView.hidden = NO;
        self.lockScreenView.hidden = NO;

        self.landscapeFullSkinView.frame = self.bounds;
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
        if (!self.loopPlayView.hidden){
            self.loopPlayView.frame = self.bounds;
        }
        if (!self.fastForwardView.hidden){
            self.fastForwardView.frame = self.bounds;
        }
    } else { // 竖向-半屏
        self.landscapeFullSkinView.hidden = YES;
        self.lockScreenView.hidden = YES;
        self.skinMoreView.hidden = YES;
        self.definitionView.hidden = YES;
        self.playbackRateView.hidden = YES;
        self.portraitHalfSkinView.hidden = NO;
        self.portraitHalfSkinView.frame = self.bounds;
        self.audioModeView.frame = self.bounds;
        
        if (!self.loopPlayView.hidden){
            self.loopPlayView.frame = self.bounds;
        }
        if (!self.fastForwardView.hidden){
            self.fastForwardView.frame = self.bounds;
        }
    }
}

#pragma mark 【Getter & Setter】
- (PLVMediaAreaPortraitHalfSkinView *)portraitHalfSkinView{
    if (!_portraitHalfSkinView){
        _portraitHalfSkinView = [[PLVMediaAreaPortraitHalfSkinView alloc] initWithSkinType:PLVMediaAreaBaseSkinViewType_Portrait_Half];
        _portraitHalfSkinView.baseDelegate = self;
    }
    return _portraitHalfSkinView;
}

- (PLVMediaAreaLandscapeFullSkinView *)landscapeFullSkinView{
    if (!_landscapeFullSkinView){
        _landscapeFullSkinView = [[PLVMediaAreaLandscapeFullSkinView alloc] initWithSkinType:PLVMediaAreaBaseSkinViewType_Landscape_Full];
        _landscapeFullSkinView.baseDelegate = self;
        _landscapeFullSkinView.fullSkinDelegate = self;
        _landscapeFullSkinView.hidden = YES;
    }
    return _landscapeFullSkinView;
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

- (PLVMediaPlayerSkinLoopPlayView *)loopPlayView{
    if (!_loopPlayView){
        _loopPlayView = [[PLVMediaPlayerSkinLoopPlayView alloc] init];
        _loopPlayView.delegate = self;
    }
    return _loopPlayView;
}

- (PLVMediaPlayerSkinFastForwardView *)fastForwardView{
    if (!_fastForwardView){
        _fastForwardView = [[PLVMediaPlayerSkinFastForwardView alloc] init];
    }
    return _fastForwardView;
}

#pragma mark 【Public Method】
- (void)syncSkinWithMode:(PLVMediaPlayerState *)mediaPlayerState{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mediaPlayerState = mediaPlayerState;
        // 横屏皮肤
        self.landscapeFullSkinView.qualityButton.hidden = mediaPlayerState.qualityCount > 1? NO:YES ;
        self.landscapeFullSkinView.titleLabel.text = mediaPlayerState.videoTitle;
        self.portraitHalfSkinView.titleLabel.text = mediaPlayerState.videoTitle;
    });
}

- (void)showAudioModeUI{
    // 显示音频模式UI
    [self insertSubview:self.audioModeView belowSubview:self.portraitHalfSkinView];
    [self layoutIfNeeded];
    
    // 配置封面图
    [self.audioModeView setMediaPlayerState:self.mediaPlayerState];
    [self.audioModeView startRotate];
}

- (void)showVideoModeUI{
    [self.audioModeView removeFromSuperview];
    [self.audioModeView stopRotate];
}

- (void)showLoopPlayUI{
    [self addSubview:self.loopPlayView];
    [self bringSubviewToFront:self.loopPlayView];
    [self.loopPlayView showMediaPlayerLoopPlayView];
    
    [self layoutIfNeeded];
}

#pragma mark 【PLVMediaPlayerBaseSkinViewDelegate 基础皮肤的回调方法】
/// 回退 按钮事件 回调方法
- (void)plvMediaAreaBaseSkinViewBackButtonClicked:(PLVMediaAreaBaseSkinView *)skinView{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainerView_BackEvent:)]){
        [self.containerDelegate mediaPlayerSkinContainerView_BackEvent:self];
    }
}

/// 画中画 按钮事件 回调方法
-(void)plvMediaAreaBaseSkinViewPictureInPictureButtonClicked:(PLVMediaAreaBaseSkinView *)skinView {
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainerView_StartPictureInPicture:)]){
        [self.containerDelegate mediaPlayerSkinContainerView_StartPictureInPicture:self];
    }
}

/// 更多 按钮事件 回调方法
- (void)plvMediaAreaBaseSkinViewMoreButtonClicked:(PLVMediaAreaBaseSkinView *)skinView{
    if ([skinView isKindOfClass:[PLVMediaAreaLandscapeFullSkinView class]]){ // 横屏模式
        // 显示 横屏状态的 更多弹层
        [self.landscapeFullSkinView hiddenMediaPlayerFullSkinView:YES];
        [self addSubview:self.skinMoreView];
        [self bringSubviewToFront:self.skinMoreView];
        [self.skinMoreView showMoreViewWithModel:self.mediaPlayerState];
        
        [self layoutIfNeeded];
    } else { // 竖屏模式
        if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainerView_ShowMoreView:)]){
            [self.containerDelegate mediaPlayerSkinContainerView_ShowMoreView:self];
        }
    }
}

/// 播放/暂停 按钮事件 回调方法
- (void)plvMediaAreaBaseSkinViewPlayButtonClicked:(PLVMediaAreaBaseSkinView *)skinView wannaPlay:(BOOL)wannaPlay{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainerView_Play:willPlay:)]){
        [self.containerDelegate mediaPlayerSkinContainerView_Play:self willPlay:wannaPlay];
    }
}

/// 全屏 按钮事件 回调方法
- (void)plvMediaAreaBaseSkinViewFullScreenOpenButtonClicked:(PLVMediaAreaBaseSkinView *)skinView{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainerView_FullScreenEvent:)]){
        [self.containerDelegate mediaPlayerSkinContainerView_FullScreenEvent:self];
    }
}

- (void)plvMediaAreaBaseSkinViewProgressViewPaned:(PLVMediaAreaBaseSkinView *)skinView scrubTime:(NSTimeInterval)scrubTime {
    // 拖动进度条面板后，同步当前进度时间
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainerview_ProgressViewPan:scrubTime:)]){
        [self.containerDelegate mediaPlayerSkinContainerview_ProgressViewPan:self scrubTime:scrubTime];
    }
}

- (void)plvMediaAreaBaseSkinView:(PLVMediaAreaBaseSkinView *)skinView sliderDragEnd:(CGFloat)currentSliderProgress{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainerView_SliderDragEnd:sliderValue:)]){
        [self.containerDelegate mediaPlayerSkinContainerView_SliderDragEnd:self sliderValue:currentSliderProgress];
    }
}

- (BOOL)plvMediaAreaBaseSkinView:(PLVMediaAreaBaseSkinView *)skinView askHandlerForTouchPointOnSkinView:(CGPoint)point{
    if ([PLVMediaAreaBaseSkinView checkView:self.audioModeView.switchButton canBeHandlerForTouchPoint:point onSkinView:skinView]){
        /// 判断触摸事件是否应由 ‘音频模式按钮’ 处理
        return YES;
    }
    
    return NO;
}

/// 长按开始 手势事件 回调方法
- (void)plvMediaAreaBaseSkinView:(PLVMediaAreaBaseSkinView *)skinView longPressGestureStart:(UILongPressGestureRecognizer *)gesture{
    //
    if (!self.mediaPlayerState.isPlaying ) return;
    
    [self addSubview:self.fastForwardView];
    [self bringSubviewToFront:self.fastForwardView];
    [self.fastForwardView show];
    // 更新播放速度
    if (self.mediaPlayerState.curPlayRate == 2.0) return;
    
    self.mediaPlayerState.origPlayRate = self.mediaPlayerState.curPlayRate;
    self.mediaPlayerState.curPlayRate = 2.0;
    [self mediaPlayerSkinPlaybackRateView_SwitchPlayRate:self.mediaPlayerState.curPlayRate];
}

/// 长按结束 手势事件 回调方法
- (void)plvMediaAreaBaseSkinView:(PLVMediaAreaBaseSkinView *)skinView longPressGestureEnd:(UILongPressGestureRecognizer *)gesture{
    //
    [self.fastForwardView hide];
    // 还原播放速率
    self.mediaPlayerState.curPlayRate = self.mediaPlayerState.origPlayRate;
    [self mediaPlayerSkinPlaybackRateView_SwitchPlayRate:self.mediaPlayerState.curPlayRate];
}

#pragma mark 【PLVMediaPlayerSkinAudioModeView Delegate - 音频模式视图的回调方法】
- (void)mediaPlayerSkinAudioModeView_switchVideoMode:(PLVMediaPlayerSkinAudioModeView *)audioModeView{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainerView_SwitchVideoMode:)]){
        [self.containerDelegate mediaPlayerSkinContainerView_SwitchVideoMode:self];
    }
}

#pragma mark 【PLVMediaPlayerLandscapeFullSkinView Delegate - 横向-全屏皮肤 回调方法】
/// 锁屏 按钮事件 回调方法
- (void)mediaAreaLandscapeFullSkinView_LockSceenEvent:(PLVMediaAreaLandscapeFullSkinView *)fullSkinView{
    // 显示锁屏状态
    self.mediaPlayerState.isLocking = YES;
    [self addSubview:self.lockScreenView];
    [self bringSubviewToFront:self.lockScreenView];
    
    [self.landscapeFullSkinView hiddenMediaPlayerFullSkinView:YES];
    
    [PLVOrientationUtil setNeedsUpdateOfSupportedInterfaceOrientations];
}

/// 清晰度 切换事件 回调方法
- (void)mediaAreaLandscapeFullSkinView_SwitchQuality:(PLVMediaAreaLandscapeFullSkinView *)fullSkinView{
    [self addSubview:self.definitionView];
    [self bringSubviewToFront:self.definitionView];
    [self.definitionView showDefinitionViewWithModel:self.mediaPlayerState];
    [self.landscapeFullSkinView hiddenMediaPlayerFullSkinView:YES];
}

/// 播放速度 切换事件 回调方法
- (void)mediaAreaLandscapeFullSkinView_SwitchPlayRate:(PLVMediaAreaLandscapeFullSkinView *)fullSkinView{
    [self addSubview:self.playbackRateView];
    [self bringSubviewToFront:self.playbackRateView];
    [self.playbackRateView showPlayRateViewWithModel:self.mediaPlayerState];
    [self.landscapeFullSkinView hiddenMediaPlayerFullSkinView:YES];
}

#pragma mark 【PLVMediaPlayerSkinMoreView Delegate - 外部更多弹层 回调方法】
/// 音频模式 按钮事件 回调方法
- (void)mediaPlayerSkinMoreView_SwitchToAudioMode:(PLVMediaPlayerSkinMoreView *)moreView{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainerView_SwitchToAudioMode:)]){
        [self.containerDelegate mediaPlayerSkinContainerView_SwitchToAudioMode:self];
    }
}

/// 画中画模式 按钮事件 回调方法
- (void)mediaPlayerSkinMoreView_StartPictureInPicture:(PLVMediaPlayerSkinMoreView *)moreView{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainerView_StartPictureInPicture:)]){
        [self.containerDelegate mediaPlayerSkinContainerView_StartPictureInPicture:self];
    }
}

#pragma mark 【PLVMediaPlayerSkinDefinitionView Delegate - 清晰度切换弹层 回调方法】
/// 清晰度 切换事件 回调方法
- (void)mediaPlayerSkinDefinitionView_SwitchQualtiy:(NSInteger)qualityLevel{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainerView_SwitchQualtiy:qualityLevel:)]){
        [self.containerDelegate mediaPlayerSkinContainerView_SwitchQualtiy:self qualityLevel:qualityLevel];
    }
}

#pragma mark 【PLVMediaPlayerSkinPlaybackRateView Delegate - 播放速度切换弹层 回调方法】
/// 播放速度 切换事件 回调方法
- (void)mediaPlayerSkinPlaybackRateView_SwitchPlayRate:(CGFloat)playRate{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainerView_SwitchPlayRate:playRate:)]){
        [self.containerDelegate mediaPlayerSkinContainerView_SwitchPlayRate:self playRate:playRate];
    }
}

#pragma mark 【PLVMediaPlayerSkinLockScreenView Delegate - 锁屏视图 回调方法】
/// 锁屏 按钮事件 回调方法
- (void)mediaPlayerSkinLockScreenView_unlockScreenEvent:(PLVMediaPlayerSkinLockScreenView *)lockScreenView{
    self.mediaPlayerState.isLocking = NO;
    [self.lockScreenView removeFromSuperview];
    
    [PLVOrientationUtil setNeedsUpdateOfSupportedInterfaceOrientations];
}

#pragma mark 【PLVMediaPlayerSkinLoopPlayView Delegate - 重新播放视图 回调方法】
- (void)mediaPlayerLoopPlayView_BackEvent:(PLVMediaPlayerSkinLoopPlayView *)loopPlayView{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainerView_BackEvent:)]){
        [self.containerDelegate mediaPlayerSkinContainerView_BackEvent:self];
    }
}

- (void)mediaPlayerLoopPlayView_LoopPlay:(PLVMediaPlayerSkinLoopPlayView *)loopPlayView{
    if (self.containerDelegate && [self.containerDelegate respondsToSelector:@selector(mediaPlayerSkinContainerView_Play:willPlay:)]){
        [self.containerDelegate mediaPlayerSkinContainerView_Play:self willPlay:YES];
    }
}

@end
