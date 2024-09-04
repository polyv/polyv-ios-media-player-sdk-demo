//
//  PLVDemoVodViewController.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/9.
//

#import "PLVDemoVodMediaViewController.h"
#import "PLVVodMediaAreaVC.h"
#import "PLVMediaPlayerSkinOutMoreView.h"
#import "PLVVodMediaPictureInPictureRestoreManager.h"
#import "AppDelegate.h"
#import "PLVVodMediaToast.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVVodMediaErrorUtil.h"
#import "PLVVodMediaOrientationUtil.h"

/// UI View Hierarchy
///
/// (UIView) self.view
///  ├── (PLVVodMediaAreaVC) vodMediaAreaVC
///  ├── (PLVMediaPlayerSkinOutMoreView) skinOutMoreView

@interface PLVDemoVodMediaViewController ()<
PLVVodMediaAreaVCDelegate,
PLVMediaPlayerSkinOutMoreViewDelegate
>

@property (nonatomic, strong) PLVVodMediaAreaVC *vodMediaAreaVC;
@property (nonatomic, strong) PLVMediaPlayerSkinOutMoreView *skinOutMoreView;

@end

@implementation PLVDemoVodMediaViewController

#pragma mark 【Life Cycle】
- (void)dealloc{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [PLVMediaPlayerPictureInPictureManager sharedInstance].canStartPictureInPictureAutomaticallyFromInline = NO;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _actionAfterPlayFinish = 0; // 0：显示播放结束UI（缺省）  1：重新播放  2：播放下一个
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Setup UI
    [self setupUI];
    
    // Setup Data
    if (!self.vid) {
        NSLog(@"Warning -- Vid is null!!! Set test vid instead!");
        self.vid = [self testVid];
    }

    // Play Vid
    [self.vodMediaAreaVC playWithVid:self.vid];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self updateUI];
}

#pragma mark 【UI setup & update】
- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithRed:15/255.0 green:32/255.0 blue:57.0/255.0 alpha:1.0];
    
    [self.view addSubview:self.vodMediaAreaVC.view];
    [self.view addSubview:self.skinOutMoreView];
}

- (void)updateUI{
    [self updateUIForOrientation];
}

#pragma mark 【Back 页面返回处理】
- (void)back {
    if (self.navigationController){
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark 【Getter & Setter】
- (PLVVodMediaAreaVC *)vodMediaAreaVC{
    if (!_vodMediaAreaVC){
        _vodMediaAreaVC = [[PLVVodMediaAreaVC alloc] init];
        _vodMediaAreaVC.mediaAreaVcDelegate = self;
    }
    return _vodMediaAreaVC;
}

- (PLVMediaPlayerSkinOutMoreView *)skinOutMoreView{
    if (!_skinOutMoreView){
        _skinOutMoreView = [[PLVMediaPlayerSkinOutMoreView alloc] init];
        _skinOutMoreView.hidden = YES;
        _skinOutMoreView.skinOutMoreViewDelegate = self;
    }
    return _skinOutMoreView;
}

#pragma mark 【Test Data 测试数据模拟】
- (NSString *)testVid {
    NSString *vid = @"a0f97cbb565ea16cbdea547040669841_a"; // 私有加密 lien
//    vid = @"a0f97cbb567948c6d3544ca11d5e4b9e_a"; // 源视频 lien (ok)
//    vid = @"a0f97cbb565ea16cbdea547040669841_a"; // 多分辨率加密视频 lien
//    vid = @"a0f97cbb565c26a5e04055f135fb04bf_a";   // app级别加密
    vid = @"e97dbe3e648aefc2eb6f68b96db9db6c_e"; // 公号点播
    vid = @"a0f97cbb56ae78349fb12567623fb411_a"; // 字幕测试
    return vid;
}

#pragma mark 【Orientation 横竖屏设置】
- (BOOL)shouldAutorotate{
    return self.vodMediaAreaVC.mediaPlayerState.isLocking ? NO : YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if (self.vodMediaAreaVC.mediaPlayerState.isLocking) {
        return UIInterfaceOrientationMaskLandscape;
    } else {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
    }
}

/// 更新 播放器皮肤 —— 触发 竖向-半屏皮肤 和 横向-全屏皮肤 的切换
- (void)updateUIForOrientation{
    BOOL isFullScreen = [PLVVodMediaOrientationUtil isLandscape];
    if (isFullScreen){ // 横向-全屏
        self.vodMediaAreaVC.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    } else { // 竖向-半屏
        CGFloat y = 0;
        if (@available(iOS 11.0, *)) {
            UIEdgeInsets safeInset;
            safeInset = self.view.safeAreaInsets;
            y = safeInset.top;
        }
        self.vodMediaAreaVC.view.frame = CGRectMake(0, y, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)*9/16);
        self.skinOutMoreView.frame = self.view.bounds;
    }
}

#pragma mark 【PictureInPicture 画中画功能】
- (void)changePictureInPictureState:(PLVPictureInPictureState)state {
    if (state == PLVPictureInPictureStateDidStart) { // 启动 画中画
        // 画中画已经开启
        // 设定画中画恢复逻辑的处理者为PLVVodMediaPictureInPictureRestoreManager
        [PLVMediaPlayerPictureInPictureManager sharedInstance].restoreDelegate = [PLVVodMediaPictureInPictureRestoreManager sharedInstance];
        [PLVVodMediaPictureInPictureRestoreManager sharedInstance].holdingViewController = self;
        [PLVVodMediaPictureInPictureRestoreManager sharedInstance].restoreWithPresent = YES;
    
        if ([PLVMediaPlayerPictureInPictureManager sharedInstance].isBackgroudStartMode){
            // 停留在当前界面，客户也可以自定义交互
        }
        else{
            // 退出当前界面
            if (self.navigationController){
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    } else if (state == PLVPictureInPictureStateDidEnd) { // 关闭 画中画
        // 画中画已经关闭
        // 清理恢复逻辑的处理者
        [[PLVVodMediaPictureInPictureRestoreManager sharedInstance] cleanRestoreManager];
    }
}

- (void)startPictureInPictureFailed:(NSError *)error {
    if ([error.domain isEqualToString:PLVVodMediaErrorDomain]) {
        NSString *message = [NSString stringWithFormat:@"%@", [PLVVodMediaErrorUtil getErrorMsgWithCode:error.code]];
        [PLVVodMediaToast showMessage:message];
    } else {
        NSString *message = [NSString stringWithFormat:@"%@", error.localizedFailureReason];
        [PLVVodMediaToast showMessage:message];
    }
}

#pragma mark 【PLVVodMediaAreaVC Delegate - 视频区域 回调方法】
/// 竖向-半屏 皮肤下，显示 外部的 更多弹层
- (void)vodMediaAreaVC_ShowMoreView:(PLVVodMediaAreaVC *)playerVC{
    [self.skinOutMoreView showMoreViewWithModel:self.vodMediaAreaVC.mediaPlayerState];
}

/// 返回 按钮事件回调
- (void)vodMediaAreaVC_BackEvent:(PLVVodMediaAreaVC *)playerVC{
    [self back];
}

/// 播放结束事件
- (void)vodMediaAreaVC_PlayFinishEvent:(PLVVodMediaAreaVC *)playerVC { // 0：显示播放结束UI（缺省）  1：重新播放  2：播放下一个
    if ([PLVMediaPlayerPictureInPictureManager sharedInstance].pictureInPictureActive) {
        [self.vodMediaAreaVC showPlayFinishUI];
        return;
    }
    
    if (self.actionAfterPlayFinish == 0) { // 0：显示播放结束UI（缺省）
        [self.vodMediaAreaVC showPlayFinishUI];
    } else if (self.actionAfterPlayFinish == 1) { // 1：重新播放
        [self.vodMediaAreaVC replay];
    } else if (self.actionAfterPlayFinish == 2) { // 2：播放下一个
       // 客户自定义
    }
}


/// 画中画 切换状态
- (void)vodMediaAreaVC_PictureInPictureChangeState:(PLVVodMediaAreaVC *)playerVC state:(PLVPictureInPictureState)state{
    [self changePictureInPictureState:state];
}

/// 画中画 错误回调
- (void)vodMediaAreaVC_StartPictureInPictureFailed:(PLVVodMediaPlayer *)playerVC error:(NSError *)error{
    [self startPictureInPictureFailed:error];
}

#pragma mark 【PLVMediaPlayerSkinOutMoreView Delegate - 更多弹层 回调方法】
- (void)mediaPlayerSkinOutMoreView_SwitchPlayRate:(CGFloat)rate{
    [self.vodMediaAreaVC setPlayRate:rate];
}

- (void)mediaPlayerSkinOutMoreView_SwitchQualityLevel:(NSInteger)qualityLevel{
    [self.vodMediaAreaVC setPlayQuality:qualityLevel];
}

- (void)mediaPlayerSkinOutMoreView_SwitchPlayMode:(PLVMediaPlayerSkinOutMoreView *)outMoreView{
    if (PLVMediaPlayerPlayModeAudio == outMoreView.mediaPlayerState.curPlayMode){
        [self.vodMediaAreaVC setPlaykMode:PLVVodMediaPlaybackModeAudio];
    }
    else if (PLVMediaPlayerPlayModeVideo == outMoreView.mediaPlayerState.curPlayMode){
        [self.vodMediaAreaVC setPlaykMode:PLVVodMediaPlaybackModeVideo];
    }
}

- (void)mediaPlayerSkinOutMoreView_StartPictureInPicture{
    if ([PLVMediaPlayerPictureInPictureManager sharedInstance].pictureInPictureActive){
        [self.vodMediaAreaVC.player stopPictureInPicture];
    }
    else{
        [self.vodMediaAreaVC.player startPictureInPicture];
    }
}

- (void)mediaPlayerSkinOutMoreView_SetSubtitle{
    [self.vodMediaAreaVC updateVideoSubtile];
}

@end
