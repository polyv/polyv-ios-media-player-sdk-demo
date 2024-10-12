//
//  PLVSlideTabUtil.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/10/12.
//

#import "PLVSlideTabUtil.h"

@implementation PLVSlideTabUtil

+ (UIColor *)getColorOfPercent:(CGFloat)percent between:(UIColor *)color1 and:(UIColor *)color2{
    CGFloat red1, green1, blue1, alpha1;
    [color1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    
    CGFloat red2, green2, blue2, alpha2;
    [color2 getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
    
    CGFloat p1 = percent;
    CGFloat p2 = 1.0 - percent;
    UIColor *mid = [UIColor colorWithRed:red1*p1+red2*p2 green:green1*p1+green2*p2 blue:blue1*p1+blue2*p2 alpha:1.0f];
    return mid;
}

@end
