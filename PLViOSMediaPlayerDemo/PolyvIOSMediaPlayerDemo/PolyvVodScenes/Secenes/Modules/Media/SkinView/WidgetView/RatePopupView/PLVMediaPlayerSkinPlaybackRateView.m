//
//  PLVMediaPlayerSkinPlaybackRateView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/11.
//

#import "PLVMediaPlayerSkinPlaybackRateView.h"
#import "UIImage+Tint.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

@interface PLVMediaPlayerSkinPlaybackRateView()

@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *playRate1Btn; // 0.5
@property (nonatomic, strong) UIButton *playRate2Btn; // 1
@property (nonatomic, strong) UIButton *playRate3Btn; // 1.5
@property (nonatomic, strong) UIButton *playRate4Btn; // 2

@property (nonatomic, strong) CAGradientLayer *bgLayer;

@end

@implementation PLVMediaPlayerSkinPlaybackRateView

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
    [self.layer addSublayer:self.bgLayer];
    [self addSubview:self.closeBtn];
    
    [self addSubview:self.playRate1Btn];
    [self addSubview:self.playRate2Btn];
    [self addSubview:self.playRate3Btn];
    [self addSubview:self.playRate4Btn];
    
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
    self.playRate1Btn.frame = CGRectMake(origin.x, origin.y, buttonSize.width, buttonSize.height);
    origin = CGPointMake(origin.x, CGRectGetMaxY(self.playRate1Btn.frame) + 43);
    self.playRate2Btn.frame = CGRectMake(origin.x, origin.y, buttonSize.width, buttonSize.height);
    origin = CGPointMake(origin.x, CGRectGetMaxY(self.playRate2Btn.frame) + 43);
    self.playRate3Btn.frame = CGRectMake(origin.x, origin.y, buttonSize.width, buttonSize.height);
    origin = CGPointMake(origin.x, CGRectGetMaxY(self.playRate3Btn.frame) + 43);
    self.playRate4Btn.frame = CGRectMake(origin.x, origin.y, buttonSize.width, buttonSize.height);
}

- (UIButton *)playRate1Btn{
    if (!_playRate1Btn){
        _playRate1Btn = [self buttonWithTitle:@"0.5x" tag:1];
        [_playRate1Btn addTarget:self action:@selector(playRateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _playRate1Btn;
}

- (UIButton *)playRate2Btn{
    if (!_playRate2Btn){
        _playRate2Btn = [self buttonWithTitle:@"1.0x" tag:2];
        [_playRate2Btn addTarget:self action:@selector(playRateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _playRate2Btn;
}

- (UIButton *)playRate3Btn{
    if (!_playRate3Btn){
        _playRate3Btn = [self buttonWithTitle:@"1.5x" tag:3];
        [_playRate3Btn addTarget:self action:@selector(playRateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _playRate3Btn;
}

- (UIButton *)playRate4Btn{
    if (!_playRate4Btn){
        _playRate4Btn = [self buttonWithTitle:@"2.0x" tag:4];
        [_playRate4Btn addTarget:self action:@selector(playRateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _playRate4Btn;
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

- (UIButton *)buttonWithTitle:(NSString *)title tag:(NSInteger )tag{
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[PLVVodColorUtil colorFromHexString:@"#3F76FC"] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    button.tag = tag;
    
    return button;
}

#pragma mark 【Button Action】
- (void)playRateButtonClick:(UIButton *)playRateButton{
    [self hideRateView];
    [self resetButtonState];
    
    playRateButton.selected = YES;
    NSInteger index = playRateButton.tag;
    CGFloat rate = index/2.0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerSkinPlaybackRateView_SwitchPlayRate:)]){
        [self.delegate mediaPlayerSkinPlaybackRateView_SwitchPlayRate:rate];
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap{
    // 处理解锁按钮的显示/隐藏
    [self hideRateView];
}

- (void)resetButtonState{
    self.playRate1Btn.selected = NO;
    self.playRate2Btn.selected = NO;
    self.playRate3Btn.selected = NO;
    self.playRate4Btn.selected = NO;
}

- (void)closeButtonClick:(UIButton *)closeButton{
    [self hideRateView];
}

- (void)hideRateView{
    self.hidden = YES;
    [self removeFromSuperview];
}

- (void)showPlayRateViewWithModel:(PLVMediaPlayerState *)mediaState{
    [self resetButtonState];
    self.hidden = NO;

    NSInteger rate = mediaState.curPlayRate *2;
    
    switch (rate) {
        case 1:
            self.playRate1Btn.selected = YES;
            break;
        case 2:
            self.playRate2Btn.selected = YES;
            break;
        case 3:
            self.playRate3Btn.selected = YES;
            break;
        case 4:
            self.playRate4Btn.selected = YES;
            break;
            
        default:
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
