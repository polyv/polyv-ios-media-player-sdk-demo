//
//  PLVSlideTabView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/10/12.
//

#import <UIKit/UIKit.h>
#import "PLVSlideTabbarProtocol.h"

@interface PLVTabedbarItem : NSObject
@property (nonatomic, strong) NSString *title;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) UIImage *selectedImage;

+ (PLVTabedbarItem *)itemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage;
@end

@class PLVSlideTabView;

@protocol PLVSlideTabViewDelegate <NSObject>
- (NSInteger)numberOfTabsInPLVSlideTabView:(PLVSlideTabView *)sender;
- (UIViewController *)PLVSlideTabView:(PLVSlideTabView *)sender controllerAt:(NSInteger)index;
@optional
- (void)PLVSlideTabView:(PLVSlideTabView *)sender didSelectedAt:(NSInteger)index;
@end

@interface PLVSlideTabView : UIView<PLVSlideTabbarDelegate>
@property(nonatomic, weak) UIViewController *baseViewController;
@property(nonatomic, assign) NSInteger selectedIndex;

//set tabbar properties.
@property(nonatomic, strong) UIColor *tabItemNormalColor;
@property(nonatomic, strong) UIColor *tabItemSelectedColor;
@property(nonatomic, strong) UIImage *tabbarBackgroundImage;
@property(nonatomic, strong) UIColor *tabbarTrackColor;
@property(nonatomic, strong) NSArray *tabbarItems;
@property(nonatomic, assign) NSInteger tabItemNormalFontSize;
@property(nonatomic, assign) NSInteger tabItemSelectedFontSize;

@property(nonatomic, assign) float tabbarHeight;
@property(nonatomic, assign) float tabbarBottomSpacing;
@property(nonatomic, assign) BOOL canScroll;

// cache properties
@property(nonatomic, assign) NSInteger cacheCount;

- (void)buildTabbar;

@property(nonatomic, weak)IBOutlet id<PLVSlideTabViewDelegate>delegate;

@end
