//
//  PLVShortVideoFeedView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/4.
//

#import "PLVShortVideoFeedView.h"
#import "PLVFeedData.h"
#import "PLVShortVideoMediaPlayerVC.h"

@interface PLVShortVideoFeedView()<
PLVShortVideoMediaPlayerVCDelegate
>

@property (nonatomic, strong) PLVShortVideoMediaPlayerVC *mediaPlayer;
@property (nonatomic, strong) PLVFeedData *feedData;
@property (nonatomic, assign) BOOL isActive;

@end

@implementation PLVShortVideoFeedView

@synthesize reuseIdentifier;

#pragma mark - [ Life Cycle ]

- (void)dealloc {
}

#pragma mark - [ Override ]

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateUI];
}

#pragma mark - [ Public Method ]

- (instancetype)initWithWatchData:(PLVFeedData *)feedData {
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        self.reuseIdentifier = feedData.hashKey;
        _feedData = feedData;

        [self setupUI];
        [self setModule];
    }
    return self;
}

- (void)setupUI{
    self.mediaPlayer = [[PLVShortVideoMediaPlayerVC alloc] init];
    self.mediaPlayer.vcDelegate = self;
    self.mediaPlayer.view.frame = self.bounds;
    [self addSubview:self.mediaPlayer.view];
}

- (void)updateUI{
    //
    [self.mediaPlayer setFrame:self.bounds];
}

- (void)setModule{
    [self.mediaPlayer playWithVid:self.feedData.vid];
}

- (void)viewWillAppear {
    [self setNeedsLayout];
//    [self.playerVC cancelMute];
//    self.logoutWhenStopPictureInPicutre = NO;
}

- (void)viewWillDisappear {
   
}

#pragma mark PLVShortVideoMediaPlayerVCDelegate
- (void)shortVideoMediaPlayerVC_BackEvent:(PLVShortVideoMediaPlayerVC *)playerVC{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sceneViewWillExitController:)]){
        [self.delegate sceneViewWillExitController:self];
    }
}

- (void)shortVideoMediaPlayerVC_PictureInPictureChangeState:(PLVShortVideoMediaPlayerVC *)playerVC state:(PLVPictureInPictureState)state{
    // 画中画状态回调
    if (state == PLVPictureInPictureStateDidStart){
        if (self.delegate && [self.delegate respondsToSelector:@selector(sceneViewPictureInPictureDidStart:)]){
            [self.delegate sceneViewPictureInPictureDidStart:self];
        }
    }
    else if (state == PLVPictureInPictureStateDidEnd){
        if (self.delegate && [self.delegate respondsToSelector:@selector(sceneViewPictureInPictureDidEnd:)]){
            [self.delegate sceneViewPictureInPictureDidEnd:self];
        }
    }
}

- (void)shortVideoMediaPlayerVC_playerIsPreparedToPlay:(PLVShortVideoMediaPlayerVC *)playerVC{
    if (self.isActive){
        [playerVC play];
    }
    else{
        [playerVC pause];
    }
}

- (void)shortVideoMediaPlayerVC_StartPictureInPictureFailed:(PLVShortVideoMediaPlayerVC *)playerVC error:(NSError *)error{
    
}

#pragma mark PLVFeedItemCustomViewDelegate
- (void)setActive:(BOOL)active {
    if (active) {
        [self notifySceneViewBecomeActive];
    } else {
        [self notifySceneViewEndActive];
    }
}

- (void)notifySceneViewBecomeActive {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(sceneViewDidBecomeActive:)]) {
        [self.delegate sceneViewDidBecomeActive:self];
    }
    
    // 播放器视图展示
    self.isActive = YES;
    [self.mediaPlayer startActive];
}

- (void)notifySceneViewEndActive {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(sceneViewDidEndActive:)]) {
        [self.delegate sceneViewDidEndActive:self];
    }
    
    // 播放器视图消失
    self.isActive = NO;
    [self.mediaPlayer endActive];
}

/// 通知控制器退出
- (void)notifyControllerExit {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(sceneViewWillExitController:)]) {
        [self.delegate sceneViewWillExitController:self];
    }
}

- (BOOL)notifyPushController:(UIViewController *)vctrl {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(sceneView:pushController:)]) {
        return [self.delegate sceneView:self pushController:vctrl];
    } else {
        return NO;
    }
}

@end
