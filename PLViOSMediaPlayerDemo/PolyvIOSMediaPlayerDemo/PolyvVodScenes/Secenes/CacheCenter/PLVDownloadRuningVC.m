//
//  PLVDownloadRuningVC.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/9/4.
//

#import "PLVDownloadRuningVC.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVDownloadRunningCell.h"
#import "PLVDownloadNoDataTipsView.h"

@interface PLVDownloadRuningVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray<PLVDownloadInfo *> *downloadInfos;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PLVDownloadRunningCell *> *downloadItemCellDic;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PLVDownloadNoDataTipsView *tipsView;

@end

@implementation PLVDownloadRuningVC

- (UITableView *)tableView{
    if (!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[PLVDownloadRunningCell class] forCellReuseIdentifier:[PLVDownloadRunningCell identifier]];
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

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:12/255.0 green:38/255.0 blue:65/255.0 alpha:1.0];

    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor colorWithRed:12/255.0 green:38/255.0 blue:65/255.0 alpha:1.0];

    self.tableView.tableFooterView = [UIView new];
    self.tableView.allowsSelection = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 92;
    
    __weak typeof(self) weakSelf = self;
    PLVDownloadMediaManager *downloadManager = [PLVDownloadMediaManager sharedManager];
    
    [downloadManager getUnfinishedDownloadList:^(NSArray<PLVDownloadInfo *> *downloadInfos) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.downloadInfos = downloadInfos.mutableCopy;
            [weakSelf.tableView reloadData];
        });
    }];
    
    // 所有下载完成回调
    downloadManager.completeBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    };
}

#pragma mark - property

- (void)setDownloadInfos:(NSMutableArray<PLVDownloadInfo *> *)downloadInfos {
    _downloadInfos = downloadInfos;
    
    // 设置单元格字典
    NSMutableDictionary *downloadItemCellDic = [NSMutableDictionary dictionary];
    for (PLVDownloadInfo *info in downloadInfos) {
        PLVDownloadRunningCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[PLVDownloadRunningCell identifier]];
        downloadItemCellDic[info.identifier] = cell;
    }
    self.downloadItemCellDic = downloadItemCellDic;
    
    // 设置回调
    __weak typeof(self) weakSelf = self;
    for (PLVDownloadInfo *info in downloadInfos) {
        // 下载状态改变回调
        info.stateDidChangeBlock = ^(PLVDownloadInfo *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (info.state == PLVVodDownloadStateSuccess){ //下载成功，从列表中删除
                    [weakSelf handleDownloadSuccess:info];
                }
                
                [weakSelf updateCellWithDownloadInfo:info];
            });
        };
        
        // 下载进度回调
        info.progressDidChangeBlock = ^(PLVDownloadInfo *info) {
            NSLog(@"vid: %@, progress: %f speed: %f", info.vid, info.progress, info.bytesPerSeconds);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updateCellWithDownloadInfo:info];
            });
        };
    }
}

- (void)updateCellWithDownloadInfo:(PLVDownloadInfo *)info {
    PLVDownloadRunningCell *cell = self.downloadItemCellDic[info.identifier];
    [cell updateCellWithModel:info];
}

#pragma mark -- handle
- (void)handleDownloadSuccess:(PLVDownloadInfo *)downloadInfo{
    //
    [self.downloadInfos removeObject:downloadInfo];
    [self.downloadItemCellDic removeObjectForKey:downloadInfo.identifier];
    
    [self.tableView reloadData];
}

#pragma mark - action
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
    return [PLVDownloadRunningCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLVDownloadInfo *info = self.downloadInfos[indexPath.row];
    PLVDownloadRunningCell *cell = self.downloadItemCellDic[info.identifier];
    if (!cell) return [UITableViewCell new];
    
    [cell configCellWithModel:info];

    return cell;
}

#pragma mark -- UITableViewDelegate --
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PLVDownloadInfo *info = self.downloadInfos[indexPath.row];
    switch (info.state) {
        case PLVVodDownloadStatePreparing:
        case PLVVodDownloadStatePreparingTask:
        case PLVVodDownloadStateReady:
            // 开始下载
            [self handleStartDownloadVideo:info];
            break;
        case PLVVodDownloadStateStopping:
        case PLVVodDownloadStateStopped:
            // 开始下载
            [self handleStartDownloadVideo:info];
            break;
        case PLVVodDownloadStateRunning:
            // 停止下载
            [self handleStopDownloadVideo:info];
            break;
        case PLVVodDownloadStateSuccess:
            break;
        case PLVVodDownloadStateFailed:
            // 开始下载
            [self handleStartDownloadVideo:info];
            break;
        default:
            break;
    }
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
    PLVDownloadInfo *downloadInfo = self.downloadInfos[indexPath.row];
    
    [downloadManager removeDownloadTask:downloadInfo error:nil];
    
    [self.downloadInfos removeObject:downloadInfo];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    if (self.downloadCountDidChanged){
        self.downloadCountDidChanged();
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

#pragma mark - util

+ (NSString *)formatFilesize:(NSInteger)filesize {
    return [NSByteCountFormatter stringFromByteCount:filesize countStyle:NSByteCountFormatterCountStyleBinary];
}

#pragma mark -- handle
- (void)handleStopDownloadVideo:(PLVDownloadInfo *)info{
    [[PLVDownloadMediaManager sharedManager] stopDownloadTask:info];
}

- (void)handleStartDownloadVideo:(PLVDownloadInfo *)info{
    [[PLVDownloadMediaManager sharedManager] startDownloadTask:info highPriority:NO];
}

@end
