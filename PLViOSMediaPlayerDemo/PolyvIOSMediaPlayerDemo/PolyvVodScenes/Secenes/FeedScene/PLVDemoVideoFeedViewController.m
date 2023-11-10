//
//  PLVDemoVideoFeedViewController.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/4.
//

#import "PLVDemoVideoFeedViewController.h"
//#import "PLVBaseNavigationController.h"
#import "PLVFeedView.h"
#import "PLVShortVideoFeedView.h"
#import "PLVShortVideoFeedDataManager.h"
#import "PLVPictureInPictureRestoreManager.h"
#import "AppDelegate.h"

@interface PLVDemoVideoFeedViewController ()<
PLVFeedViewDataSource,
PLVShortVideoFeedViewDelegate
>

#pragma mark UI
/// view hierarchy
///
/// (UIView) self.view
///   └── (PLVFeedView) feedView
@property (nonatomic, strong) PLVFeedView *feedView; // feed组件
@property (nonatomic, weak) PLVShortVideoFeedView *currentFeedItemView;
@property (nonatomic, assign) NSInteger curIndex;

@property (nonatomic, strong) NSMutableArray<PLVFeedData *> *dataSource;
@property (nonatomic, strong) PLVShortVideoFeedDataManager *dataManager;

@end

@implementation PLVDemoVideoFeedViewController

#pragma mark - [ Life Cycle ]

- (void)dealloc {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)develeperTest{
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

- (PLVShortVideoFeedDataManager *)dataManager {
    if (!_dataManager) {
        _dataManager = [[PLVShortVideoFeedDataManager alloc] init];
    }
    return _dataManager;
}

- (NSMutableArray<PLVFeedData *> *)dataSource{
    if (!_dataSource){
        _dataSource = [[NSMutableArray alloc] init];
    }
    
    return _dataSource;
}

- (PLVFeedView *)feedView{
    if (!_feedView){
        self.feedView = [[PLVFeedView alloc] init];
        self.feedView.dataSource = self;
    }
    
    return _feedView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    app.isSupportLandscape = YES;
    
    self.view.backgroundColor = [UIColor colorWithRed:32/255.0 green:38/255.0 blue:57.0/255.0 alpha:1.0];
    
    [self develeperTest];
    
    [self.view addSubview:self.feedView];
    
    [self setupModule];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // 必须放在此处更新，safeAreaInset 才有值
    [self updateUI];
}

- (void)updateUI{
    UIEdgeInsets safeInset;
    if (@available(iOS 11.0, *)) {
        safeInset = self.view.safeAreaInsets;
    }
    BOOL fullScreen = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;
    if (fullScreen){
        self.feedView.frame = self.view.bounds;
    }
    else{
        // 竖屏
        self.feedView.frame = CGRectMake(0, safeInset.top, self.view.bounds.size.width, self.view.bounds.size.height - safeInset.top -safeInset.bottom);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

#pragma mark - [ Override ]

#pragma mark - [ Public Method ]

#pragma mark - [ Private Method ]

- (void)exitCurrentController {
    [self.feedView clear];
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - [ Delegate ]

#pragma mark PLVFeedViewDataSource

- (NSInteger)numberOfSectionsInFeedView:(PLVFeedView *)feedView {
    return 1;
}

- (NSInteger)feedView:(PLVFeedView *)feedView numberOfItemsInSection:(NSInteger)section {
    return [self.dataManager.feedDataArray count];
}

// 提供显示数据
- (UIView <PLVFeedItemCustomViewDelegate>*)feedView:(PLVFeedView *)feedView contentViewForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataManager.feedDataArray.count == indexPath.row){
        return  nil;
    }
    
    PLVFeedData *feedData = self.dataManager.feedDataArray[indexPath.row];
    feedData.index = indexPath.row;
    PLVShortVideoFeedView *feedItemView = (PLVShortVideoFeedView *)[feedView dequeueReusableFeedItemCustomViewWithIdentifier:feedData.hashKey];
    if (!feedItemView) {
        feedItemView = [[PLVShortVideoFeedView alloc] initWithWatchData:feedData];
        feedItemView.delegate = self;
    }
    
    return feedItemView;
}

- (void)feedViewNeedsRefresh:(PLVFeedView *)feedView completion:(void (^)(BOOL))completion {
    [self.dataManager refreshDataWithCompletion:^{
        NSLog(@"PLVTEST -请求刷新成功");
        [self.feedView.collectionView reloadData];
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

- (void)feedViewNeedsLoadMore:(PLVFeedView *)feedView completion:(void (^)(BOOL))completion {
    [self.dataManager loadMoreDataWithCompletion:^(BOOL lastPage) {
        NSLog(@"PLVTEST -请求加载成功");
        [self.feedView.collectionView reloadData];
        if (completion) {
            completion (lastPage);
        }
    } failure:^(NSError * error) {
        if (completion) {
            completion (NO);
        }
    }];
}

#pragma mark PLVShortVideoFeedViewDelegate
- (void)sceneViewDidBecomeActive:(PLVShortVideoFeedView *)sceneView {
    self.currentFeedItemView = sceneView;
    _curIndex = sceneView.feedData.index;
    NSLog(@"%@ :curindex: %ld", NSStringFromSelector(_cmd), _curIndex);
}

- (void)sceneViewDidEndActive:(PLVShortVideoFeedView *)sceneView {
    if (self.currentFeedItemView == sceneView){
        self.currentFeedItemView = nil;
    }
}

- (void)sceneViewWillExitController:(PLVShortVideoFeedView *)sceneView {
    [self exitCurrentController];
}

- (BOOL)sceneView:(PLVShortVideoFeedView *)sceneView pushController:(UIViewController *)vctrl {
    if (self.navigationController) {
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:vctrl animated:YES];
        return YES;
    } else {
//        PLVBaseNavigationController *nav = [[PLVBaseNavigationController alloc] initWithRootViewController:vctrl];
//        nav.navigationBarHidden = NO;
//        nav.modalPresentationStyle = UIModalPresentationFullScreen;
//        [self presentViewController:nav animated:YES completion:nil];
        return NO;
    }
}

- (void)sceneViewPictureInPictureDidStart:(PLVShortVideoFeedView *)feedView{
    [PLVMediaPlayerPictureInPictureManager sharedInstance].restoreDelegate = [PLVPictureInPictureRestoreManager sharedInstance];
    [PLVPictureInPictureRestoreManager sharedInstance].holdingViewController = self;
    [PLVPictureInPictureRestoreManager sharedInstance].restoreWithPresent = YES;

    // 退出当前界面
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)sceneViewPictureInPictureDidEnd:(PLVShortVideoFeedView *)feedView{
    [[PLVPictureInPictureRestoreManager sharedInstance] cleanRestoreManager];
}

#pragma mark -- 横竖屏处理
- (void)setupModule{
    // 通用的 配置
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interfaceOrientationDidChange:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)interfaceOrientationDidChange:(NSNotification *)notification {
    [self.view layoutIfNeeded];
    
    BOOL fullScreen = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;
    if (fullScreen){
        self.feedView.collectionView.scrollEnabled = NO;
        [self.feedView.collectionView reloadData];
        
        // 横屏、定位到具体cell
        [self.feedView.collectionView setContentOffset:CGPointMake(0, CGRectGetHeight(self.feedView.frame)*_curIndex)];
    }
    else{
        self.feedView.collectionView.scrollEnabled = YES;
        [self.feedView.collectionView reloadData];
        
        // 竖屏、定位到具体cell
        [self.feedView.collectionView setContentOffset:CGPointMake(0, CGRectGetHeight(self.feedView.frame)*_curIndex)];
    }
}

@end
