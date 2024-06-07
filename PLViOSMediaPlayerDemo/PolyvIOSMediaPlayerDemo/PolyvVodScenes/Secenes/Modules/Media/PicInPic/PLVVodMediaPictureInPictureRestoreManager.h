//
//  PLVVodMediaPictureInPictureRestoreManager.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/10/5.
//

#import <Foundation/Foundation.h>
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodMediaPictureInPictureRestoreManager : NSObject<PLVMediaPlayerPictureInPictureRestoreDelegate>

#pragma mark - [ 属性 ]

/// 用于开启画中画后离开页面时，持有原来的页面
@property (nonatomic, strong, nullable) UIViewController *holdingViewController;

/// 当使用model方式展示直播间的时候，点击小窗恢复按钮，是present还是dismiss来恢复原直播间
@property (nonatomic, assign) BOOL restoreWithPresent;

#pragma mark - [ 方法 ]

/// 单例方法
+ (instancetype)sharedInstance;

/// 清空恢复管理器的内部属性，在画中画关闭的时候调用，防止内存泄漏
- (void)cleanRestoreManager;

@end

NS_ASSUME_NONNULL_END
