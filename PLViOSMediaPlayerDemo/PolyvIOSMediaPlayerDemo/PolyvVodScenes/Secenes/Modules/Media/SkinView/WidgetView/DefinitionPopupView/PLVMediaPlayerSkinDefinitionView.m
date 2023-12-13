//
//  PLVMediaPlayerSkinDefinitionView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/11.
//

#import "PLVMediaPlayerSkinDefinitionView.h"
#import "UIImage+Tint.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

@interface PLVMediaPlayerSkinDefinitionView()

@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *lowQualityBtn;
@property (nonatomic, strong) UIButton *midQualityBtn;
@property (nonatomic, strong) UIButton *highQualtiyBtn;
@property (nonatomic, strong) CAGradientLayer *bgLayer;

@end

@implementation PLVMediaPlayerSkinDefinitionView

- (void)layoutSubviews{
    [super layoutSubviews];
    [self updateUI];
}

- (instancetype)init{
    if (self = [super init]){
        [self setupUI];
    }
    
    return self;
}

- (void)setupUI{
    // quality
    [self.layer addSublayer:self.bgLayer];
    [self addSubview:self.closeBtn];
    
    [self addSubview:self.lowQualityBtn];
    [self addSubview:self.midQualityBtn];
    [self addSubview:self.highQualtiyBtn];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:tapGes];
}

- (void)updateUI{
    CGFloat rightInset = 160;
    CGFloat topInset = 80;
    CGSize buttonSize = CGSizeMake(40, 20);
    
    // 背景虚化图层
    self.bgLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    self.closeBtn.frame = CGRectMake(self.bounds.size.width - 24 - 20, 20, 24, 24);
    
    CGPoint origin = CGPointMake(self.bounds.size.width - rightInset - buttonSize.width, topInset);
    self.lowQualityBtn.frame = CGRectMake(origin.x, origin.y, buttonSize.width, buttonSize.height);
    origin = CGPointMake(origin.x, CGRectGetMaxY(self.lowQualityBtn.frame) + 48);
    self.midQualityBtn.frame = CGRectMake(origin.x, origin.y, buttonSize.width, buttonSize.height);
    origin = CGPointMake(origin.x, CGRectGetMaxY(self.midQualityBtn.frame) + 48);
    self.highQualtiyBtn.frame = CGRectMake(origin.x, origin.y, buttonSize.width, buttonSize.height);
}

- (CAGradientLayer *)bgLayer{
    if (!_bgLayer) {
        _bgLayer = [CAGradientLayer layer];
        _bgLayer.startPoint = CGPointMake(0.0, 0);
        _bgLayer.endPoint = CGPointMake(1, 0);
        _bgLayer.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.8].CGColor];
        _bgLayer.locations = @[@(0.0), @(1.0f)];
    }
    return _bgLayer;
}

- (UIButton *)closeBtn{
    if(!_closeBtn){
        _closeBtn = [[UIButton alloc] init];
        UIImage *origImg = [UIImage imageNamed:@"plv_skin_menu_icon_close"];
        [_closeBtn setImage:[origImg imageWithCustomTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _closeBtn;
}

- (UIButton *)lowQualityBtn{
    if (!_lowQualityBtn){
        _lowQualityBtn = [self buttonWithTitle:@"流畅" tag:1];
        [_lowQualityBtn addTarget:self action:@selector(qualityButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _lowQualityBtn;
}

- (UIButton *)midQualityBtn{
    if (!_midQualityBtn){
        _midQualityBtn = [self buttonWithTitle:@"高清" tag:2];
        [_midQualityBtn addTarget:self action:@selector(qualityButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _midQualityBtn;
}

- (UIButton *)highQualtiyBtn{
    if (!_highQualtiyBtn){
        _highQualtiyBtn = [self buttonWithTitle:@"超清" tag:3];
        [_highQualtiyBtn addTarget:self action:@selector(qualityButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _highQualtiyBtn;
}

- (UIButton *)buttonWithTitle:(NSString *)title tag:(NSInteger )tag{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[PLVVodColorUtil colorFromHexString:@"#3F76FC"] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.tag = tag;
    
    return button;
}

#pragma mark 【button action】
- (void)qualityButtonClick:(UIButton *)qualityButton{
    [self hideDefinitionView];
    [self resetButtonState];
    
    qualityButton.selected = YES;
    NSInteger qualityLevel = qualityButton.tag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerSkinDefinitionView_SwitchQualtiy:)]){
        [self.delegate mediaPlayerSkinDefinitionView_SwitchQualtiy:qualityLevel];
    }
}

- (void)resetButtonState{
    _lowQualityBtn.selected = NO;
    _midQualityBtn.selected = NO;
    _highQualtiyBtn.selected = NO;
}

- (void)hideDefinitionView{
    self.hidden = YES;
    [self removeFromSuperview];
}

- (void)closeButtonClick:(UIButton *)closeButton{
    [self hideDefinitionView];
}

- (void)showDefinitionViewWithModel:(PLVMediaPlayerState *)mediaState{
    [self resetButtonState];
    self.hidden = NO;
    
    NSInteger qualityLevel = mediaState.curQualityLevel;
    switch (qualityLevel) {
        case 1:
            _lowQualityBtn.selected = YES;
            break;
        case 2:
            _midQualityBtn.selected = YES;
            break;
        case 3:
            _highQualtiyBtn.selected = YES;
            break;
        default:
            break;
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap{
    // 处理解锁按钮的显示/隐藏
    [self hideDefinitionView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
