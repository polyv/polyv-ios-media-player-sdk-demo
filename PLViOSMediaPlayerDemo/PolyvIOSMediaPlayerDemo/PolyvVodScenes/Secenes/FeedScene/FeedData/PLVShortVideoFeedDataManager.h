//
//  PLVShortVideoFeedDataManager.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by Dhan on 2023/9/7.
//

#import "PLVVodMediaFeedDataManager.h"
#import "PLVVodMediaFeedData.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVShortVideoFeedDataManager : PLVVodMediaFeedDataManager

// 数据持有
@property (nonatomic, strong, readonly) NSArray <PLVVodMediaFeedData *> *feedDataArray;

- (void)refreshDataWithCompletion:(void (^)(void))completion failure:(void (^)(NSError *))failure;

- (void)loadMoreDataWithCompletion:(void (^)(BOOL lastPage))completion failure:(void (^)(NSError *))failure;

- (PLVVodMediaFeedData *)feedDataInFeedDataArrayAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
