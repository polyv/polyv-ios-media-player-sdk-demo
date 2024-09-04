//
//  PLVMediaPlayerSkinLandscapeSubtitleSetCell.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/8/15.
//

#import "PLVMediaPlayerSkinLandscapeSubtitleSetCell.h"
#import <PolyvMediaPlayerSDK/PLVVodMediaColorUtil.h>

@interface PLVMediaPlayerSkinLandscapeSubtitleSetCell ()

@property (nonatomic) UILabel *subtitleText;

@end

@implementation PLVMediaPlayerSkinLandscapeSubtitleSetCell

#pragma mark [life cycle]
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
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
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.subtitleText];
}

- (void)updateUI{
    self.subtitleText.frame = CGRectMake(0, 22, self.bounds.size.width, 20);
}

- (UILabel *)subtitleText{
    if (!_subtitleText){
        _subtitleText = [[UILabel alloc] init];
        _subtitleText.font = [UIFont systemFontOfSize:14];
        _subtitleText.textColor = [UIColor whiteColor];
    }
    
    return _subtitleText;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark [public]
- (void)configSubtitleText:(NSString *)subtitleText select:(BOOL)selected{
    _subtitleText.text = subtitleText;
    
    if (selected){
        _subtitleText.textColor = [PLVVodMediaColorUtil colorFromHexString:@"#3F76FC" alpha:1.0];
    }
    else{
        _subtitleText.textColor = [UIColor whiteColor];
    }
}

@end
