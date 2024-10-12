//
//  PLVSlideTabbarProtocol.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PLVSlideTabbarDelegate <NSObject>
- (void)PLVSlideTabbar:(id)sender selectAt:(NSInteger)index;
@end

@protocol PLVSlideTabbarProtocol <NSObject>
@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, readonly) NSInteger tabbarCount;
@property(nonatomic, weak) id<PLVSlideTabbarDelegate> delegate;

- (void)switchingFrom:(NSInteger)fromIndex to:(NSInteger)toIndex percent:(float)percent;
@end

NS_ASSUME_NONNULL_END
