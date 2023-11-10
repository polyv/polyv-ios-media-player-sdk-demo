//
//  PLVDemoVodViewController.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/9.
//

#import "PLVDemoVodViewController.h"
#import "PLVVodMediaPlayerVC.h"
#import "PLVMediaPlayerSkinOutMoreView.h"
#import "PLVPictureInPictureRestoreManager.h"
#import "AppDelegate.h"
#import "PLVToast.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVVodErrorUtil.h"

@interface PLVDemoVodViewController ()<
PLVVodMediaPlayerVCDelegate,
PLVMediaPlayerSkinOutMoreViewDelegate
>

@property (nonatomic, strong) PLVVodMediaPlayerVC *vodPlayerVC;
@property (nonatomic, strong) PLVMediaPlayerSkinOutMoreView *skinMoreView;
@end

@implementation PLVDemoVodViewController

- (PLVVodMediaPlayerVC *)vodPlayerVC{
    if (!_vodPlayerVC){
        _vodPlayerVC = [[PLVVodMediaPlayerVC alloc] init];
        _vodPlayerVC.vcDelegate = self;
    }
    
    return _vodPlayerVC;
}

- (PLVMediaPlayerSkinOutMoreView *)skinMoreView{
    if (!_skinMoreView){
        _skinMoreView = [[PLVMediaPlayerSkinOutMoreView alloc] init];
        _skinMoreView.hidden = YES;
        _skinMoreView.skinOutMoreViewDelegate = self;
    }
    
    return _skinMoreView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.isSupportLandscape = YES;
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:15/255.0 green:32/255.0 blue:57.0/255.0 alpha:1.0];
    
    [self.view addSubview:self.vodPlayerVC.view];
    [self.view addSubview:self.skinMoreView];
    
    NSString *vid = @"e97dbe3e648aefc2eb6f68b96db9db6c_e";
    [self.vodPlayerVC playWithVid:vid];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    [self updateUI];
}

- (void)updateUI{
    UIEdgeInsets safeInset;

    if (@available(iOS 11.0, *)) {
        safeInset = self.view.safeAreaInsets;
    }
    BOOL fullScreen = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;
    if (fullScreen){
        self.vodPlayerVC.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    }
    else{
        // 竖屏
        self.vodPlayerVC.view.frame = CGRectMake(0, safeInset.top, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)*9/16);
        self.skinMoreView.frame = self.view.bounds;
    }
}

#pragma mark -- PLVVodMediaPlayerVCDelegate
- (void)vodMediaPlayerVC_ShowMoreView:(PLVVodMediaPlayerVC *)playerVC{
    [self.skinMoreView showMoreViewWithModel:[self.vodPlayerVC mediaPlayerState]];
}

- (void)vodMediaPlayerVC_BackEvent:(PLVVodMediaPlayerVC *)playerVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)vodMediaPlayerVC_PictureInPictureChangeState:(PLVVodMediaPlayerVC *)playerVC state:(PLVPictureInPictureState)state{
    if (state == PLVPictureInPictureStateDidStart) {
        // 画中画已经开启
        // 设定画中画恢复逻辑的处理者为PLVPictureInPictureRestoreManager
        [PLVMediaPlayerPictureInPictureManager sharedInstance].restoreDelegate = [PLVPictureInPictureRestoreManager sharedInstance];
        [PLVPictureInPictureRestoreManager sharedInstance].holdingViewController = self;
        [PLVPictureInPictureRestoreManager sharedInstance].restoreWithPresent = YES;
    
        // 退出当前界面
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (state == PLVPictureInPictureStateDidEnd) {
        // 画中画已经关闭
        // 清理恢复逻辑的处理者
        [[PLVPictureInPictureRestoreManager sharedInstance] cleanRestoreManager];
    }
}

- (void)vodMediaPlayerVC_StartPictureInPictureFailed:(PLVVodMediaPlayer *)playerVC error:(NSError *)error{
    //
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

#pragma mark -- PLVMediaPlayerSkinOutMoreViewDelegate
- (void)mediaPlayerSkinOutMoreView_SwitchPlayRate:(CGFloat)rate{
    [self.vodPlayerVC setPlayRate:rate];
}

- (void)mediaPlayerSkinOutMoreView_SwitchQualityLevel:(NSInteger)qualityLevel{
    [self.vodPlayerVC setPlayQuality:qualityLevel];
}

- (void)mediaPlayerSkinOutMoreView_SwitchToAudioMode{
    [self.vodPlayerVC setPlaybackMode:PLVVodPlaybackModeAudio];
    
    // 显示音频模式UI
    [self.vodPlayerVC showAudioModeUI];
}

- (void)mediaPlayerSkinOutMoreView_StartPictureInPicture{
    [self.vodPlayerVC.vodMediaPlayer startPictureInPicture];
}

@end
