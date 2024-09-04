//
//  PLVVodMediaCommonUtil.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/8/27.
//

#import "PLVVodMediaCommonUtil.h"

@implementation PLVVodMediaCommonUtil

/// 判断是否为空字符串
+ (BOOL)isNilString:(NSString *)origStr{
    if (!origStr || [origStr isKindOfClass:[NSNull class]] || !origStr.length){
        return YES;
    }
    
    return NO;
}

@end
