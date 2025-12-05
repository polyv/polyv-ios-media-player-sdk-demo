//
//  PLVMediaPlayerSkinPlaybackRateView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/11.
//

#import "PLVMediaPlayerSkinPlaybackRateView.h"
#import "UIImage+PLVVodMediaTint.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

@interface PLVMediaPlayerSkinPlaybackRateView()

@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) NSArray<NSNumber *> *playbackRates;
@property (nonatomic, strong) NSMutableArray<UIButton *> *playRateButtons;
@property (nonatomic, strong) UIScrollView *rateScrollView;

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
    
    [self addSubview:self.rateScrollView];
    [self setupPlaybackRateButtonsIfNeeded];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:tapGes];
}

- (void)updateUI{
    CGFloat rightInset = 160;
    CGFloat topInset = 80;
    CGSize buttonSize = CGSizeMake(48, 28);
    
    // 背景虚化图层
    self.bgLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);

    self.closeBtn.frame = CGRectMake(self.bounds.size.width - 24 - 20, 20, 24, 24);

    CGFloat scrollWidth = buttonSize.width + 8;
    CGFloat scrollX = self.bounds.size.width - rightInset - scrollWidth;

    CGFloat maxVisibleHeight = MAX(0, self.bounds.size.height - topInset - 40);
    self.rateScrollView.frame = CGRectMake(scrollX, topInset, scrollWidth, maxVisibleHeight);
    CGFloat verticalSpacing = 32;
    CGFloat contentY = 0;
    for (UIButton *button in self.playRateButtons){
        button.frame = CGRectMake(4, contentY, buttonSize.width, buttonSize.height);
        contentY = CGRectGetMaxY(button.frame) + verticalSpacing;
    }
    CGFloat contentHeight = MAX(buttonSize.height, contentY - verticalSpacing);
    self.rateScrollView.contentSize = CGSizeMake(self.rateScrollView.frame.size.width, contentHeight);
    if (self.rateScrollView.contentOffset.x != 0) {
        self.rateScrollView.contentOffset = CGPointMake(0, self.rateScrollView.contentOffset.y);
    }
}

- (void)setupPlaybackRateButtonsIfNeeded{
    if (self.playRateButtons.count > 0){
        return;
    }
    if (@available(iOS 15.0, *)) {
        self.playbackRates = @[@0.5, @0.75, @1.0, @1.25, @1.5, @2.0, @3.0];
    } else {
        self.playbackRates = @[@0.5, @0.75, @1.0, @1.25, @1.5, @2.0];
    }
    self.playRateButtons = [NSMutableArray array];
    for (NSInteger i = 0; i < (NSInteger)self.playbackRates.count; i++){
        CGFloat rate = self.playbackRates[i].floatValue;
        NSString *rateString = [NSString stringWithFormat:@"%.2f", rate];
        while ([rateString hasSuffix:@"0"] && ![rateString hasSuffix:@".0"]) {
            rateString = [rateString substringToIndex:rateString.length - 1];
        }
        NSString *title = [NSString stringWithFormat:@"%@ X", rateString];
        UIButton *button = [self buttonWithTitle:title tag:i];
        [button addTarget:self action:@selector(playRateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.rateScrollView addSubview:button];
        [self.playRateButtons addObject:button];
    }
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
    [button setTitleColor:[PLVVodMediaColorUtil colorFromHexString:@"#3F76FC"] forState:UIControlStateSelected];
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
    if (index < 0 || index >= (NSInteger)self.playbackRates.count){
        return;
    }
    CGFloat rate = self.playbackRates[index].floatValue;
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerSkinPlaybackRateView_SwitchPlayRate:)]){
        [self.delegate mediaPlayerSkinPlaybackRateView_SwitchPlayRate:rate];
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap{
    // 处理解锁按钮的显示/隐藏
    [self hideRateView];
}

- (void)resetButtonState{
    for (UIButton *btn in self.playRateButtons){
        btn.selected = NO;
    }
}

- (void)closeButtonClick:(UIButton *)closeButton{
    [self hideRateView];
}

- (void)hideRateView{
    self.hidden = YES;
    [self removeFromSuperview];
}

- (void)showPlayRateViewWithModel:(PLVMediaPlayerState *)mediaState{
    [self setupPlaybackRateButtonsIfNeeded];
    [self resetButtonState];
    self.hidden = NO;

    // 选中当前倍速（就近匹配）
    CGFloat target = mediaState.curPlayRate;
    NSInteger selIndex = 0;
    CGFloat minDiff = CGFLOAT_MAX;
    for (NSInteger i = 0; i < (NSInteger)self.playbackRates.count; i++){
        CGFloat r = self.playbackRates[i].floatValue;
        CGFloat diff = fabs(r - target);
        if (diff < minDiff){
            minDiff = diff;
            selIndex = i;
        }
    }
    if (selIndex >= 0 && selIndex < (NSInteger)self.playRateButtons.count){
        self.playRateButtons[selIndex].selected = YES;
    }
}

- (UIScrollView *)rateScrollView{
    if (!_rateScrollView){
        _rateScrollView = [[UIScrollView alloc] init];
        _rateScrollView.showsHorizontalScrollIndicator = NO;
        _rateScrollView.showsVerticalScrollIndicator = YES;
        _rateScrollView.bounces = YES;
        _rateScrollView.alwaysBounceHorizontal = NO;
        _rateScrollView.clipsToBounds = YES;
    }
    return _rateScrollView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
