//
//  PLVVodMediaFeedData.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodMediaFeedData : NSObject

@property (nonatomic, strong) NSString *hashKey;
@property (nonatomic, strong) NSString *vid;
@property (nonatomic, assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
