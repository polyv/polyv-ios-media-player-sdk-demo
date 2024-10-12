//
//  PLVSlideView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/10/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVSlideView;

@protocol PLVSlideViewDataSource <NSObject>
- (NSInteger)numberOfControllersInDLSlideView:(PLVSlideView *)sender;
- (UIViewController *)PLVSlideView:(PLVSlideView *)sender controllerAt:(NSInteger)index;
@end

@protocol PLVSlideViewDelegate <NSObject>
@optional
- (void)PLVSlideView:(PLVSlideView *)slide switchingFrom:(NSInteger)oldIndex to:(NSInteger)toIndex percent:(float)percent;
- (void)PLVSlideView:(PLVSlideView *)slide didSwitchTo:(NSInteger)index;
- (void)PLVSlideView:(PLVSlideView *)slide switchCanceled:(NSInteger)oldIndex;
@end

@interface PLVSlideView : UIView
@property(nonatomic, assign) NSInteger selectedIndex;
@property(nonatomic, assign) BOOL canScroll;
@property(nonatomic, weak) UIViewController *baseViewController;
@property(nonatomic, weak) id<PLVSlideViewDelegate>delegate;
@property(nonatomic, weak) id<PLVSlideViewDataSource>dataSource;

- (void)switchTo:(NSInteger)index;


@end

NS_ASSUME_NONNULL_END
