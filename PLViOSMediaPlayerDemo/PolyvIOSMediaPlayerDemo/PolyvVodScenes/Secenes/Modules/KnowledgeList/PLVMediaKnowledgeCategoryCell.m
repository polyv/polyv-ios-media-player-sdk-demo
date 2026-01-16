//
//  PLVMediaKnowledgeCategoryCell.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2026/1/4.
//

#import "PLVMediaKnowledgeCategoryCell.h"
#import "PLVMediaMarqueeLabel.h"
#import <PolyvMediaPlayerSDK/PLVVodMediaColorUtil.h>

@interface PLVMediaKnowledgeCategoryCell ()

@property (nonatomic, strong) PLVMediaMarqueeLabel *categoryLabel;
@property (nonatomic, strong) UILabel *numberLabel;

@end

@implementation PLVMediaKnowledgeCategoryCell

#pragma mark - Init & UI

+ (PLVMediaKnowledgeCategoryCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *cellId = @"PLVMediaKnowledgeCategoryCell";
    PLVMediaKnowledgeCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[PLVMediaKnowledgeCategoryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [PLVVodMediaColorUtil colorFromHexString:@"#222326"];
        cell.contentView.backgroundColor = [PLVVodMediaColorUtil colorFromHexString:@"#222326"];
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
    [self.contentView addSubview:self.categoryLabel];
    [self.contentView addSubview:self.numberLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat contentWidth = CGRectGetWidth(self.contentView.bounds);
    CGFloat contentHeight = CGRectGetHeight(self.contentView.bounds);
    
    // categoryLabel 布局
    CGFloat categoryLabelX = 32;
    CGFloat categoryLabelWidth = MIN(120, contentWidth - categoryLabelX - 10);
    CGFloat categoryLabelHeight = MAX(10, [self.categoryLabel.text boundingRectWithSize:CGSizeMake(categoryLabelWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.categoryLabel.font} context:nil].size.height);
    CGFloat categoryLabelY = (contentHeight - categoryLabelHeight) / 2.0;
    self.categoryLabel.frame = CGRectMake(categoryLabelX, categoryLabelY, categoryLabelWidth, categoryLabelHeight);
    
    // numberLabel 布局
    CGFloat numberLabelX = CGRectGetMaxX(self.categoryLabel.frame);
    CGFloat numberLabelWidth = MAX(10, [self.numberLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, contentHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.numberLabel.font} context:nil].size.width);
    CGFloat numberLabelHeight = MAX(10, [self.numberLabel.text boundingRectWithSize:CGSizeMake(numberLabelWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.numberLabel.font} context:nil].size.height);
    CGFloat numberLabelY = (contentHeight - numberLabelHeight) / 2.0;
    self.numberLabel.frame = CGRectMake(numberLabelX, numberLabelY, numberLabelWidth, numberLabelHeight);
}

#pragma mark - Setter
- (void)setWorkKeyModel:(PLVMediaKnowledgeWorkKey *)workKeyModel {
    _workKeyModel = workKeyModel;
    self.categoryLabel.text = workKeyModel.name;
    self.numberLabel.text = [NSString stringWithFormat:@"（%lu）", (unsigned long)workKeyModel.knowledgePoints.count];
}

- (void)setIsSelectCell:(BOOL)isSelectCell {
    if (isSelectCell) {
        self.backgroundColor = [PLVVodMediaColorUtil colorFromHexString:@"#333437"];
        self.contentView.backgroundColor = [PLVVodMediaColorUtil colorFromHexString:@"#333437"];
        // 滚动
        self.categoryLabel.scrollDuration = 10;
        [self.categoryLabel restartLabel];
    }else {
        self.backgroundColor = [PLVVodMediaColorUtil colorFromHexString:@"#222326"];
        self.contentView.backgroundColor = [PLVVodMediaColorUtil colorFromHexString:@"#222326"];
        //暂停滚动
        self.categoryLabel.scrollDuration = -1;
        [self.categoryLabel shutdownLabel];
    }
}


#pragma mark - Pravite Method

- (void)beginAnimation {
    [self.categoryLabel restartLabel];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animationFinish) object:nil];
    [self performSelector:@selector(animationFinish) withObject:nil afterDelay:10*3];
}

- (void)animationFinish {
    [self.categoryLabel shutdownLabel];
    self.hidden = YES;
}


#pragma mark - Loadlazy

- (UILabel *)numberLabel {
    if (_numberLabel == nil) {
        _numberLabel = [[UILabel alloc]init];
        _numberLabel.textColor = [PLVVodMediaColorUtil colorFromHexString:@"#FFFFFF" alpha:0.6];
        _numberLabel.font = [UIFont systemFontOfSize:14];
    }
    return _numberLabel;
}

- (PLVMediaMarqueeLabel *)categoryLabel {
    if (_categoryLabel == nil) {
        _categoryLabel = [[PLVMediaMarqueeLabel alloc] initWithFrame:self.contentView.bounds duration:10.0 andFadeLength:0];
        _categoryLabel.scrollDuration = -1;
//        _categoryLabel.holdScrolling = YES;
        _categoryLabel.textColor = [PLVVodMediaColorUtil colorFromHexString:@"#FFFFFF" alpha:0.6];
        _categoryLabel.font = [UIFont systemFontOfSize:14];
    }
    return _categoryLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end
