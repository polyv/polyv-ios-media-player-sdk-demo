//
//  PLVBaseViewController.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/10/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVBaseViewController : UIViewController

/// 系统截屏防护 YES 防止系统能截屏
@property (nonatomic, assign) BOOL sysScreenShotProtect;
/// 系统录制防护 YES  防止系统录屏
@property (nonatomic, assign) BOOL sysScreenRecordProtect;
/// 禁止录屏时是否处于播放状态
@property (nonatomic, assign) BOOL isPlayingWhenCaptureStart;

/// 子类重载，完成暂停播放相关逻辑
- (void)startPreventScreenCapture;
/// 子类重载，完成恢复播放相关逻辑
- (void)stopPreventScreenCapture;

@end

NS_ASSUME_NONNULL_END
