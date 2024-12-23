//
//  PLVDownloadBaseCell.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/12/23.
//

#import <UIKit/UIKit.h>
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

NS_ASSUME_NONNULL_BEGIN


@interface PLVDownloadBaseCell : UITableViewCell

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
