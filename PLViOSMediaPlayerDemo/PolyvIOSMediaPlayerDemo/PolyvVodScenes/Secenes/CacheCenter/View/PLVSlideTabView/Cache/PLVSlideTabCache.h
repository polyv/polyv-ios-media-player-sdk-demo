//
//  PLVSlideTabCache.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/10/12.
//

#import <UIKit/UIKit.h>
#import "PLVSlideTabCacheProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface PLVSlideTabCache: NSObject<PLVSlideTabCacheProtocol>

- (id)initWithCount:(NSInteger)count;

- (void)setObject:(id)object forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
