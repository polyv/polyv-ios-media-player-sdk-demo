//
//  PLVDownloadRunningCell.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/9/22.
//

#import "PLVDownloadRunningCell.h"
#import "PLVVodMediaCommonUtil.h"

@implementation PLVDownloadRunningCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self initProcessingViews];
    }
    
    return self;
}

- (void)initProcessingViews{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.videoStateLable];
    [self.contentView addSubview:self.downlaodProgressView];
    
    //
    self.videoSizeLabel.adjustsFontSizeToFitWidth = YES;
}

- (UILabel *)videoStateLable{
    if (!_videoStateLable){
        _videoStateLable = [[UILabel alloc] init];
        _videoStateLable.font = [UIFont systemFontOfSize:12];
        _videoStateLable.textColor = [PLVVodMediaCommonUtil colorFromHexString:@"#FFFFFF" alpha:0.4];
    }
    
    return _videoStateLable;
}

- (UIProgressView *)downlaodProgressView{
    if (!_downlaodProgressView){
        _downlaodProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _downlaodProgressView.trackTintColor = [PLVVodMediaCommonUtil colorFromHexString:@"#FFFFFF" alpha:0.2];
        _downlaodProgressView.progressTintColor = [PLVVodMediaCommonUtil colorFromHexString:@"#3F76FC" alpha:1.0];
    }
    
    return _downlaodProgressView;
}

- (void)layoutSubviews{
    CGFloat offset_x = 16;
    CGFloat offset_y = 6;
    
    // 图片
    CGFloat start_x = offset_x;
    CGFloat start_y = offset_y;
    self.thumbnailView.frame = CGRectMake(start_x, start_y, 104, 58);
    
    // 清晰度、文件大小
    start_x = self.bounds.size.width - offset_x - 80;
    self.videoSizeLabel.frame = CGRectMake(start_x, start_y, 80, 15);
    self.videoSizeLabel.textAlignment = NSTextAlignmentRight;
    
    // 视频标题
    start_x = CGRectGetMaxX(self.thumbnailView.frame) + 8;
    CGFloat width = CGRectGetMinX(self.videoSizeLabel.frame) - 8 -start_x;
    self.titleLabel.frame = CGRectMake(start_x, start_y, width, 20);
    
    // 下载状态 图标
    start_x = self.bounds.size.width - offset_x - 20;
    start_y = 25;
    self.downloadStateImgView.frame = CGRectMake(start_x, start_y, 20, 20);

    // 下载进度条
    start_x = CGRectGetMaxX(self.thumbnailView.frame) + 8;
    start_y = 34;
    width = self.bounds.size.width - (32+12) - start_x;
    self.downlaodProgressView.frame = CGRectMake(start_x, start_y, width, 3);
    
    // 下载中：下载进度百分比 下载速度 显示
    // 非下载中： 等待下载
    start_y = CGRectGetMaxY(self.thumbnailView.frame) - 15;
    self.videoStateLable.frame = CGRectMake(start_x, start_y, 200, 15);
    
    // 视频时长
    start_x = CGRectGetMaxX(self.thumbnailView.frame) - 60 - 5;
    start_y = CGRectGetMaxY(self.thumbnailView.frame) - 4 - 15;
    self.timeLable.frame = CGRectMake(start_x, start_y, 60, 15);
}

- (void)configCellWithModel:(PLVDownloadInfo *)model{
    // 图标
    self.thumbnailUrl = model.snapshot;
    // title
    self.titleLabel.text = model.title;
    
    // 文件大小 清晰度
    NSString *strQuality = NSStringFromPLVVodMediaQuality(model.quality);
    NSString *downloadProgressStr = [NSString stringWithFormat:@"%@:%@", strQuality,[PLVVodMediaCommonUtil formatFilesize:model.filesize]];
    self.videoSizeLabel.text = downloadProgressStr;
    
    // 下载状态图标
    self.downloadStateImgView.image = [UIImage imageNamed:[self downloadStateImgFromState:model.state]];
    
    // 时间
    NSString *strTime =  [PLVVodMediaCommonUtil timeFormatStringWithTime:model.duration];
    self.timeLable.text = strTime;
}

- (void)updateCellWithModel:(PLVDownloadInfo *)model{
    self.videoStateLable.text = @"等待中...";
    self.downloadStateImgView.image = [UIImage imageNamed:[self downloadStateImgFromState:model.state]];
    self.downlaodProgressView.progress = model.progress;

    switch (model.state) {
        case PLVVodDownloadStatePreparing:
        case PLVVodDownloadStateReady:
        case PLVVodDownloadStateStopped:
        case PLVVodDownloadStateStopping:{
        } break;
        case PLVVodDownloadStatePreparingTask:
        case PLVVodDownloadStateRunning:{
            
            float floatProgress = MIN(model.progress, 1);
            NSInteger progress = floatProgress * 100;
            NSString *strProgress = [NSString stringWithFormat:@"%d%%",(int)progress];
            NSString *strSpeed = [NSString stringWithFormat:@"%.2f M/s", model.bytesPerSeconds/ (1024 *1024)];
            NSString *downloaStateStr = [NSString stringWithFormat:@"%@（%@)", strProgress,strSpeed];
            self.videoStateLable.text = downloaStateStr;
            
        } break;
        case PLVVodDownloadStateSuccess:{
        } break;
        case PLVVodDownloadStateFailed:{
            self.videoStateLable.text = @"下载失败";
        } break;
    }
}

- (NSString *)downloadStateImgFromState:(PLVVodDownloadState )state{
    //
    NSString *imageName = nil;
    switch (state) {
        case PLVVodDownloadStateReady:
        case PLVVodDownloadStatePreparing:
            imageName = @"plv_download_wait";
            break;
        case PLVVodDownloadStateStopped:
        case PLVVodDownloadStateStopping:
            imageName = @"plv_download_wait";
            break;
        case PLVVodDownloadStatePreparingTask:
        case PLVVodDownloadStateRunning:
            imageName = @"plv_download_running";
            break;
        case PLVVodDownloadStateSuccess:
            imageName = @"plv_download_wait";
            break;
        case PLVVodDownloadStateFailed:
            imageName = @"plv_download_wait";
            break;
    }
    
    return imageName;
}

@end
