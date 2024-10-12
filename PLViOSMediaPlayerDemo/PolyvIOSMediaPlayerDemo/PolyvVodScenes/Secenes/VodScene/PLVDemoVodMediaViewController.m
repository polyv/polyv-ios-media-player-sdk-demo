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
#import "PLVDownloadCenterViewController.h"

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
        _isOffPlayModel = NO;
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
    }

    // Play Vid
    [self.vodMediaAreaVC playWithVid:self.vid];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    // 下载事件回调设置
    [self initDownloadModule];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    // 暂停播放
    [self.vodMediaAreaVC.player pause];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self updateUI];
}

#pragma mark 【UI setup & update】
- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithRed:15/255.0 green:32/255.0 blue:57.0/255.0 alpha:1.0];
    
    [self.view addSubview:self.vodMediaAreaVC.view];
    // 离线播放模式设置
    self.vodMediaAreaVC.mediaPlayerState.isOffPlayMode = self.isOffPlayModel;
    
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

/// 横屏 -开始下载
- (void)vodMediaAreaVC_StartDownloadEvent:(PLVVodMediaAreaVC *)playerVC{
    [self startDownload];
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

- (void)mediaPlayerSkinOutMoreView_StartDownload{
    [self startDownload];
}

#pragma mark [下载相关业务逻辑处理]
- (void)startDownload{
    PLVDownloadInfo *downloadItem = [[PLVDownloadManager sharedManager] getDownloadInfo:self.vid
                                                                               fileType:PLVDownloadFileTypeVideo];
    if (downloadItem){
        // 已经创建下载任务
        switch (downloadItem.state) {
            case PLVVodDownloadStatePreparing:
            case PLVVodDownloadStatePreparingTask:
            case PLVVodDownloadStateReady:
            case PLVVodDownloadStateStopping:
            case PLVVodDownloadStateStopped:{
                // 等待中 不处理 or (跳转下载中列表)
                [self pushToDownloadCenter:1];

            } break;
            case PLVVodDownloadStateRunning:{
                // 下载中 跳转下载中列表
                [self pushToDownloadCenter:1];

            } break;
            case PLVVodDownloadStateSuccess:{
                // 已完成 跳转完成列表
                [self pushToDownloadCenter:0];

            } break;
            case PLVVodDownloadStateFailed:{
                // 下载失败或者暂停 重新下载
                [self restartDownloadTask:downloadItem];

            } break;
        }
    }
    else{
        __weak typeof(self) weakSelf = self;
        // 调用可以缓存video 数据的方法
        [PLVVodMediaVideo requestVideoPriorityCacheWithVid:self.vid completion:^(PLVVodMediaVideo *video, NSError *error) {
            // 添加下载任务
            PLVDownloadInfo *downloadItem = [[PLVDownloadManager sharedManager] addVideoTask:video
                                                                                     quality:weakSelf.vodMediaAreaVC.mediaPlayerState.curQualityLevel];
            [weakSelf setDownloadEventWithItem:downloadItem];
        }];
    }
}

- (void)initDownloadModule{
    PLVDownloadInfo *downloadItem = [[PLVDownloadManager sharedManager] getDownloadInfo:self.vid 
                                                                               fileType:PLVDownloadFileTypeVideo];
    if (downloadItem){
        [self setDownloadEventWithItem:downloadItem];
        // 更新一次下载状态
        [self.skinOutMoreView.downloadProgressView updateDownloadState:downloadItem.state];
        [self.vodMediaAreaVC.mediaSkinContainer.skinMoreView.downloadProgressView updateDownloadState:downloadItem.state];
    }
    else{
        [self.skinOutMoreView.downloadProgressView resetProgressView];
        [self.vodMediaAreaVC.mediaSkinContainer.skinMoreView.downloadProgressView resetProgressView];
    }
}

- (void)restartDownloadTask:(PLVDownloadInfo *)downloadInfo{
    [[PLVDownloadManager sharedManager] startDownloadTask:downloadInfo highPriority:NO];
}

- (void)setDownloadEventWithItem:(PLVDownloadInfo *)downloadItem{
    __weak typeof(self) weakSelf = self;
    downloadItem.stateDidChangeBlock = ^(PLVDownloadInfo *info) {
        // 下载状态
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.skinOutMoreView.downloadProgressView updateDownloadState:info.state];
            [weakSelf.vodMediaAreaVC.mediaSkinContainer.skinMoreView.downloadProgressView updateDownloadState:info.state];
        });
    };
    
    downloadItem.progressDidChangeBlock = ^(PLVDownloadInfo *info) {
        // 下载进度
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.skinOutMoreView.downloadProgressView.progressView setProgress:info.progress];
            [weakSelf.vodMediaAreaVC.mediaSkinContainer.skinMoreView.downloadProgressView.progressView setProgress:info.progress];
        });
    };
}

- (void)pushToDownloadCenter:(NSInteger )selectIndex{
    // 竖屏模式才跳转
    if (![PLVVodMediaOrientationUtil isLandscape]){
        PLVDownloadCenterViewController *center = [[PLVDownloadCenterViewController alloc] init];
        center.selectedIndex = selectIndex;
        [self.navigationController pushViewController:center animated:YES];
    }
}

@end
