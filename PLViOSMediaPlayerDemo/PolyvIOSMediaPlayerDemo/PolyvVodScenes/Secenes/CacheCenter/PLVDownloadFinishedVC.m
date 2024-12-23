//
//  PLVDownloadFinishedVC.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/9/4.
//

#import "PLVDownloadFinishedVC.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVDownloadFinishedCell.h"
#import "PLVDemoVodMediaViewController.h"
#import "PLVDownloadNoDataTipsView.h"

@interface PLVDownloadFinishedVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<PLVDownloadInfo *> *downloadInfos;
@property (nonatomic, strong) PLVDownloadNoDataTipsView *tipsView; //  无数据提示视图

@end

@implementation PLVDownloadFinishedVC

- (instancetype)init{
    if (self = [super init]){
        // 初始化view 否则删除cell 崩溃
        [self view];
        
        // 单个视频下载完成回调
        __weak typeof(self) weakSelf = self;
        [PLVDownloadMediaManager sharedManager].downloadCompleteBlock = ^(PLVDownloadInfo *info) {
            // 刷新列表
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.downloadInfos addObject:info];
                if (weakSelf.tableView.superview){
                    [weakSelf.tableView reloadData];
                }
                
                // 更新tab 数据
                if (weakSelf.downloadCountDidChanged){
                    weakSelf.downloadCountDidChanged();
                }
            });
        };
        
        [self initVideoList];
    }
    return self;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:12/255.0 green:38/255.0 blue:65/255.0 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:12/255.0 green:38/255.0 blue:65/255.0 alpha:1.0];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)initVideoList{
    // 从数据库中读取已缓存视频详细信息
    NSArray<PLVDownloadInfo *> *dbInfos = [[PLVDownloadMediaManager sharedManager] getFinishedDownloadList];
    [self.downloadInfos addObjectsFromArray:dbInfos];
}

- (NSMutableArray<PLVDownloadInfo *> *)downloadInfos{
    if (!_downloadInfos){
        _downloadInfos = [NSMutableArray arrayWithCapacity:0];
    }
    
    return _downloadInfos;
}

- (UITableView *)tableView{
    if (!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[PLVDownloadFinishedCell class] forCellReuseIdentifier:[PLVDownloadFinishedCell identifier]];
    }
    
    return _tableView;
}

-(PLVDownloadNoDataTipsView *)tipsView{
    if (!_tipsView){
        _tipsView = [[PLVDownloadNoDataTipsView alloc] init];
        _tipsView.backgroundColor = [UIColor colorWithRed:12/255.0 green:38/255.0 blue:65/255.0 alpha:1.0];
    }
    
    return _tipsView;
}

#pragma mark - property

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = self.downloadInfos.count;
    self.tableView.backgroundView = number ? nil : self.tipsView;
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [PLVDownloadFinishedCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLVDownloadFinishedCell *cell = [tableView dequeueReusableCellWithIdentifier:[PLVDownloadFinishedCell identifier]];
    PLVDownloadInfo *info = [self.downloadInfos objectAtIndex:indexPath.row];
    [cell configCellWithModel:info];
  
    return cell;
}

#pragma mark -- UITableViewDelegate --
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 播放本地缓存视频
    PLVDownloadInfo *info = self.downloadInfos[indexPath.row];
    
    //普通视频播放页面入口 离线播放
    PLVDemoVodMediaViewController *demoVC = [[PLVDemoVodMediaViewController alloc] init];
    demoVC.vid = info.vid;
    demoVC.isOffPlayModel = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:demoVC animated:YES];
    });
}

/// 删除
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PLVDownloadMediaManager *downloadManager = [PLVDownloadMediaManager sharedManager];
    PLVDownloadInfo *localModel = self.downloadInfos[indexPath.row];
    [downloadManager removeDownloadTask:localModel error:nil];
    [self.downloadInfos removeObject:localModel];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    if (self.downloadCountDidChanged){
        self.downloadCountDidChanged();
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

@end
