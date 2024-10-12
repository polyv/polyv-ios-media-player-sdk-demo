//
//  PLVDownloadCenterViewController.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/9/4.
//

#import "PLVDownloadCenterViewController.h"
#import "PLVDownloadFinishedVC.h"
#import "PLVDownloadRuningVC.h"
#import "PLVSlideTabView.h"
#import "PLVVodMediaCommonUtil.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

@interface PLVDownloadCenterViewController ()<PLVSlideTabViewDelegate>

@property (nonatomic, strong) PLVSlideTabView *tabedSlideView;
@property (nonatomic, strong) NSArray<UIViewController *> *subViewControllers;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation PLVDownloadCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma init --
- (void)initUI{
    self.view.backgroundColor = [UIColor colorWithRed:12/255.0 green:38/255.0 blue:65/255.0 alpha:1.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    
    [self.view addSubview:self.tabedSlideView];
    self.tabedSlideView.frame = CGRectMake(0, PLV_StatusAndNaviBarHeight, PLV_ScreenWidth, PLV_ScreenHeight - PLV_StatusAndNaviBarHeight);
    
    [self setupTabedSlideView];
}

- (UIButton *)backButton{
    if (!_backButton){
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        [_backButton setTitle:@"下载中心" forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _backButton;
}

- (void)backButtonClick:(UIButton *)item{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupTabedSlideView{
    // setup slide view
    self.tabedSlideView.delegate = self;
    self.tabedSlideView.baseViewController = self;
    self.tabedSlideView.backgroundColor = [UIColor colorWithRed:12/255.0 green:38/255.0 blue:65/255.0 alpha:1.0];
    self.tabedSlideView.tabbarHeight = 52;
    self.tabedSlideView.tabItemSelectedColor = [UIColor whiteColor];
    self.tabedSlideView.tabItemNormalColor = [PLVVodMediaCommonUtil colorFromHexString:@"#FFFFFF" alpha:0.6];
    self.tabedSlideView.tabItemNormalFontSize = 14;
    self.tabedSlideView.tabItemSelectedFontSize = 16;
    self.tabedSlideView.tabbarTrackColor = [PLVVodMediaCommonUtil colorFromHexString:@"#3F76FC"];
    self.tabedSlideView.canScroll = NO;
    
    NSString *finishString = [NSString stringWithFormat:@"已下载(%ld)",[[PLVDownloadManager sharedManager] getFinishedDownloadList].count];
    NSString *runningStr = [NSString stringWithFormat:@"下载中(%ld)",[[PLVDownloadManager sharedManager] getUnfinishedDownloadList].count] ;
    PLVTabedbarItem *item0 = [PLVTabedbarItem itemWithTitle:finishString image:nil selectedImage:nil];
    PLVTabedbarItem *item1 = [PLVTabedbarItem itemWithTitle:runningStr image:nil selectedImage:nil];
    
    self.tabedSlideView.tabbarItems = @[item0, item1];
    [self.tabedSlideView buildTabbar];
    self.tabedSlideView.selectedIndex = self.selectedIndex;
}

#pragma getter --
- (PLVSlideTabView *)tabedSlideView{
    if (!_tabedSlideView){
        _tabedSlideView = [[PLVSlideTabView alloc] init];
    }
    
    return _tabedSlideView;
}

- (NSArray<UIViewController *> *)subViewControllers{
    if (!_subViewControllers){
        __weak typeof(self) weakSelf = self;
        PLVDownloadFinishedVC *finishedVC = [[PLVDownloadFinishedVC alloc] init];
        finishedVC.downloadCountDidChanged = ^{
            [weakSelf updateTabNumbers:0];
        };
        PLVDownloadRuningVC *runningVC = [[PLVDownloadRuningVC alloc] init];
        runningVC.downloadCountDidChanged = ^{
            [weakSelf updateTabNumbers:1];
        };
        _subViewControllers = @[finishedVC, runningVC];
    }
    
    return _subViewControllers;
}

- (void)updateTabNumbers:(NSInteger)index{
    
    NSString *finishString = [NSString stringWithFormat:@"已下载(%ld)",[[PLVDownloadManager sharedManager] getFinishedDownloadList].count];
    NSString *runningStr = [NSString stringWithFormat:@"下载中(%ld)",[[PLVDownloadManager sharedManager] getUnfinishedDownloadList].count] ;
    PLVTabedbarItem *item0 = [PLVTabedbarItem itemWithTitle:finishString image:nil selectedImage:nil];
    PLVTabedbarItem *item1 = [PLVTabedbarItem itemWithTitle:runningStr image:nil selectedImage:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tabedSlideView.tabbarItems = @[item0, item1];
        [self.tabedSlideView buildTabbar];
    });
}

#pragma mark -- PLVSlideTabViewDelegate

- (NSInteger)numberOfTabsInPLVSlideTabView:(PLVSlideTabView *)sender{
    return self.subViewControllers.count;
}

- (UIViewController *)PLVSlideTabView:(PLVSlideTabView *)sender controllerAt:(NSInteger)index{
    return self.subViewControllers[index];
}

@end
