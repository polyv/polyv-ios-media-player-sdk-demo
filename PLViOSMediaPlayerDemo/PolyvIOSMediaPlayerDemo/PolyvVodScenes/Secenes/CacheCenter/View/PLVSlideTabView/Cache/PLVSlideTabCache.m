//
//  PLVSlideTabCache.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/10/12.
//

#import "PLVSlideTabCache.h"

@implementation PLVSlideTabCache
{
    NSMutableDictionary *dic_;
    NSMutableArray *lruKeyList_;
    NSInteger capacity_;
}

- (id)initWithCount:(NSInteger)count{
    if (self = [super init]) {
        capacity_ = count;
        dic_ = [NSMutableDictionary dictionaryWithCapacity:capacity_];
        lruKeyList_ = [NSMutableArray arrayWithCapacity:capacity_];
    }

    return self;
}

- (void)setObject:(id)object forKey:(NSString *)key{
    if ([lruKeyList_ containsObject:key]) {
        
        [dic_ setValue:object forKey:key];
        [lruKeyList_ removeObject:key];
        [lruKeyList_ addObject:key];
        
    } else {
        if (lruKeyList_.count < capacity_) {
            [dic_ setValue:object forKey:key];
            [lruKeyList_ addObject:key];
        }
        else{
            NSString *longTimeUnusedKey = [lruKeyList_ firstObject];
            [dic_ setValue:nil forKey:longTimeUnusedKey];
            [lruKeyList_ removeObjectAtIndex:0];
            
            [dic_ setValue:object forKey:key];
            [lruKeyList_ addObject:key];
        }
    }
}

- (id)objectForKey:(NSString *)key{
    if ([lruKeyList_ containsObject:key]) {
        [lruKeyList_ removeObject:key];
        [lruKeyList_ addObject:key];
        
        return [dic_ objectForKey:key];
    }
    else{
        return nil;
    }
}
@end
