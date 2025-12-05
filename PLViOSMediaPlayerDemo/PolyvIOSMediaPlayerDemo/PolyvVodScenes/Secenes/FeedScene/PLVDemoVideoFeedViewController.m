//
//  PLVDemoVideoFeedViewController.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/4.
//

#import "PLVDemoVideoFeedViewController.h"
#import "PLVVodMediaFeedView.h"
#import "PLVShortVideoMediaAreaVC.h"
#import "PLVShortVideoFeedDataManager.h"
#import "PLVVodMediaPictureInPictureRestoreManager.h"
#import "PLVVodMediaOrientationUtil.h"

/// UI View Hierarchy
///
/// (UIView) self.view
///   └── (PLVVodMediaFeedView) feedView
///     └── (PLVShortVideoMediaAreaVC) feedViewItem

@interface PLVDemoVideoFeedViewController ()<
PLVVodMediaFeedViewDataSource,
PLVShortVideoMediaAreaVCDelegate
>

#pragma mark UI
@property (nonatomic, strong) PLVVodMediaFeedView *feedView; // Feed组件
@property (nonatomic, weak) PLVShortVideoMediaAreaVC *currentFeedItemView; // 当前显示的Feed item
@property (nonatomic, assign) NSInteger curIndex; // 当前显示的Feed item 索引

@property (nonatomic, strong) NSMutableArray<PLVVodMediaFeedData *> *dataSource;
@property (nonatomic, strong) PLVShortVideoFeedDataManager *dataManager;

@property (nonatomic, assign) BOOL isInited; // 是否已完成UI初始化

@end

@implementation PLVDemoVideoFeedViewController

#pragma mark - [ Life Cycle ]
- (instancetype)init {
    self = [super init];
    if (self) {
        _actionAfterPlayFinish = 1; // 0：显示播放结束UI  1：重新播放（缺省）  2：播放下一个
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self updateUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNavigationBarHidden:YES];
    
    [self enterFeedVC];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNavigationBarHidden:NO];

    [self leaveFeedVC];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)dealloc {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [PLVMediaPlayerPictureInPictureManager sharedInstance].canStartPictureInPictureAutomaticallyFromInline = NO;
}

#pragma mark 【UI setup & update】
- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithRed:32/255.0 green:38/255.0 blue:57.0/255.0 alpha:1.0];
    
    [self.view addSubview:self.feedView];
    
    [self setupOrientationNotification];
    
    [self loadData];
}

- (void)updateUI {
    UIEdgeInsets safeInset;
    if (@available(iOS 11.0, *)) {
        safeInset = self.view.safeAreaInsets;
    }
    
    BOOL isLandscape = [PLVVodMediaOrientationUtil isLandscape];
    if (isLandscape){ // 横向-全屏
        if (@available(iOS 26.0, *)){
            // iOS 26: 系统可能不会自动触发布局更新，需要手动调用
            [self.currentFeedItemView adaptUIForLandscape];
        }
        else if (@available(iOS 14.0, *)){
            // iOS 14-17: 系统函数调用，子控件自动更新布局
            // 部分设备需要手动调用
            if ([PLVVodMediaOrientationUtil isIPhone8Plus]){
                [self.currentFeedItemView adaptUIForLandscape];
            }
        }
        else{
            // iOS 14以下: 系统函数不自动调用，手动更新，feed流当前活动视图横屏适配
            [self.currentFeedItemView adaptUIForLandscape];
        }
    } else { // 竖向-全屏
        CGRect rect = CGRectMake(0, safeInset.top, self.view.bounds.size.width, self.view.bounds.size.height - safeInset.top -safeInset.bottom);
        if (CGRectEqualToRect(rect, self.feedView.frame)) {
            // 大小没变化，不需要重复设置
        } else {
            self.feedView.frame = rect;
        }
    }
}

- (void)leaveFeedVC{
    if (self.currentFeedItemView){
        [self.currentFeedItemView endActive];
    }
}

- (void)enterFeedVC{
    if (self.currentFeedItemView){
        [self.currentFeedItemView startActive];
    }
}

#pragma mark 【Test Data 测试数据模拟】
- (void)loadData{
    __weak typeof(self) weakSelf = self;
    [self.dataManager refreshDataWithCompletion:^{
        NSLog(@"PLVTEST 首次加载");
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.feedView.collectionView reloadData];
        });
    } failure:^(NSError * error) {
        NSLog(@"PLVTEST 首次加载");
    }];
}

#pragma mark 【Getter & Setter】
- (PLVShortVideoFeedDataManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [[PLVShortVideoFeedDataManager alloc] init];
    }
    return _dataManager;
}

- (NSMutableArray<PLVVodMediaFeedData *> *)dataSource{
    if (!_dataSource){
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (PLVVodMediaFeedView *)feedView{
    if (!_feedView){
        self.feedView = [[PLVVodMediaFeedView alloc] init];
        self.feedView.dataSource = self;
    }
    return _feedView;
}

#pragma mark 【Orientation 横竖屏】
#pragma mark 【Orientation 横竖屏设置】
- (BOOL)shouldAutorotate{
    if (self.currentFeedItemView.mediaPlayerState.ratio <= 1) { // 当前 feedIemtView 的视频方向是竖向的，不支持方向切换
        return NO;
    } else if (self.currentFeedItemView.mediaPlayerState.isLocking) { // 当前 feedIemtView 是锁屏状态，不支持方向切换
        return NO;
    } else { // 支持方向切换
        return YES;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if (self.currentFeedItemView.mediaPlayerState.ratio <= 1) { // 当前 feedIemtView 视频方向是竖向的，只支持竖向
        return UIInterfaceOrientationMaskPortrait;
    } else if (self.currentFeedItemView.mediaPlayerState.isLocking) { // 当前 feedIemtView 是锁屏状态，只支持横向
        return UIInterfaceOrientationMaskLandscape;
    } else { // 同时 支持 竖向 和 横向
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
    }
}

- (void)setupOrientationNotification{
    // 通用的 配置
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interfaceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark 【Back 页面返回处理】

- (void)exitCurrentController {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark 【PLVVodMediaFeedViewDataSource Delegate - Feed流 数据源 回调方法】
- (NSInteger)numberOfSectionsInFeedView:(PLVVodMediaFeedView *)feedView {
    return 1;
}

- (NSInteger)feedView:(PLVVodMediaFeedView *)feedView numberOfItemsInSection:(NSInteger)section {
    return [self.dataManager.feedDataArray count];
}

- (UIView <PLVVodMediaFeedItemCustomViewDelegate>*)feedView:(PLVVodMediaFeedView *)feedView contentViewForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataManager.feedDataArray.count == indexPath.row){
        return  nil;
    }
    PLVVodMediaFeedData *feedData = self.dataManager.feedDataArray[indexPath.row];
    feedData.index = indexPath.row;
    PLVShortVideoMediaAreaVC *feedItemView = (PLVShortVideoMediaAreaVC *)[feedView dequeueReusableFeedItemCustomViewWithIdentifier:feedData.hashKey];
    if (!feedItemView) {
        feedItemView = [[PLVShortVideoMediaAreaVC alloc] init];
        // 设置系统截屏保护
        feedItemView.sysScreenShotProtect = self.sysScreenShotProtect;
        feedItemView.feedData = feedData;
        feedItemView.mediaAreaVcDelegate = self;
        if (self.isHideProtraitBackButton) {
            [feedItemView hideProtraitBackButton];
        }
        
        [feedItemView playWithVid:feedData.vid];
    }
    return feedItemView;
}

- (void)feedViewNeedsRefresh:(PLVVodMediaFeedView *)feedView completion:(void (^)(BOOL))completion {
    [self.dataManager refreshDataWithCompletion:^{
        NSLog(@"PLVTEST -请求刷新成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.feedView.collectionView reloadData];
        });
        if (completion) {
            completion (YES);
        }
    } failure:^(NSError * error) {
        NSLog(@"PLVTEST -请求刷新失败");
        if (completion) {
            completion (NO);
        }
    }];
}

- (void)feedViewNeedsLoadMore:(PLVVodMediaFeedView *)feedView completion:(void (^)(BOOL))completion {
    [self.dataManager loadMoreDataWithCompletion:^(BOOL lastPage) {
        NSLog(@"PLVTEST -请求加载成功");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.feedView.collectionView reloadData];
        });
        if (completion) {
            completion (lastPage);
        }
    } failure:^(NSError * error) {
        NSLog(@"PLVTEST -请求加载失败");
        if (completion) {
            completion (NO);
        }
    }];
}

#pragma mark 【PLVShortVideoMediaAreaVCDelegate - Feed流Item 代理 回调方法】
/// 返回事件
- (void)shortVideoMediaAreaVC_BackEvent:(PLVShortVideoMediaAreaVC *)mediaAreaVC {
    [self.feedView clear];
    [self exitCurrentController];
}

/// 播放完毕
- (void)shortVideoMediaAreaVC_PlayFinishEvent:(PLVShortVideoMediaAreaVC *)mediaAreaVC { // 0：显示播放结束UI  1：重新播放（缺省）  2：播放下一个
    if ([PLVMediaPlayerPictureInPictureManager sharedInstance].pictureInPictureActive) {
        // 显示播放结束UI
        return;
    }
    
    if (self.actionAfterPlayFinish == 0) { // 0：显示播放结束UI
        // 暂无 播放结束UI
    } else if (self.actionAfterPlayFinish == 1) { // 1：重新播放（ß缺省）
        [mediaAreaVC play];
    } else if (self.actionAfterPlayFinish == 2) { // 2：播放下一个
        NSInteger index = mediaAreaVC.feedData.index;
        NSInteger nextIndex = index + 1;
        if (nextIndex < self.dataManager.feedDataArray.count) {
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:nextIndex inSection:0];;
            [self.feedView.collectionView scrollToItemAtIndexPath:nextIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];

        }
     }
}

/// 切换为激活状态
- (void)shortVideoMediaAreaVC_BecomeActive:(PLVShortVideoMediaAreaVC *)mediaAreaVC {
    self.currentFeedItemView = mediaAreaVC;
    _curIndex = mediaAreaVC.feedData.index;
    [PLVVodMediaOrientationUtil setNeedsUpdateOfSupportedInterfaceOrientations];
    NSLog(@"%@ :curindex: %ld", NSStringFromSelector(_cmd), _curIndex);
}

/// 切换为非激活状态
- (void)shortVideoMediaAreaVC_EndActive:(PLVShortVideoMediaAreaVC *)mediaAreaVC {
    if (self.currentFeedItemView == mediaAreaVC){
        self.currentFeedItemView = nil;
    }
}

/// 画中画状态回调
- (void)shortVideoMediaAreaVC_PictureInPictureChangeState:(PLVShortVideoMediaAreaVC *)mediaAreaVC state:(PLVPictureInPictureState )state {
    // 画中画状态回调
    if (state == PLVPictureInPictureStateDidStart){
        [PLVMediaPlayerPictureInPictureManager sharedInstance].restoreDelegate = [PLVVodMediaPictureInPictureRestoreManager sharedInstance];
        [PLVVodMediaPictureInPictureRestoreManager sharedInstance].holdingViewController = self;
        [PLVVodMediaPictureInPictureRestoreManager sharedInstance].restoreWithPresent = YES;

        if ([PLVMediaPlayerPictureInPictureManager sharedInstance].isBackgroudStartMode){
            // 停留在当前界面，客户也可以自定义交互
        }
        else{
            // 退出当前界面
            [self exitCurrentController];
        }
    } else if (state == PLVPictureInPictureStateDidEnd){
        [[PLVVodMediaPictureInPictureRestoreManager sharedInstance] cleanRestoreManager];
    }
}

/// 画中画开启失败
- (void)shortVideoMediaAreaVC_StartPictureInPictureFailed:(PLVShortVideoMediaAreaVC *)mediaAreaVC error:(NSError *)error {
    
}

/// 即将开始播放
- (void)shortVideoMediaAreaVC_playerIsPreparedToPlay:(PLVShortVideoMediaAreaVC *)mediaAreaVC {
    if (mediaAreaVC == self.currentFeedItemView) {
        [mediaAreaVC play];
    } else {
        [mediaAreaVC pause];
    }
}

// 需要push/present新页面时触发，由页面容器类push/present新页面
- (BOOL)shortVideoMediaAreaVC:(PLVShortVideoMediaAreaVC *)mediaAreaVC pushController:(UIViewController *)vctrl {
    if (self.navigationController) {
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:vctrl animated:YES];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark [录屏保护]
- (void)startPreventScreenCapture{
    [super startPreventScreenCapture];
    
    // 暂停播放
    [self.currentFeedItemView.player pause];
    self.currentFeedItemView.hidden = YES;
    // 保存播放器状态
    self.isPlayingWhenCaptureStart = self.currentFeedItemView.player.playing;
}

- (void)stopPreventScreenCapture{
    [super stopPreventScreenCapture];
    
    // 恢复播放状态
    if (self.isPlayingWhenCaptureStart){
        [self.currentFeedItemView.player play];
        self.currentFeedItemView.hidden = NO;

    }
}

@end
