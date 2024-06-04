//
//  PLVVodMediaFeedView.h
//  PolyvLiveScenesDemo
//
//  Created by MissYasiky on 2023/6/21.
//  Copyright © 2023 PLV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVVodMediaFeedViewDefine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVVodMediaFeedViewDataSource;

@interface PLVVodMediaFeedView : UIView

@property (nonatomic, weak) id<PLVVodMediaFeedViewDataSource> dataSource;

@property (nonatomic, strong, readonly) UICollectionView *collectionView;

// 上拉加载的偏移量，默认为50
@property (nonatomic, assign) CGFloat loadMoreOffset;

// 下拉刷新的偏移量，默认为-50
@property (nonatomic, assign) CGFloat refreshOffset;

// 获取复用视图
- (UIView <PLVVodMediaFeedItemCustomViewDelegate>*)dequeueReusableFeedItemCustomViewWithIdentifier:(NSString *)identifier;

// 初始化默认激活的视图
- (void)initActiveFeedItemView;

// 视图销毁前应及时调用clear方法，防止触发数据自动加载机制
- (void)clear;

@end

@protocol PLVVodMediaFeedViewDataSource <NSObject>

@required

- (NSInteger)numberOfSectionsInFeedView:(PLVVodMediaFeedView *)feedView;

- (NSInteger)feedView:(PLVVodMediaFeedView *)feedView numberOfItemsInSection:(NSInteger)section;

- (UIView <PLVVodMediaFeedItemCustomViewDelegate>*)feedView:(PLVVodMediaFeedView *)feedView contentViewForItemAtIndexPath:(NSIndexPath *)indexPath;

/// 上拉刷新回调
///
/// @param feedView feed流组件
/// @param completion 完成回调，不执行触发completion不会进行下次回调
- (void)feedViewNeedsRefresh:(PLVVodMediaFeedView *)feedView completion:(void (^)(BOOL refresh))completion;

/// 下拉加载回调
///
/// @param feedView feed流组件
/// @param completion 完成回调，不执行触发completion不会进行下次回调
- (void)feedViewNeedsLoadMore:(PLVVodMediaFeedView *)feedView completion:(void (^)(BOOL lastPage))completion;

@end

NS_ASSUME_NONNULL_END
