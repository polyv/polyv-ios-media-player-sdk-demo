//
//  PLVDownloadRunningCell.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/9/22.
//

#import "PLVDownloadCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVDownloadRunningCell : PLVDownloadCell

/// 视频下载状态
@property (strong, nonatomic) UILabel *videoStateLable;

/// 视频下载进度
@property (nonatomic, strong) UIProgressView *downlaodProgressView;

- (void)updateCellWithModel:(PLVDownloadInfo *)model;

@end

NS_ASSUME_NONNULL_END
