//
//  PLVDemoVodViewController.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 长视频播放 演示页面
@interface PLVDemoVodMediaViewController : UIViewController

@property (nonatomic, copy) NSString *vid;

@property (nonatomic, assign) NSInteger actionAfterPlayFinish; // 视频播放完毕后的处理方式  0：显示播放结束UI（缺省）  1：重新播放  2：播放下一个

@end

NS_ASSUME_NONNULL_END
