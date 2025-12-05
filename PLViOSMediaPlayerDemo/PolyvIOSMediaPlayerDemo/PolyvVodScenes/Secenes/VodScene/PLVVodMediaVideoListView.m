
//
//  PLVVodMediaVideoListView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by POLYV on 2025/7/1.
//

#import "PLVVodMediaVideoListView.h"
#import "PLVVodMediaVideoListCell.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

@interface PLVVodMediaVideoListView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <PLVVodMediaVideo *>*videoList;
@property (nonatomic, assign) BOOL isSwitchingVideo; // 标记是否正在切换视频

@end

@implementation PLVVodMediaVideoListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 120;
    [self.tableView registerClass:[PLVVodMediaVideoListCell class] forCellReuseIdentifier:@"PLVVodMediaVideoListCell"];
    [self addSubview:self.tableView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

- (void)updateWithVideoList:(NSArray<PLVVodMediaVideo *> *)videoList {
    self.videoList = videoList;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PLVVodMediaVideoListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PLVVodMediaVideoListCell" forIndexPath:indexPath];
    PLVVodMediaVideo *video = self.videoList[indexPath.row];
    [cell updateWithModel:video];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 防抖：如果正在切换视频，忽略新的点击
    if (self.isSwitchingVideo) {
        NSLog(@"[PLVVodMediaVideoListView] 视频正在切换中，忽略本次点击");
        return;
    }
    
    self.isSwitchingVideo = YES;
    PLVVodMediaVideo *video = self.videoList[indexPath.row];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(vodMediaVideoListView_didSelectVideo:)]) {
        [self.delegate vodMediaVideoListView_didSelectVideo:video];
    }
    
    // 1秒后重置防抖标记
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.isSwitchingVideo = NO;
    });
}

@end
