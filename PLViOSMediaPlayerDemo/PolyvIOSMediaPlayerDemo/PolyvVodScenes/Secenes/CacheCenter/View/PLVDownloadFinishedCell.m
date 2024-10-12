//
//  PLVDownloadFinishedCell.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/9/22.
//

#import "PLVDownloadFinishedCell.h"
#import "PLVVodMediaCommonUtil.h"

@implementation PLVDownloadFinishedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initCompleteViews];
    }
    
    return self;
}

- (void)initCompleteViews{
}

- (void)layoutSubviews{
    CGFloat offset_x = 16;
    CGFloat offset_y = 6;
    
    // 图片
    CGFloat start_x = offset_x;
    CGFloat start_y = offset_y;
    self.thumbnailView.frame = CGRectMake(start_x, start_y, 104, 58);
        
    // 视频标题
    start_x = CGRectGetMaxX(self.thumbnailView.frame) + 8;
    start_y = CGRectGetMinY(self.thumbnailView.frame) + 8;
    CGFloat width = self.bounds.size.width - 16 -start_x;
    self.titleLabel.frame = CGRectMake(start_x, start_y, width, 20);
    
    // 清晰度、文件大小
    start_x = CGRectGetMaxX(self.thumbnailView.frame) + 8;
    start_y = CGRectGetMaxY(self.titleLabel.frame) + 5;
    self.videoSizeLabel.frame = CGRectMake(start_x, start_y, 120, 15);
    
    // 视频时长
    start_x = CGRectGetMaxX(self.thumbnailView.frame) - 60 - 5;
    start_y = CGRectGetMaxY(self.thumbnailView.frame) - 4 - 15;
    self.timeLable.frame = CGRectMake(start_x, start_y, 60, 15);
}

- (void)configCellWithModel:(PLVDownloadInfo *)model{
    self.thumbnailUrl = model.snapshot;
    self.titleLabel.text = model.title;
        
    // 文件大小 清晰度
    NSString *strQuality = NSStringFromPLVVodMediaQuality(model.quality);
    NSString *downloadProgressStr = [NSString stringWithFormat:@"%@:%@", strQuality,[PLVVodMediaCommonUtil formatFilesize:model.filesize]];
    self.videoSizeLabel.text = downloadProgressStr;
    self.timeLable.text = [PLVVodMediaCommonUtil timeFormatStringWithTime:model.duration];
}

@end
