//
//  PLVOrientationUtil.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by lichangjie on 2023/11/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVOrientationUtil : NSObject

+ (Boolean)isLandscape;

+ (void)changeUIOrientation:(UIDeviceOrientation)orientation;

+ (void)setNeedsUpdateOfSupportedInterfaceOrientations;

@end

NS_ASSUME_NONNULL_END
