//
//  PLVShortVideoFeedView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/4.
//

#import <UIKit/UIKit.h>
#import "PLVFeedViewDefine.h"
#import "PLVFeedData.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVShortVideoFeedViewDelegate;

@interface PLVShortVideoFeedView : UIView<
PLVFeedItemCustomViewDelegate // 遵循该协议才能嵌套Feed组件
>

@property (nonatomic, weak) id<PLVShortVideoFeedViewDelegate> delegate;
@property (nonatomic, strong, readonly) PLVFeedData *feedData;

- (instancetype)initWithWatchData:(PLVFeedData *)feedData;

// 页面容器类在同名方法执行时调用
- (void)viewWillAppear;

// 页面容器类在同名方法执行时调用
- (void)viewWillDisappear;

@end

// 用于向上通知页面容器类的协议
@protocol PLVShortVideoFeedViewDelegate <NSObject>

// 协议PLVFeedItemCustomViewDelegate的setActive方法参数为YES时触发
- (void)sceneViewDidBecomeActive:(PLVShortVideoFeedView *)feedView;

// 协议PLVFeedItemCustomViewDelegate的setActive方法参数为NO时触发
- (void)sceneViewDidEndActive:(PLVShortVideoFeedView *)feedView;

// 需要退出当前页面时触发，由页面容器类退出
- (void)sceneViewWillExitController:(PLVShortVideoFeedView *)feedView;

// 需要push/present新页面时触发，由页面容器类push/present新页面
- (BOOL)sceneView:(PLVShortVideoFeedView *)feedView pushController:(UIViewController *)vctrl;

// 画中画状态回调
- (void)sceneViewPictureInPictureDidStart:(PLVShortVideoFeedView *)feedView;
- (void)sceneViewPictureInPictureDidEnd:(PLVShortVideoFeedView *)feedView;

@end

NS_ASSUME_NONNULL_END
