
//
//  PLVVodMediaVideoListCell.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by POLYV on 2025/7/1.
//

#import "PLVVodMediaVideoListCell.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface PLVVodMediaVideoListCell()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *durationLabel;

@end

@implementation PLVVodMediaVideoListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.coverImageView = [[UIImageView alloc] init];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.coverImageView];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.numberOfLines = 2;
    [self.contentView addSubview:self.titleLabel];
    
    self.durationLabel = [[UILabel alloc] init];
    self.durationLabel.font = [UIFont systemFontOfSize:12];
    self.durationLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:self.durationLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat coverImageWidth = 160;
    CGFloat coverImageHeight = 90;
    CGFloat padding = 15;
    
    self.coverImageView.frame = CGRectMake(padding, (120 - coverImageHeight) / 2, coverImageWidth, coverImageHeight);
    
    CGFloat titleLabelX = CGRectGetMaxX(self.coverImageView.frame) + padding;
    CGFloat titleLabelWidth = self.contentView.bounds.size.width - titleLabelX - padding;
    
    self.titleLabel.frame = CGRectMake(titleLabelX, self.coverImageView.frame.origin.y, titleLabelWidth, 50);
    self.durationLabel.frame = CGRectMake(titleLabelX, CGRectGetMaxY(self.coverImageView.frame) - 20, titleLabelWidth, 20);
}



- (void)updateWithModel:(PLVVodMediaVideo *)video {
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:video.snapshot] placeholderImage:nil];
    self.titleLabel.text = video.title;
    self.durationLabel.text = [self durationStringFromTimeInterval:video.duration];
}

- (NSString *)durationStringFromTimeInterval:(NSTimeInterval)timeInterval {
    NSInteger interval = (NSInteger)timeInterval;
    NSInteger seconds = interval % 60;
    NSInteger minutes = (interval / 60) % 60;
    NSInteger hours = interval / 3600;
    if (hours > 0) {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
}

@end
