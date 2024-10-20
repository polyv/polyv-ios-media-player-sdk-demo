//
//  PLVDemoVodViewController.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/9.
//

#import <UIKit/UIKit.h>
#import "PLVBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// 长视频播放 演示页面
@interface PLVDemoVodMediaViewController : PLVBaseViewController

@property (nonatomic, copy) NSString *vid;

/// 视频播放完毕后的处理方式  0：显示播放结束UI（缺省）  1：重新播放  2：播放下一个
@property (nonatomic, assign) NSInteger actionAfterPlayFinish;

/// 离线模式播放 皮肤需要隐藏下载按钮 默认NO
@property (nonatomic, assign) BOOL isOffPlayModel;

@end

NS_ASSUME_NONNULL_END
