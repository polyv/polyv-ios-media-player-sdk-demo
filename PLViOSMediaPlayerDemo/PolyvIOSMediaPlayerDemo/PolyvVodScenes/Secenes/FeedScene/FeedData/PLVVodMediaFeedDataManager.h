//
//  PLVVodMediaFeedDataManager.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by Dhan on 2023/9/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodMediaFeedDataManager : NSObject

@property (nonatomic, strong, readonly) NSArray *currentData; // 当前数据的持有属性

/// 更新持有数据
- (void)refreshWithData:(NSArray *)data;

/// 增加更多数据
- (void)appendWithData:(NSArray *)data;

/// 读取一条数据
/// @param index 数据的位置
/// @return 返回读取到的数据，不存在返回nil
- (id)objectAtIndex:(NSInteger)index;

/// 增加一条数据
- (void)addObject:(id)object;

/// 移除所有数据
- (void)removeAll;

@end

NS_ASSUME_NONNULL_END
