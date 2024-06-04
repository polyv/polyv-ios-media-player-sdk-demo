//
//  UIImage+PLVVodMediaTint.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (PLVVodMediaTint)

- (UIImage *)imageWithCustomTintColor:(UIColor *)tintColor;

+ (UIImage *)boxblurImageWithBlur:(CGFloat)blur image:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
