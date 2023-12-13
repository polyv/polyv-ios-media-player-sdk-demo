//
//  PLVShortVideoFeedDataManager.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by Dhan on 2023/9/7.
//

#import "PLVFeedDataManager.h"
#import "PLVFeedData.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVShortVideoFeedDataManager : PLVFeedDataManager

// 数据持有
@property (nonatomic, strong, readonly) NSArray <PLVFeedData *> *feedDataArray;

- (void)refreshDataWithCompletion:(void (^)(void))completion failure:(void (^)(NSError *))failure;

- (void)loadMoreDataWithCompletion:(void (^)(BOOL lastPage))completion failure:(void (^)(NSError *))failure;

- (PLVFeedData *)feedDataInFeedDataArrayAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
