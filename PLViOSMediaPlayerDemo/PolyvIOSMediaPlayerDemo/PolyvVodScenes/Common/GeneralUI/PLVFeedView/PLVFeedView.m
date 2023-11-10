//
//  PLVFeedView.m
//  PolyvLiveScenesDemo
//
//  Created by MissYasiky on 2023/6/21.
//  Copyright © 2023 PLV. All rights reserved.
//

#import "PLVFeedView.h"
#import "PLVFeedItemView.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import <MJRefresh/MJRefresh.h>

static NSString *kPLVFeedViewCellIdentifier = @"kPLVFeedViewCellIdentifier";

@interface PLVFeedView ()<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout
>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;
@property (nonatomic, strong) UIView <PLVFeedItemCustomViewDelegate> *activeFeedItemView;
@property (nonatomic, strong) NSMutableDictionary <NSString *, UIView <PLVFeedItemCustomViewDelegate> *> *feedItemCustomViewDict;
@property (nonatomic, strong) NSMutableArray <UIView <PLVFeedItemCustomViewDelegate> *> *feedItemCustomViewArray;
@property (nonatomic, assign) NSInteger maxReuseCustomViewCount;
@property (nonatomic, strong) dispatch_semaphore_t feedItemCustomViewOperationLock;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) BOOL noMoreData;

@end

@implementation PLVFeedView

#pragma mark - [ Life Cycle ]

- (void)dealloc {
    [self clear];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxReuseCustomViewCount = 3;
        _feedItemCustomViewOperationLock = dispatch_semaphore_create(1);
        _feedItemCustomViewDict = [[NSMutableDictionary alloc] initWithCapacity:_maxReuseCustomViewCount];
        _feedItemCustomViewArray = [[NSMutableArray alloc] initWithCapacity:_maxReuseCustomViewCount];
        
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionViewLayout.minimumLineSpacing = 0;
        _collectionViewLayout.minimumInteritemSpacing = 0;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_collectionViewLayout];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor colorWithRed:32/255.0 green:38/255.0 blue:57.0/255.0 alpha:1.0];
        _collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        _collectionView.contentInset = UIEdgeInsetsZero;
        _collectionView.pagingEnabled = YES;
        _collectionView.delegate = self;
        
        __weak typeof(self) weakSelf = self;
        MJRefreshNormalHeader *mjHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            if (weakSelf.dataSource && [weakSelf.dataSource respondsToSelector:@selector(feedViewNeedsRefresh:completion:)]) {
                weakSelf.isRefreshing = YES;
                [weakSelf.dataSource feedViewNeedsRefresh:weakSelf completion:^(BOOL refresh) {
                    weakSelf.isRefreshing = NO;
                    [weakSelf.collectionView.mj_header endRefreshing];
                    if (refresh) {
                        weakSelf.noMoreData = NO;
                        [weakSelf.collectionView.mj_footer resetNoMoreData];
                    }
                }];
            }
        }];
        mjHeader.lastUpdatedTimeLabel.hidden = YES;
        [mjHeader.loadingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        
        _collectionView.mj_header = mjHeader;
        
        MJRefreshAutoNormalFooter *mjFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            if (weakSelf.noMoreData) {
                [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                return;
            }
            if (weakSelf.dataSource && [weakSelf.dataSource respondsToSelector:@selector(feedViewNeedsLoadMore:completion:)]) {
                weakSelf.isLoadingMore = YES;
                [weakSelf.dataSource feedViewNeedsLoadMore:weakSelf completion:^(BOOL lastPage) {
                    weakSelf.isLoadingMore = NO;
                    weakSelf.noMoreData = lastPage;
                    [weakSelf.collectionView.mj_footer endRefreshing];
                }];
            }
        }];

        mjFooter.refreshingTitleHidden = YES;
        [mjFooter setTitle:@"暂时没有更多了" forState:MJRefreshStateNoMoreData];
        [mjFooter.loadingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        _collectionView.mj_footer = mjFooter;
        
        [_collectionView registerClass:[PLVFeedItemView class] forCellWithReuseIdentifier:kPLVFeedViewCellIdentifier];
        [self addSubview:_collectionView];
        
        _isRefreshing = NO;
        _isLoadingMore = NO;
    }
    return self;
}

- (void)layoutSubviews {
    self.collectionView.frame = self.bounds;
}

#pragma mark - [ Public Method ]
- (UIView <PLVFeedItemCustomViewDelegate>*)dequeueReusableFeedItemCustomViewWithIdentifier:(NSString *)identifier {
    if (identifier && [identifier isKindOfClass:[NSString class]] && identifier.length > 0) {
        UIView <PLVFeedItemCustomViewDelegate> *customView = self.feedItemCustomViewDict[identifier];
        return customView;
    }
    return nil;
}

- (void)clear {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didStopScroll) object:nil];
    
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
    _activeFeedItemView = nil;
    
    [_feedItemCustomViewDict removeAllObjects];
    _feedItemCustomViewDict = nil;
}

#pragma mark Getter & Setter

- (void)setDataSource:(id<PLVFeedViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    if (dataSource) {
        self.collectionView.dataSource = self;
    } else {
        self.collectionView.dataSource = nil;
    }
    
    [self.collectionView reloadData];
}

#pragma mark - [ Private Method ]

- (void)appendCustomView:(UIView <PLVFeedItemCustomViewDelegate> *)customView {
    if (!customView.reuseIdentifier ||
        customView.reuseIdentifier.length == 0 ||
        self.feedItemCustomViewDict[customView.reuseIdentifier]) {
        return;
    }
    
    LOCK(self.feedItemCustomViewOperationLock);
    
    if ([self.feedItemCustomViewArray count] >= self.maxReuseCustomViewCount) {
        UIView <PLVFeedItemCustomViewDelegate> *removeView = self.feedItemCustomViewArray[0];
        if (removeView && [removeView respondsToSelector:@selector(setActive:)]){
            [removeView setActive:NO];
            // 快速滑动，当前不需要选中项
            if(self.activeFeedItemView == removeView){
                self.activeFeedItemView = nil;
            }
        }
        [self.feedItemCustomViewDict removeObjectForKey:removeView.reuseIdentifier];
        [self.feedItemCustomViewArray removeObject:removeView];
    }
    
    self.feedItemCustomViewDict[customView.reuseIdentifier] = customView;
    [self.feedItemCustomViewArray addObject:customView];

    /*
    NSLog(@"xyj debug - %@", self.feedItemCustomViewArray);
    for (UIView <PLVFeedItemCustomViewDelegate> *view in self.feedItemCustomViewArray) {
        NSLog(@"%@", view.reuseIdentifier);
    }
    */
    
    UNLOCK(self.feedItemCustomViewOperationLock);
}

#pragma mark - [ Delegate ]

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.dataSource &&
        [self.dataSource respondsToSelector:@selector(numberOfSectionsInFeedView:)]) {
        return [self.dataSource numberOfSectionsInFeedView:self];
    } else {
        return 0;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataSource &&
        [self.dataSource respondsToSelector:@selector(numberOfSectionsInFeedView:)]) {
        return [self.dataSource feedView:self numberOfItemsInSection:section];
    } else {
        return 0;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PLVFeedItemView *cell = (PLVFeedItemView *)[collectionView dequeueReusableCellWithReuseIdentifier:kPLVFeedViewCellIdentifier forIndexPath:indexPath];
    
    // 获取内容视图，内容视图必须遵循协议PLVFeedItemCustomViewDelegate
    UIView <PLVFeedItemCustomViewDelegate> *contentView = nil;
    if (self.dataSource &&
        [self.dataSource respondsToSelector:@selector(feedView:contentViewForItemAtIndexPath:)]) {
        UIView <PLVFeedItemCustomViewDelegate>*returnView = (UIView <PLVFeedItemCustomViewDelegate>*)[self.dataSource feedView:self contentViewForItemAtIndexPath:indexPath];
        if ([returnView conformsToProtocol:@protocol(PLVFeedItemCustomViewDelegate)]) {
            contentView = returnView;
            [self appendCustomView:contentView];
        }
        // 预加载下一条内容数据
//        if (indexPath.row + 1 < indexPath.length) {
//            NSIndexPath *proIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
//            UIView <PLVFeedItemCustomViewDelegate>*proloadView = (UIView <PLVFeedItemCustomViewDelegate>*)[self.dataSource feedView:self contentViewForItemAtIndexPath:proIndexPath];
//            if (proloadView && [proloadView conformsToProtocol:@protocol(PLVFeedItemCustomViewDelegate)]) {
//                [self appendCustomView:proloadView];
//            }
//        }
    }
    
    if (indexPath.row == 0 && !self.activeFeedItemView){
        // 设置默认激活视图（当前正显示），部分场景下scrollviewdidscroll 不会回调
        self.activeFeedItemView = contentView;
        [self.activeFeedItemView setActive:YES];
    }
    
    [cell setCustomContentView:contentView];
    return cell;
}

#pragma mark UICollectionViewLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.bounds.size;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didStopScroll) object:nil];
    [self performSelector:@selector(didStopScroll) withObject:nil afterDelay:0.3];
}

// called on start of dragging (may require some time and or distance to move)
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    NSLog(@"xyj debug - WillBeginDragging: visibleCell %@", self.collectionView.visibleCells);
//}

/*
// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"xyj debug - WillEndDragging: velocity (%f, %f)", velocity.x, velocity.y);
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"xyj debug - DidEndDragging: decelerate %@", decelerate ? @"YES" : @"NO");
}
*/
#pragma mark - [ Event ]

- (void)didStopScroll {
    NSLog(@"xyj debug - didStopScroll: visibleCell %@", self.collectionView.visibleCells);
    if(self.collectionView.visibleCells.count >= 2 || self.noMoreData){
        // 调整ContentOffset
        float diff = (int)self.collectionView.contentOffset.y % (int)self.collectionView.frame.size.height;
        if (diff > 44){
            CGPoint point = CGPointMake(0, self.collectionView.contentOffset.y + (self.collectionView.frame.size.height - diff));
            [UIView animateWithDuration:0.3 animations:^{
                [self.collectionView setContentOffset:point];
            }];
        }
        else if (diff == 44){
            CGPoint point = CGPointMake(0, self.collectionView.contentOffset.y - diff);
            [UIView animateWithDuration:0.3 animations:^{
                [self.collectionView setContentOffset:point];
            }];
        }
    }
    if ([self.collectionView.visibleCells count] == 0) {
        return;
    }
    
    PLVFeedItemView *cell = (PLVFeedItemView *)self.collectionView.visibleCells.firstObject;
    if (self.activeFeedItemView &&
        ((cell.customContentView && self.activeFeedItemView != cell.customContentView) || !cell.customContentView)) {
        [self.activeFeedItemView setActive:NO];
    }

    if (cell.customContentView &&
        [cell.customContentView conformsToProtocol:@protocol(PLVFeedItemCustomViewDelegate)]) {
        if (self.activeFeedItemView != cell.customContentView){
            [cell.customContentView setActive:YES];
            self.activeFeedItemView = cell.customContentView;
        }
    }
}

- (void)initActiveFeedItemView{
    if ([self.collectionView.visibleCells count] == 0) {
        return;
    }
    
    PLVFeedItemView *cell = (PLVFeedItemView *)self.collectionView.visibleCells[0];
    if (cell.customContentView && !self.activeFeedItemView) {
        self.activeFeedItemView = cell.customContentView;
    }
}

@end
