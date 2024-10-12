//
//  PLVSlideTabCacheProtocol.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PLVSlideTabCacheProtocol <NSObject>
- (void)setObject:(id)object forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
