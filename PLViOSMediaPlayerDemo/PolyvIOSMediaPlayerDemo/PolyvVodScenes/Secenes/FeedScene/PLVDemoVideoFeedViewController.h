//
//  PLVDemoVideoFeedViewController.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 短视频播放 演示页面
 * 短视频数据默认是获取 账号 对应的点播列表数据；如果需要自行定制，请修改 PLVVideoNetwork 类中的 requestAccountVideoWithPageCount 方法的实现
 */
@interface PLVDemoVideoFeedViewController : UIViewController

@property (nonatomic, assign) BOOL isHideProtraitBackButton; // 是否显示返回按钮（如果是APP的首页，可以不显示）

@end

NS_ASSUME_NONNULL_END
