//
//  PLVMediaKnowledgePointCell.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2026/1/4.
//

#import "PLVMediaKnowledgePointCell.h"
#import <PolyvMediaPlayerSDK/PLVVodMediaColorUtil.h>

@interface PLVMediaKnowledgePointCell ()

@property (nonatomic, strong) UIImageView *statusImageView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation PLVMediaKnowledgePointCell

#pragma mark - Init & UI

+ (PLVMediaKnowledgePointCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *cellId = @"PLVMediaKnowledgePointCell";
    PLVMediaKnowledgePointCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[PLVMediaKnowledgePointCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [PLVVodMediaColorUtil colorFromHexString:@"#333437"];
        cell.contentView.backgroundColor = [PLVVodMediaColorUtil colorFromHexString:@"#333437"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.contentView addSubview:self.statusImageView];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.timeLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat contentWidth = CGRectGetWidth(self.contentView.bounds);
    CGFloat contentHeight = CGRectGetHeight(self.contentView.bounds);
    
    // statusImageView 布局
    CGFloat statusImageViewSize = 24;
    CGFloat statusImageViewX = 23;
    CGFloat statusImageViewY = (contentHeight - statusImageViewSize) / 2.0;
    self.statusImageView.frame = CGRectMake(statusImageViewX, statusImageViewY, statusImageViewSize, statusImageViewSize);
    
    // timeLabel 布局
    CGFloat timeLabelRightMargin = 32;
    CGFloat timeLabelWidth = MAX(10, [self.timeLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, contentHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.timeLabel.font} context:nil].size.width);
    CGFloat timeLabelHeight = MAX(10, [self.timeLabel.text boundingRectWithSize:CGSizeMake(timeLabelWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.timeLabel.font} context:nil].size.height);
    
    if (self.isShowDesc) {
        // 显示描述时，timeLabel 在右侧
        CGFloat timeLabelX = contentWidth - timeLabelWidth - timeLabelRightMargin;
        CGFloat timeLabelY = (contentHeight - timeLabelHeight) / 2.0;
        self.timeLabel.frame = CGRectMake(timeLabelX, timeLabelY, timeLabelWidth, timeLabelHeight);
        
        // descLabel 布局
        CGFloat descLabelLeftMargin = 15;
        CGFloat descLabelX = CGRectGetMaxX(self.statusImageView.frame) + descLabelLeftMargin;
        CGFloat descLabelWidth = MAX(1, timeLabelX - descLabelX - descLabelLeftMargin);
        CGFloat descLabelHeight = MAX(1, [self.descLabel.text boundingRectWithSize:CGSizeMake(descLabelWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.descLabel.font} context:nil].size.height);
        CGFloat descLabelY = (contentHeight - descLabelHeight) / 2.0;
        self.descLabel.frame = CGRectMake(descLabelX, descLabelY, descLabelWidth, descLabelHeight);
    } else {
        // 不显示描述时，timeLabel 紧跟在 statusImageView 后面
        CGFloat timeLabelLeftMargin = 15;
        CGFloat timeLabelX = CGRectGetMaxX(self.statusImageView.frame) + timeLabelLeftMargin;
        CGFloat timeLabelY = (contentHeight - timeLabelHeight) / 2.0;
        self.timeLabel.frame = CGRectMake(timeLabelX, timeLabelY, timeLabelWidth, timeLabelHeight);
        
        // descLabel 隐藏
        self.descLabel.frame = CGRectZero;
    }
}


#pragma mark - Setter

- (void)setPointModel:(PLVMediaKnowledgePoint *)pointModel {
    _pointModel = pointModel;
    if (self.isShowDesc) {
        self.descLabel.hidden = NO;
        self.descLabel.text = pointModel.name;
    }else {
        self.descLabel.hidden = YES;
        self.descLabel.text = @"";
    }
    self.timeLabel.text = [self timeStringWithSeconds:pointModel.time];
}

- (void)setIsSelectCell:(BOOL)isSelectCell {
    _isSelectCell = isSelectCell;
    if (isSelectCell) {
        [self.statusImageView setImage:[UIImage imageNamed:@"plv_playing_btn"]];
        self.descLabel.textColor = [PLVVodMediaColorUtil colorFromHexString:@"#3990FF"];
    }else {
        [self.statusImageView setImage:[UIImage imageNamed:@"plv_play_btn"]];
        self.descLabel.textColor = [PLVVodMediaColorUtil colorFromHexString:@"#FFFFFF" alpha:0.8];
    }
}

- (void)setIsShowDesc:(BOOL)isShowDesc {
    _isShowDesc = isShowDesc;
    [self setNeedsLayout];
}

/// 时间转字符串
- (NSString *)timeStringWithSeconds:(NSTimeInterval)seconds {
    NSInteger time = seconds;
    NSInteger _hours = time / 60 / 60;
    NSInteger _minutes = (time / 60) % 60;
    NSInteger _seconds = time % 60;
    NSString *timeString = _hours > 0 ? [NSString stringWithFormat:@"%02zd:", _hours] : @"00:";
    timeString = [timeString stringByAppendingString:[NSString stringWithFormat:@"%02zd:%02zd", _minutes, _seconds]];
    return timeString;
}


#pragma mark - Loadlazy

- (UIImageView *)statusImageView {
    if (_statusImageView == nil) {
        _statusImageView = [[UIImageView alloc]init];
        [_statusImageView setImage:[UIImage imageNamed:@"plv_play_btn"]];
    }
    return _statusImageView;
}

- (UILabel *)descLabel {
    if (_descLabel == nil) {
        _descLabel = [[UILabel alloc]init];
        _descLabel.textColor = [PLVVodMediaColorUtil colorFromHexString:@"#FFFFFF" alpha:0.8];
        _descLabel.font = [UIFont systemFontOfSize:14];
        _descLabel.numberOfLines = 0;
    }
    return _descLabel;
}

- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textColor = [PLVVodMediaColorUtil colorFromHexString:@"#FFFFFF" alpha:0.6];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.numberOfLines = 0;
    }
    return _timeLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
