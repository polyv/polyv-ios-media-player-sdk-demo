//
//  PLVMediaPlayerDanmuModule.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2026/1/7.
//

#import <Foundation/Foundation.h>
#if __has_include(<PLVVodDanmu/PLVVodDanmu.h>)
#import <PLVVodDanmu/PLVVodDanmu.h>
#else
#import "PLVVodDanmu.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PLVMediaPlayerDanmuModule : NSObject

/// 发送弹幕
+ (void)sendDammuWithContent:(NSString *)content vid:(NSString *)vid time:(NSTimeInterval)time fontSize:(int)fontSize colorHex:(NSUInteger)colorHex mode:(NSInteger)mode completion:(void (^)(NSError *error, NSString * danmuId))completion;

/// 加载弹幕
+ (void)requestDanmusWithVid:(NSString *)vid completion:(void (^)(NSArray<PLVVodDanmu *> *danmus, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
