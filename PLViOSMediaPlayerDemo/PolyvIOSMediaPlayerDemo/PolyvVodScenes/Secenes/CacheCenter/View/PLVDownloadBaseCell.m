//
//  PLVDownloadBaseCell.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/12/23.
//

#import "PLVDownloadBaseCell.h"

#import "PLVVodMediaCommonUtil.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation PLVDownloadBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.backgroundColor = [UIColor colorWithRed:12/255.0 green:38/255.0 blue:65/255.0 alpha:1.0];

        [self initViews];
    }
    
    return self;
}

- (void)initViews{
    [self.contentView addSubview:self.thumbnailView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.downloadStateImgView];
    [self.contentView addSubview:self.videoSizeLabel];
    [self.contentView addSubview:self.timeLable];
}

- (UILabel *)titleLabel{
    if (!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [PLVVodMediaCommonUtil colorFromHexString:@"#FFFFFF" alpha:1.0];
    }
    
    return _titleLabel;
}

- (UILabel *)videoSizeLabel{
    if (!_videoSizeLabel){
        _videoSizeLabel = [[UILabel alloc] init];
        _videoSizeLabel.font = [UIFont systemFontOfSize:12];
        _videoSizeLabel.textColor = [PLVVodMediaCommonUtil colorFromHexString:@"#FFFFFF" alpha:0.4];
    }
    
    return _videoSizeLabel;
}

- (UIImageView *)downloadStateImgView{
    if (!_downloadStateImgView){
        _downloadStateImgView = [[UIImageView alloc] init];
        _downloadStateImgView.clipsToBounds = YES;
    }
    
    return _downloadStateImgView;
}

- (UIImageView *)thumbnailView{
    if (!_thumbnailView){
        _thumbnailView = [[UIImageView alloc] init];
        _thumbnailView.clipsToBounds = YES;
        _thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailView.layer.cornerRadius = 2.0;
    }
    
    return _thumbnailView;
}

- (UILabel *)timeLable{
    if (!_timeLable){
        _timeLable = [[UILabel alloc] init];
        _timeLable.font = [UIFont systemFontOfSize:12.0];
        _timeLable.textColor = [UIColor whiteColor];
        _timeLable.textAlignment = NSTextAlignmentRight;
    }
    return _timeLable;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setThumbnailUrl:(NSString *)thumbnailUrl {
    _thumbnailUrl = thumbnailUrl;
    [self.thumbnailView sd_setImageWithURL:[NSURL URLWithString:thumbnailUrl] placeholderImage:[UIImage imageNamed:@"plv_ph_courseCover"]];
}

+ (NSString *)identifier{
    return NSStringFromClass([self class]);
}

+ (CGFloat)cellHeight{
    return 70.0;;
}

#pragma makr -- public
- (void)configCellWithModel:(PLVDownloadInfo *)model{
    NSLog(@"need impletation in subclass");
}

@end
