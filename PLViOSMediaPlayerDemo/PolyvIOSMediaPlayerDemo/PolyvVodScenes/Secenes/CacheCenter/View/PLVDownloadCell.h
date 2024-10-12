//
//  PLVDownloadCell.h
//  PolyvVodSDKDemo
//
//  Created by MissYasiky on 2019/6/12.
//  Copyright © 2019 POLYV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVDownloadCell : UITableViewCell

/// 标题
@property (strong, nonatomic) UILabel *titleLabel;

/// 视频大小
@property (strong, nonatomic) UILabel *videoSizeLabel;

/// 下载状态
@property (strong, nonatomic) UIImageView *downloadStateImgView;

/// 缩略图
@property (strong, nonatomic) UIImageView *thumbnailView;
/// 缩略图URL
@property (copy, nonatomic) NSString *thumbnailUrl;

/// 视频时长
@property (nonatomic, strong) UILabel *timeLable;

+ (NSString *)identifier;

+ (CGFloat)cellHeight;

- (void)configCellWithModel:(PLVDownloadInfo *)model;

@end

NS_ASSUME_NONNULL_END
