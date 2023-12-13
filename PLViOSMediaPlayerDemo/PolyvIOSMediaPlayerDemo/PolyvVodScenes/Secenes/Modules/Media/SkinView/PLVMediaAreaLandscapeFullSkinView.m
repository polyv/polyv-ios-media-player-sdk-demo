//
//  PLVMediaPlayerFullSkinView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/30.
//

#import "PLVMediaAreaLandscapeFullSkinView.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

@interface PLVMediaAreaLandscapeFullSkinView()

@property (nonatomic, strong) UIButton *lockScreenButton;

@end

@implementation PLVMediaAreaLandscapeFullSkinView

@synthesize titleLabel = _titleLabel;

#pragma mark 【Life Cycle】
- (instancetype)initWithSkinType:(PLVMediaAreaBaseSkinViewType)skinType{
    if (self = [super initWithSkinType:skinType]){
        [self setupUI];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (void)layoutSubviews{
    [self updateUI];
}

#pragma mark 【UI setup & update】
- (void)setupUI{
    [super setupUI];
    
    [self addSubview:self.lockScreenButton];
    [self addSubview:self.playRateButton];
    [self addSubview:self.qualityButton];
}
 
- (void)updateUI {
    if (self.isInited) {
        return;
    }
    if (CGRectGetWidth(self.bounds) == 0) {
        return;
    }
    
    self.isInited = YES;
    
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    
    CGFloat leftSafePadding;
    CGFloat rightSafePadding = 0;
    if (@available(iOS 11.0, *)) {
        leftSafePadding = self.safeAreaInsets.left;
        rightSafePadding = self.safeAreaInsets.right;
    } else {
        leftSafePadding = 20;
    }
    leftSafePadding += 0;

        [self controlsSwitchShowStatusWithAnimation:YES];
        BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        
        // 顶部UI
        CGFloat topShadowLayerHeight = 90.0;
        self.topShadowLayer.frame = CGRectMake(0, 0, viewWidth, topShadowLayerHeight);
        
        CGSize backButtonSize = CGSizeMake(40.0, 20.0f);
        CGFloat topPadding = isPad ? 30.0 : 16.0;

        if (![PLVVodFdUtil isiPhoneXSeries]) {
            leftSafePadding = 6;
            rightSafePadding = 6;
        }
        if (isPad) {
            leftSafePadding = 20;
            rightSafePadding = 20;
        }
        
        self.backButton.frame = CGRectMake(leftSafePadding, topPadding - 10, backButtonSize.width, 40);
        
        CGSize titleLabelFitSize = [self.titleLabel sizeThatFits:CGSizeMake(200, 22)];
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.backButton.frame), topPadding, titleLabelFitSize.width, backButtonSize.height);
        
        self.moreButton.frame = CGRectMake(viewWidth - rightSafePadding - backButtonSize.width, topPadding, backButtonSize.width, backButtonSize.height);
                
        [self refreshTitleLabelFrameInSmallScreen];
        [self refreshPlayTimesLabelFrame];
        [self refreshProgressViewFrame];

        // 底部UI
        CGFloat bottomShadowLayerHeight = 90.0;
        self.bottomShadowLayer.frame = CGRectMake(0, viewHeight - bottomShadowLayerHeight, viewWidth, bottomShadowLayerHeight);

        // 播放按钮
        CGFloat bottomPadding = 28.0;
        self.playButton.frame = CGRectMake(leftSafePadding, viewHeight - bottomPadding - backButtonSize.height, backButtonSize.width, backButtonSize.height);
        
        // 时间
        CGFloat timeLabelWidth = [self getLabelTextWidth:self.currentTimeLabel];
        CGPoint point = CGPointMake(CGRectGetMaxX(self.playButton.frame), CGRectGetMinY(self.playButton.frame));
        self.currentTimeLabel.frame = CGRectMake(point.x, point.y, timeLabelWidth, 20);
        self.diagonalsLabel.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLabel.frame), CGRectGetMinY(self.currentTimeLabel.frame), 5, 20);
        timeLabelWidth = [self getLabelTextWidth:self.durationLabel];
        self.durationLabel.frame = CGRectMake(CGRectGetMaxX(self.diagonalsLabel.frame), CGRectGetMinY(self.currentTimeLabel.frame), timeLabelWidth, 20);
        
        // 进度条
        CGFloat progressHigh = 20;
        CGRect progressRect = CGRectMake(leftSafePadding + 10, CGRectGetMinY(self.playButton.frame) - 12 -progressHigh, viewWidth - leftSafePadding - leftSafePadding, progressHigh);
        self.progressSlider.frame = progressRect;
        
        // 清晰度
        point = CGPointMake(CGRectGetMaxX(self.moreButton.frame) - 48, CGRectGetMinY(self.playButton.frame));
        self.qualityButton.frame = CGRectMake(point.x, point.y, 48, 20);
        
        // 倍速
        point = CGPointMake(CGRectGetMinX(self.qualityButton.frame) - 20 -48, point.y);
        self.playRateButton.frame = CGRectMake(point.x, point.y, 48, 20);
        
        // 锁屏按钮
        self.lockScreenButton.frame = CGRectMake(90, self.bounds.size.height/2 - 40/2, 40, 40);
   
        // 自动隐藏皮肤
        [self autoHideSkinView];

}

#pragma mark - [ Public Methods ]
- (void)hiddenMediaPlayerFullSkinView:(BOOL)isHidden {
    if (isHidden) {
        self.needShowSkin = self.isSkinShowing;
    }
    [self controlsSwitchShowStatusWithAnimation:!isHidden];
}

- (void)updateQualityLevel:(NSInteger)qualityLevel{
    NSString *title = @"流畅";
    switch (qualityLevel) {
        case 1:
            title = @"流畅";
            break;
        case 2:
            title = @"高清";
            break;
        case 3:
            title = @"超清";
            break;
        default:
            break;
    }
    
    [self.qualityButton setTitle:title forState:UIControlStateNormal];
}

- (void)updatePlayRate:(CGFloat)playRate{
    NSInteger playRateLevel = playRate *2;
    NSString *title = @"1.0 X";
    switch (playRateLevel) {
        case 1:
            title = @"0.5 X";
            break;
        case 2:
            title = @"1.0 X";
            break;
        case 3:
            title = @"1.5 X";
            break;
        case 4:
            title = @"2.0 X";
            break;
            
        default:
            break;
    }
    
    [self.playRateButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - [ Private Methods ]

- (void)refreshTitleLabelFrameInSmallScreen{
    BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    CGSize backButtonSize = CGSizeMake(40.0, 20.0);
    CGFloat topPadding = isPad ? 30.0 : 16.0;
    CGSize titleLabelFitSize = [self.titleLabel sizeThatFits:CGSizeMake(200, 22)];
    CGFloat titleLabelWidth = CGRectGetMinX(self.moreButton.frame) - CGRectGetMaxX(self.backButton.frame);

    if (isPad) {
        // iPad小分屏适配（横屏1:2），标题宽度调整，观看次数隐藏
        Boolean isSmallScreen = CGRectGetWidth(self.bounds) <= PLVScreenWidth / 3 ? YES : NO;
        if (isSmallScreen) {
            titleLabelWidth = MIN(titleLabelWidth, titleLabelFitSize.width);
            self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.backButton.frame), topPadding, titleLabelWidth, backButtonSize.height);
        } else {
            titleLabelWidth = MIN(titleLabelWidth, titleLabelFitSize.width);
            self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.backButton.frame), topPadding, titleLabelWidth, backButtonSize.height);
        }
    }
}

#pragma mark - [ Father Public Methods ]
- (void)refreshProgressViewFrame {
    self.progressView.frame = CGRectMake(self.frame.size.width / 2 - 73.5, self.frame.size.height / 2 -16, 147, 32);
}

- (void)showFloatViewShowButtonTipsLabelAnimation:(BOOL)showTips{
    // 横屏不需要显示提示，仅重写覆盖即可
}

#pragma mark Father Animation
- (void)controlsSwitchShowStatusWithAnimation:(BOOL)showStatus{
    if (self.isSkinShowing == showStatus) {
        NSLog(@"PLVLCBasePlayerSkinView - controlsSwitchShowAnimationWithShow failed , state is same");
        return;
    }
    
    self.isSkinShowing = showStatus;
    CGFloat alpha = self.isSkinShowing ? 1.0 : 0.0;
    __weak typeof(self) weakSelf = self;
    void (^animationBlock)(void) = ^{
        weakSelf.topShadowLayer.opacity = alpha;
        weakSelf.bottomShadowLayer.opacity = alpha;
        for (UIView * subview in weakSelf.subviews) {
            if ([subview isKindOfClass:PLVLCMediaProgressView.class]) {
                continue;
            }
            subview.alpha = alpha;
        }
    };
    [UIView animateWithDuration:0.3 animations:animationBlock completion:^(BOOL finished) {
        if (finished) {
            [self autoHideSkinView];
        }
    }];
}

#pragma mark Father Getter
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"";
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:16];
    }
    return _titleLabel;
}

- (UIButton *)lockScreenButton{
    if (!_lockScreenButton){
        _lockScreenButton = [[UIButton alloc] init];
        [_lockScreenButton setTitle:@"锁屏" forState:UIControlStateNormal];
        [_lockScreenButton addTarget:self action:@selector(lockSceenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_lockScreenButton setImage:[UIImage imageNamed:@"plv_skin_control_icon_unlock"] forState:UIControlStateNormal];
    }
    
    return _lockScreenButton;
}

- (UIButton *)playRateButton{
    if (!_playRateButton){
        _playRateButton = [[UIButton alloc] init];
        [_playRateButton setTitle:@"1.0 x" forState:UIControlStateNormal];
        _playRateButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_playRateButton addTarget:self action:@selector(playRateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _playRateButton;
}

- (UIButton *)qualityButton{
    if (!_qualityButton){
        _qualityButton = [[UIButton alloc] init];
        [_qualityButton setTitle:@"高清" forState:UIControlStateNormal];
        _qualityButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_qualityButton addTarget:self action:@selector(qualityButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _qualityButton;
}

#pragma mark button action
- (void)lockSceenButtonClick:(UIButton *)button{
    //
    if (self.fullSkinDelegate && [self.fullSkinDelegate respondsToSelector:@selector(mediaAreaLandscapeFullSkinView_LockSceenEvent:)]){
        [self.fullSkinDelegate mediaAreaLandscapeFullSkinView_LockSceenEvent:self];
    }
}

- (void)playRateButtonClick:(UIButton *)button{
    if (self.fullSkinDelegate && [self.fullSkinDelegate respondsToSelector:@selector(mediaAreaLandscapeFullSkinView_SwitchPlayRate:)]){
        [self.fullSkinDelegate mediaAreaLandscapeFullSkinView_SwitchPlayRate:self];
    }
}

- (void)qualityButtonClick:(UIButton *)button{
    if (self.fullSkinDelegate && [self.fullSkinDelegate respondsToSelector:@selector(mediaAreaLandscapeFullSkinView_SwitchQuality:)]){
        [self.fullSkinDelegate mediaAreaLandscapeFullSkinView_SwitchQuality:self];
    }
}

@end
