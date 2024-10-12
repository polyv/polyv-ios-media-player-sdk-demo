//
//  PLVFixedTabbarView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/10/12.
//

#import <UIKit/UIKit.h>
#import "PLVSlideTabbarProtocol.h"

#define kDefaultFixedTabbarItemWidth 110

NS_ASSUME_NONNULL_BEGIN

@interface PLVFixedTabbarViewTabItem : NSObject

@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) UIImage *selectedImage;
@property(nonatomic, strong) UIColor *titleColor;
@property(nonatomic, strong) UIColor *selectedTitleColor;
@property(nonatomic, assign) NSInteger tabItemNormalFontSize;
@property(nonatomic, assign) NSInteger tabItemSelectedFontSize;

@end

@interface PLVFixedTabbarView : UIView<PLVSlideTabbarProtocol>
@property(nonatomic, strong) UIImage *backgroundImage;
@property(nonatomic, strong) UIColor *trackColor;
@property(nonatomic, strong) NSArray *tabbarItems;
@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, readonly) NSInteger tabbarCount;
@property(nonatomic, weak) id<PLVSlideTabbarDelegate> delegate;

- (void)switchingFrom:(NSInteger)fromIndex to:(NSInteger)toIndex percent:(float)percent;

@end

NS_ASSUME_NONNULL_END
