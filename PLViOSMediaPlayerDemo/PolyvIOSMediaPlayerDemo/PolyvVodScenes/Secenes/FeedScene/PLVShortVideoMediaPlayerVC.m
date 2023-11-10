//
//  PLVSkinVodMediaPlayerVC.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/29.
//

#import "PLVShortVideoMediaPlayerVC.h"
#import "PLVMediaPlayerShortPortraitSkinView.h"
#import <PLVIJKPlayer/PLVIJKPlayer.h>
#import "PLVShortVideoMediaPlayerSkinContainer.h"
#import "PLVMediaPlayerSkinOutMoreView.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Accelerate/Accelerate.h>
#import "PLVToast.h"
#import "PLVVodErrorUtil.h"

@interface PLVShortVideoMediaPlayerVC ()<
PLVPlayerCoreDelegate,
PLVVodMediaPlayerDelegate,
PLVMediaPlayerBaseSkinViewDelegate,
PLVShortVideoMediaPlayerSkinContainerDelegate,
PLVMediaPlayerSkinOutMoreViewDelegate
>

@property (nonatomic, strong) PLVShortVideoMediaPlayerSkinContainer *skinContainer;
@property (nonatomic, strong) PLVMediaPlayerSkinOutMoreView *skinOutMoreView;
@property (nonatomic, strong) UIView *displayView; // 视频内容区域父视图
@property (nonatomic, strong) UIImageView *displayCoverView; // 视频封面图

@property (nonatomic, strong) PLVMediaPlayerState *mediaPlayerState;
@property (nonatomic, assign ) BOOL isSwitchingPlaySource; // 切换播放源

@end

@implementation PLVShortVideoMediaPlayerVC

- (PLVVodMediaPlayer *)vodMediaPlayer{
    if (!_vodMediaPlayer){
        _vodMediaPlayer = [[PLVVodMediaPlayer alloc] init];
        _vodMediaPlayer.delegateVodMediaPlayer = self;
        _vodMediaPlayer.coreDelegate = self;
        _vodMediaPlayer.autoPlay = NO;
        _vodMediaPlayer.rememberLastPosition = YES;
        
    }
    
    return _vodMediaPlayer;
}

- (PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    if (!_skinContainer){
        _skinContainer = [[PLVShortVideoMediaPlayerSkinContainer alloc] init];
        _skinContainer.containerDelegate = self;
    }
    
    return _skinContainer;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:32/255.0 green:38/255.0 blue:57.0/255.0 alpha:1.0];
    
    [self setupUI];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    [self updateUI];
}

- (void)setFrame:(CGRect)frame{
    self.view.bounds = frame;
    [self updateUI];
}

- (void)updateUI{
    BOOL fullScreen = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;
    if (fullScreen){
        self.displayView.frame = self.view.bounds;
        self.displayView.center = self.view.center;
    }
    else{
        // 竖屏
        self.displayView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width/self.mediaPlayerState.ratio);
        self.displayView.center = self.view.center;
        self.skinOutMoreView.frame = self.view.bounds;
    }
    
    self.displayCoverView.bounds = self.displayView.bounds;
    self.displayCoverView.center = self.view.center;
    self.skinContainer.frame = self.view.bounds;
}

- (void)setupUI{
    [self.view addSubview:self.displayView];
    [self.vodMediaPlayer setupDisplaySuperview:self.displayView];
    
    [self.view addSubview:self.skinOutMoreView];
    [self.view addSubview:self.skinContainer];
    [self.view addSubview:self.displayCoverView];
}

#pragma mark PLVVodMediaPlayerSkinContainerDelegate
/// 竖屏时显示外部moreview 视图
- (void)mediaPlayerSkinContainer_ShowMoreView:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    [self.view bringSubviewToFront:self.skinOutMoreView];
    [self.skinOutMoreView showMoreViewWithModel:self.mediaPlayerState];
}

- (void)mediaPlayerSkinContainer_BackEvent:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(shortVideoMediaPlayerVC_BackEvent:)]){
        [self.vcDelegate shortVideoMediaPlayerVC_BackEvent:self];
    }
}

/// 切换到视频模式
- (void)mediaPlayerSkinContainer_SwitchVideoMode:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    [self.vodMediaPlayer setPlaybackMode:PLVVodPlaybackModeVideo];
    self.isSwitchingPlaySource = YES;

    [self.skinContainer showVideoModeUI];
}

/// 切换到音频模式
- (void)mediaPlayerSkinContainer_SwitchToAudioMode:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
    [self.vodMediaPlayer setPlaybackMode:PLVVodPlaybackModeAudio];
    self.mediaPlayerState.curPlayMode = 2;
    self.isSwitchingPlaySource = YES;
    [self.skinContainer showAudioModeUI];
}

/// 开启画中画播放
- (void)mediaPlayerSkinContainer_StartPictureInPicture:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer{
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
- (void)mediaPlayerSkinContainer_SwitchQualtiy:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer qualityLevel:(NSInteger)qualityLevel{
    [self.vodMediaPlayer setPlayQuality:(PLVVodQuality)qualityLevel];
    self.isSwitchingPlaySource = YES;
    self.mediaPlayerState.curQualityLevel = qualityLevel;

    // 刷新皮肤
    [self.skinContainer.fullSkinView updateQualityLevel:qualityLevel];
}

/// 切换播放速度
- (void)mediaPlayerSkinContainer_SwitchPlayRate:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer playRate:(CGFloat)playRate{
    [self.vodMediaPlayer switchSpeedRate:playRate];
    self.mediaPlayerState.curPlayRate = playRate;

    // 刷新皮肤
    [self.skinContainer.fullSkinView updatePlayRate:playRate];
}

#pragma mark -- PLVPlayerCoreDelegate
-(void)plvPlayerCore:(PLVPlayerCore *)player playerLoadStateDidChange:(PLVPlayerLoadState)loadState{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)plvPlayerCore:(PLVPlayerCore *)player playerIsPreparedToPlay:(BOOL)prepared{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (self.isSwitchingPlaySource){
        [player play];
        self.isSwitchingPlaySource = NO;
    }
    
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(shortVideoMediaPlayerVC_playerIsPreparedToPlay:)]){
        [self.vcDelegate shortVideoMediaPlayerVC_playerIsPreparedToPlay:self];
    }
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
        [self.vodMediaPlayer play];
    }
}

- (void)plvPlayerCore:(PLVPlayerCore *)player firstFrameRendered:(BOOL)rendered{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.displayCoverView removeFromSuperview];
//        [UIView transitionWithView:self.displayCoverView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//            UIVisualEffectView *visualView = nil;
//            for (UIView *item in self.displayCoverView.subviews){
//                if ([item isKindOfClass:[UIVisualEffectView class]]){
//                    visualView = (UIVisualEffectView*)item;
//                }
//            }
//            visualView.alpha = 0.0;
//
//        } completion:^(BOOL finished) {
//            self.displayCoverView.hidden = YES;
//        }];
    });
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
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(shortVideoMediaPlayerVC_PictureInPictureChangeState:state:)]){
        [self.vcDelegate shortVideoMediaPlayerVC_PictureInPictureChangeState:self state:pipState];
    }
    
    // 画中画结束
    if (pipState == PLVPictureInPictureStateDidEnd || pipState == PLVPictureInPictureStateWillEnd){
        // 恢复皮肤状态
        self.mediaPlayerState.curWindowMode = 1;
        [self.skinContainer syncSkinWithMode:self.mediaPlayerState];
    }
}

- (void)plvVodMediaPlayer:(PLVVodMediaPlayer *)vodMediaPlayer startPictureInPictureWithError:(NSError *)error{
    // 画中画开启失败
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(shortVideoMediaPlayerVC_StartPictureInPictureFailed:error:)]){
        [self.vcDelegate shortVideoMediaPlayerVC_StartPictureInPictureFailed:self error:error];
    }
    
    // 恢复皮肤状态
    self.mediaPlayerState.curWindowMode = 1;
    [self.skinContainer syncSkinWithMode:self.mediaPlayerState];

    // 抛出错误提示
    [self dealPictureInPictureErrorHandler:error];
}

/// 画中画错误回调
- (void)dealPictureInPictureErrorHandler:(NSError *)error {
    if ([error.domain isEqualToString:PLVVodErrorDomain]) {
        NSString *message = [NSString stringWithFormat:@"%@", [PLVVodErrorUtil getErrorMsgWithCode:error.code]];
        [PLVToast showMessage:message];
    }else {
        NSString *message = [NSString stringWithFormat:@"%@", error.localizedFailureReason];
        [PLVToast showMessage:message];
    }
}


#pragma mark public
- (void)syncPlayerStateWithModel:(PLVVodVideo *)videoModel{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mediaPlayerState.curQualityLevel = videoModel.preferredQuality;
        self.mediaPlayerState.qualityCount = videoModel.qualityCount;
        self.mediaPlayerState.isSupportAudioMode = [videoModel canSwithPlaybackMode];
        
        self.mediaPlayerState.snapshot = videoModel.snapshot;
        self.mediaPlayerState.ratio = videoModel.ratio;
        self.mediaPlayerState.videoTitle = videoModel.title;
        
        [self.displayCoverView sd_setImageWithURL:[NSURL URLWithString:videoModel.snapshot] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            //
//            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//            UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//            effectView.frame = self.displayCoverView.bounds;
//            effectView.alpha = 1.0;
//            [self.displayCoverView addSubview:effectView];
            
            if (image && [image isKindOfClass:[UIImage class]]){
                UIImage *blurimage = [self boxblurImageWithBlur:0.2 image:image];
                self.displayCoverView.image = blurimage;
            }
        }];
        // 同步播放器皮肤
        [self.skinContainer syncSkinWithMode:self.mediaPlayerState];
        
        [self updateUI];
    });
}

-(UIImage *)boxblurImageWithBlur:(CGFloat)blur image:(UIImage *)image {
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1); // convert to jpeg
    UIImage* destImage = [UIImage imageWithData:imageData];
    
    
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = destImage.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    
    vImage_Error error;
    
    void *pixelBuffer;
    
    
    //create vImage_Buffer with data from CGImageRef
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
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
    self.isSwitchingPlaySource = YES;
}

- (void)setPlaybackMode:(PLVVodPlaybackMode)playbackMode{
    [self.vodMediaPlayer setPlaybackMode:playbackMode];
    self.isSwitchingPlaySource = YES;
}

- (void)showVideoModeUI{
    [self.skinContainer showVideoModeUI];
}

- (void)startActive{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self play];
    });
}

- (void)endActive{
    [self.vodMediaPlayer pause];
    self.skinContainer.portraitSkinView.playButton.selected = NO;
    
    // 关闭菜单
    [self.skinOutMoreView hideMoreView];
}

#pragma mark Getter

- (UIView *)displayView{
    if (!_displayView){
        _displayView = [[UIView alloc] init];
    }
    
    return _displayView;
}

#pragma mark - [ Delegate ]
#pragma mark PLVLCBasePlayerSkinViewDelegate
- (void)plvLCBasePlayerSkinViewBackButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView currentFullScreen:(BOOL)currentFullScreen{
    if (currentFullScreen){
        // 返回竖屏
        [PLVVodFdUtil changeDeviceOrientation:UIDeviceOrientationPortrait];
    }
    else{
        if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(shortVideoMediaPlayerVC_BackEvent:)]){
            [self.vcDelegate shortVideoMediaPlayerVC_BackEvent:self];
        }
    }
}

-(void)plvLCBasePlayerSkinViewPictureInPictureButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView {
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

- (void)plvLCBasePlayerSkinViewMoreButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView{
//    [self.moreView showMoreViewOnSuperview:skinView.superview];
}

- (void)plvLCBasePlayerSkinViewPlayButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView wannaPlay:(BOOL)wannaPlay{
    if ([PLVMediaPlayerPictureInPictureManager sharedInstance].pictureInPictureActive) {
        return; // 开启画中画的时候不响应皮肤播放按钮
    }
    if (wannaPlay) {
        [self.vodMediaPlayer play];
    }else{
        [self.vodMediaPlayer pause];
    }
}

- (void)plvLCBasePlayerSkinViewProgressViewPaned:(PLVMediaPlayerBaseSkinView *)skinView scrubTime:(NSTimeInterval)scrubTime {
    // 拖动进度条后，同步当前进度时间
    [self.vodMediaPlayer seekToTime:scrubTime];
}

- (void)plvLCBasePlayerSkinViewFullScreenOpenButtonClicked:(PLVMediaPlayerBaseSkinView *)skinView{
    [PLVVodFdUtil changeDeviceOrientation:UIDeviceOrientationLandscapeLeft];
}

- (void)plvLCBasePlayerSkinView:(PLVMediaPlayerBaseSkinView *)skinView sliderDragEnd:(CGFloat)currentSliderProgress{
    NSTimeInterval currentTime = self.vodMediaPlayer.duration * currentSliderProgress;
    // 拖动进度条后，同步当前进度时间
    [self.vodMediaPlayer seekToTime:currentTime];
}

#pragma mark PLVShortVideoMediaPlayerSkinContainerDelegate
/// 播放、暂停事件
- (void)mediaPlayerSkinContainer_Play:(PLVShortVideoMediaPlayerSkinContainer *)skin willPlay:(BOOL)willPlay{
    if (willPlay){
        [self play];
    }
    else{
        [self.vodMediaPlayer pause];
    }
}

/// 进度面板
- (void)mediaPlayerSkinContainer_ProgressViewPan:(PLVShortVideoMediaPlayerSkinContainer *)skinContainer scrubTime:(NSTimeInterval)scrubTime{
    [self.vodMediaPlayer seekToTime:scrubTime];
}

/// 进度条
- (void)mediaPlayerSkinContainer_SliderDragEnd:(PLVShortVideoMediaPlayerSkinContainer *)skinContai sliderValue:(CGFloat)sliderValue{
    NSTimeInterval currentTime = self.vodMediaPlayer.duration * sliderValue;
    // 拖动进度条后，同步当前进度时间
    [self.vodMediaPlayer seekToTime:currentTime];}

#pragma [PUBLIC]
- (void)play{
    [self.vodMediaPlayer play];
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

- (void)pause{
    [self.vodMediaPlayer pause];
}

- (void)destroyPlayer{
    [self.vodMediaPlayer clearMainPlayer];
}

- (BOOL)isPlaying{
    return [self.vodMediaPlayer playing];
}

#pragma mark -- PLVMediaPlayerSkinOutMoreViewDelegate
- (void)mediaPlayerSkinOutMoreView_SwitchPlayRate:(CGFloat)rate{
    [self.vodMediaPlayer switchSpeedRate:rate];
    self.mediaPlayerState.curPlayRate = rate;
    
    // 刷新皮肤
    [self.skinContainer.fullSkinView updatePlayRate:rate];
}

- (void)mediaPlayerSkinOutMoreView_SwitchQualityLevel:(NSInteger)qualityLevel{
    [self.vodMediaPlayer setPlayQuality:(PLVVodQuality)qualityLevel];
    self.isSwitchingPlaySource = YES;
    self.mediaPlayerState.curQualityLevel = qualityLevel;

    // 刷新皮肤
    [self.skinContainer.fullSkinView updateQualityLevel:qualityLevel];
}

- (void)mediaPlayerSkinOutMoreView_SwitchToAudioMode{
    [self setPlaybackMode:PLVVodPlaybackModeAudio];
    self.isSwitchingPlaySource = YES;
    
    // 显示音频模式UI
    [self.skinContainer showAudioModeUI];
}

- (void)mediaPlayerSkinOutMoreView_StartPictureInPicture{
    [self.vodMediaPlayer startPictureInPicture];
}

//- (void)vodMediaPlayerVC_BackEvent:(PLVVodMediaPlayerVC *)playerVC{
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

@end
