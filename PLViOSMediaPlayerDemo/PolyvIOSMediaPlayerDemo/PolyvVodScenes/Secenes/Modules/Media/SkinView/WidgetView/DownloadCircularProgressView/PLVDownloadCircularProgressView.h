//
//  PLVDownloadCircularProgressView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/9/4.
//

#import <UIKit/UIKit.h>
#import "PLVCircularProgressView.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVDownloadCircularProgressView;

@protocol PLVDownloadCircularProgressViewDelegate <NSObject>

- (void)circularProgressView_startDownload:(PLVDownloadCircularProgressView *)progressView;

@end

@interface PLVDownloadCircularProgressView : UIView

/// 下载进度
@property (nonatomic, strong) PLVCircularProgressView *progressView;
/// 下载状态
@property (nonatomic, strong) UILabel *statusLable;
/// 下载按钮 （样式需要自定义）
@property (nonatomic, strong) UIButton *startDownload;

/// 时间回调
@property (nonatomic, weak) id<PLVDownloadCircularProgressViewDelegate> delegate;

/// 更新下载状态
- (void)updateDownloadState:(PLVVodDownloadState )downloadState;

/// 重置 恢复默认状态
- (void)resetProgressView;

@end

NS_ASSUME_NONNULL_END
