//
//  PLVMediaPlayerSkinSubtitleSetCell.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/8/14.
//

#import "PLVMediaPlayerSkinSubtitleSetCell.h"
#import <PolyvMediaPlayerSDK/PLVVodMediaColorUtil.h>

@interface PLVMediaPlayerSkinSubtitleSetCell ()

@property (nonatomic, strong) UILabel *subtilteText;
@property (nonatomic, strong) UIView *subtitleBackgroud;

@end

@implementation PLVMediaPlayerSkinSubtitleSetCell

#pragma mark [life cycle]
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self setupUI];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateUI];
}

#pragma mark [init]
- (void)setupUI{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [PLVVodMediaColorUtil colorFromHexString:@"#F7F8FA" alpha:1.0];

    [self.contentView addSubview:self.subtitleBackgroud];
    [self.contentView addSubview:self.subtilteText];
}

- (void)updateUI{
    self.subtitleBackgroud.frame = CGRectMake(16, 4, self.frame.size.width - 32, 56);
    self.subtilteText.frame = CGRectMake(36, 22, self.frame.size.width - 72, 20);
}

- (UILabel *)subtilteText{
    if (!_subtilteText){
        _subtilteText = [[UILabel alloc] init];
        _subtilteText.font = [UIFont systemFontOfSize:14];
        _subtilteText.textAlignment = NSTextAlignmentLeft;
    }
    
    return _subtilteText;
}

- (UIView *)subtitleBackgroud{
    if (!_subtitleBackgroud){
        _subtitleBackgroud = [[UIView alloc] init];
        _subtitleBackgroud.layer.cornerRadius = 4.0;
        _subtitleBackgroud.layer.borderWidth = 1.0;
        _subtitleBackgroud.backgroundColor = [UIColor whiteColor];
    }
    return _subtitleBackgroud;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark [public]
- (void)configSubtitleText:(NSString *)subtitleText select:(BOOL)selected{
    _subtilteText.text = subtitleText;

    if (selected){
        _subtitleBackgroud.layer.borderColor = [PLVVodMediaColorUtil colorFromHexString:@"#3F76FC"].CGColor;
        _subtitleBackgroud.backgroundColor =  [PLVVodMediaColorUtil colorFromHexString:@"#3F76FC" alpha:0.1];
        _subtilteText.textColor = [PLVVodMediaColorUtil colorFromHexString:@"#3F76FC"];
    }
    else{
        _subtitleBackgroud.layer.borderColor = [UIColor whiteColor].CGColor;
        _subtitleBackgroud.backgroundColor = [UIColor whiteColor];
        _subtilteText.textColor = [PLVVodMediaColorUtil colorFromHexString:@"#000000" alpha:0.8];
    }}

@end
