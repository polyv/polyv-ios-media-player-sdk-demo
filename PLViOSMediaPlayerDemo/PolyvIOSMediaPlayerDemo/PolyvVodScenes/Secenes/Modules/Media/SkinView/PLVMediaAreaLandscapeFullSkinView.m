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
@property (nonatomic, strong) UIButton *danmuSwitchButton;
@property (nonatomic, strong) UIButton *danmuEnterButton;

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
    [self addSubview:self.knowledgeButton];
    [self addSubview:self.danmuSwitchButton];
    [self addSubview:self.danmuEnterButton];
    [self addSubview:self.scaleResetButton];
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

    if (![PLVVodMediaFdUtil isiPhoneXSeries]) {
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

    // 底部UI
    CGFloat bottomShadowLayerHeight = 90.0;
    self.bottomShadowLayer.frame = CGRectMake(0, viewHeight - bottomShadowLayerHeight, viewWidth, bottomShadowLayerHeight);

    // 播放按钮
    CGFloat bottomPadding = 28.0;
    self.playButton.frame = CGRectMake(leftSafePadding, viewHeight - bottomPadding - backButtonSize.height, backButtonSize.width, backButtonSize.height);
    
    // 播放进度 时间
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
    
    // 底部按钮布局（从右到左）：知识点按钮 -> 清晰度 -> 倍速 -> 弹幕开关
    // 知识点按钮（最右侧，紧贴右边缘）
    CGFloat knowledgeButtonWidth = 60;
    point = CGPointMake(viewWidth - rightSafePadding - knowledgeButtonWidth, CGRectGetMinY(self.playButton.frame));
    self.knowledgeButton.frame = CGRectMake(point.x, point.y, knowledgeButtonWidth, 20);
    
    // 清晰度（知识点按钮左侧，如果知识点按钮隐藏则紧贴右边缘）
    CGFloat qualityX = self.knowledgeButton.hidden ? 
                       (viewWidth - rightSafePadding - 48) : 
                       (CGRectGetMinX(self.knowledgeButton.frame) - 10 - 48);
    point = CGPointMake(qualityX, CGRectGetMinY(self.playButton.frame));
    self.qualityButton.frame = CGRectMake(point.x, point.y, 48, 20);
    
    // 倍速（清晰度左侧）
    CGFloat playRateX = self.qualityButton.hidden ?
                        CGRectGetMinX(self.qualityButton.frame) :
                        (CGRectGetMinX(self.qualityButton.frame) - 10 - 48);
    self.playRateButton.frame = CGRectMake(playRateX, point.y, 48, 20);
    
    // 弹幕开关（倍速左侧）
    CGFloat danmuSwitchX = self.playRateButton.hidden ?
                           CGRectGetMinX(self.playRateButton.frame) :
                           (CGRectGetMinX(self.playRateButton.frame) - 10 - 48);
    self.danmuSwitchButton.frame = CGRectMake(danmuSwitchX, point.y, 48, 20);
    
    // 弹幕输入按钮（中间靠右边缘，垂直居中）
    CGFloat danmuEnterButtonWidth = 60;
    CGFloat danmuEnterButtonHeight = 30;
    CGFloat danmuEnterX = viewWidth - rightSafePadding - danmuEnterButtonWidth;
    CGFloat danmuEnterY = viewHeight / 2 - danmuEnterButtonHeight / 2;
    self.danmuEnterButton.frame = CGRectMake(danmuEnterX, danmuEnterY, danmuEnterButtonWidth, danmuEnterButtonHeight);
        
    // 锁屏按钮
    self.lockScreenButton.frame = CGRectMake(90, self.bounds.size.height/2 - 40/2, 40, 40);
    
    // 还原屏幕按钮（位于进度条上方60px，居中显示）
    CGFloat scaleResetButtonWidth = 80;
    CGFloat scaleResetButtonHeight = 32;
    CGFloat scaleResetButtonX = (viewWidth - scaleResetButtonWidth) / 2;
    CGFloat scaleResetButtonY = CGRectGetMinY(self.progressSlider.frame) - 60 - scaleResetButtonHeight;
    self.scaleResetButton.frame = CGRectMake(scaleResetButtonX, scaleResetButtonY, scaleResetButtonWidth, scaleResetButtonHeight);
    
    [self refreshProgressViewFrame];
   
    // 自动隐藏皮肤
    [self autoHideSkinView];

}

- (void)refreshPlayTimesLabelFrame{
    // 播放进度 时间
    CGFloat timeLabelWidth = [self getLabelTextWidth:self.currentTimeLabel];
    CGPoint point = CGPointMake(CGRectGetMaxX(self.playButton.frame), CGRectGetMinY(self.playButton.frame));
    self.currentTimeLabel.frame = CGRectMake(point.x, point.y, timeLabelWidth, 20);
    self.diagonalsLabel.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLabel.frame), CGRectGetMinY(self.currentTimeLabel.frame), 5, 20);
    timeLabelWidth = [self getLabelTextWidth:self.durationLabel];
    self.durationLabel.frame = CGRectMake(CGRectGetMaxX(self.diagonalsLabel.frame), CGRectGetMinY(self.currentTimeLabel.frame), timeLabelWidth, 20);
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
    NSString *rateString = [NSString stringWithFormat:@"%.2f", playRate];
    if ([rateString hasSuffix:@"00"]) {
        rateString = [rateString stringByReplacingOccurrencesOfString:@"00" withString:@"0" options:NSBackwardsSearch range:NSMakeRange(0, rateString.length)];
    }
    while ([rateString hasSuffix:@"0"] && ![rateString hasSuffix:@".0"]) {
        rateString = [rateString substringToIndex:rateString.length - 1];
    }
    NSString *title = [NSString stringWithFormat:@"%@ X", rateString];
    [self.playRateButton setTitle:title forState:UIControlStateNormal];
}

- (void)updateWithMediaPlayerState:(PLVMediaPlayerState *)playerState{
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    CGFloat rightSafePadding = 0;
    if (@available(iOS 11.0, *)) {
        rightSafePadding = self.safeAreaInsets.right;
    }
    BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    if (![PLVVodMediaFdUtil isiPhoneXSeries]) {
        rightSafePadding = 6;
    }
    if (isPad) {
        rightSafePadding = 20;
    }
    
    CGPoint point = CGPointMake(0, CGRectGetMinY(self.playButton.frame));
    
    // 底部按钮布局（从右到左）：知识点按钮 -> 清晰度 -> 倍速 -> 弹幕开关
    // 知识点按钮（最右侧）
    CGFloat knowledgeButtonWidth = 60;
    CGPoint knowledgePoint = CGPointMake(viewWidth - rightSafePadding - knowledgeButtonWidth, point.y);
    self.knowledgeButton.frame = CGRectMake(knowledgePoint.x, knowledgePoint.y, knowledgeButtonWidth, 20);

    // 视频模式
    if (PLVMediaPlayerPlayModeVideo == playerState.curPlayMode){
        // 清晰度
        CGFloat qualityX = self.knowledgeButton.hidden ? 
                           (viewWidth - rightSafePadding - 48) : 
                           (CGRectGetMinX(self.knowledgeButton.frame) - 10 - 48);
        self.qualityButton.frame = CGRectMake(qualityX, point.y, 48, 20);
        self.qualityButton.hidden = NO;
        
        // 倍速
        CGPoint ratePoint = CGPointMake(CGRectGetMinX(self.qualityButton.frame) - 10 - 48, point.y);
        self.playRateButton.frame = CGRectMake(ratePoint.x, ratePoint.y, 48, 20);
        
        // 弹幕开关（倍速左侧）
        CGFloat danmuSwitchX = CGRectGetMinX(self.playRateButton.frame) - 10 - 48;
        self.danmuSwitchButton.frame = CGRectMake(danmuSwitchX, point.y, 48, 20);
        self.danmuSwitchButton.hidden = NO;
    }
    else if (PLVMediaPlayerPlayModeAudio == playerState.curPlayMode){
        // 音频模式
        // 清晰度
        self.qualityButton.hidden = YES;
        
        // 倍速
        CGFloat rateX = self.knowledgeButton.hidden ? 
                        (viewWidth - rightSafePadding - 48) : 
                        (CGRectGetMinX(self.knowledgeButton.frame) - 10 - 48);
        CGPoint ratePoint = CGPointMake(rateX, point.y);
        self.playRateButton.frame = CGRectMake(ratePoint.x, ratePoint.y, 48, 20);
        
        // 弹幕开关（倍速左侧）
        CGFloat danmuSwitchX = CGRectGetMinX(self.playRateButton.frame) - 10 - 48;
        self.danmuSwitchButton.frame = CGRectMake(danmuSwitchX, point.y, 48, 20);
        self.danmuSwitchButton.hidden = NO;
    }
    
    // 弹幕输入按钮（中间靠右边缘，垂直居中）
    CGFloat danmuEnterButtonWidth = 60;
    CGFloat danmuEnterButtonHeight = 30;
    CGFloat danmuEnterX = viewWidth - rightSafePadding - danmuEnterButtonWidth;
    CGFloat danmuEnterY = viewHeight / 2 - danmuEnterButtonHeight / 2;
    self.danmuEnterButton.frame = CGRectMake(danmuEnterX, danmuEnterY, danmuEnterButtonWidth, danmuEnterButtonHeight);
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
    // 预览视图
    self.progressPreviewView.frame = CGRectMake(self.frame.size.width / 2 - self.progressPreviewView.bounds.size.width / 2,
                                                self.progressSlider.frame.origin.y - self.progressPreviewView.bounds.size.height - 6,
                                                self.progressPreviewView.bounds.size.width,
                                                self.progressPreviewView.bounds.size.height);
}

- (void)showFloatViewShowButtonTipsLabelAnimation:(BOOL)showTips{
    // 横屏不需要显示提示，仅重写覆盖即可
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

- (UIButton *)knowledgeButton{
    if (!_knowledgeButton){
        _knowledgeButton = [[UIButton alloc] init];
        [_knowledgeButton setTitle:@"知识点" forState:UIControlStateNormal];
        _knowledgeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_knowledgeButton addTarget:self action:@selector(knowledgeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _knowledgeButton.hidden = YES; // 默认隐藏
    }
    
    return _knowledgeButton;
}

- (UIButton *)danmuSwitchButton{
    if (!_danmuSwitchButton){
        _danmuSwitchButton = [[UIButton alloc] init];
        [_danmuSwitchButton setImage:[UIImage imageNamed:@"plv_skin_control_danmu_off"] forState:UIControlStateNormal];
        [_danmuSwitchButton setImage:[UIImage imageNamed:@"plv_skin_control_danmu_on"] forState:UIControlStateSelected];

        [_danmuSwitchButton addTarget:self action:@selector(danmuSwitchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _danmuSwitchButton.selected = self.enableDanmu;
    }
    
    return _danmuSwitchButton;
}

- (UIButton *)danmuEnterButton{
    if (!_danmuEnterButton){
        _danmuEnterButton = [[UIButton alloc] init];
        [_danmuEnterButton setTitle:@"弹幕" forState:UIControlStateNormal];
        _danmuEnterButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_danmuEnterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _danmuEnterButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        _danmuEnterButton.layer.cornerRadius = 15;
        _danmuEnterButton.layer.masksToBounds = YES;
        _danmuEnterButton.hidden = YES;
        [_danmuEnterButton addTarget:self action:@selector(danmuEnterButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _danmuEnterButton;
}

- (UIButton *)scaleResetButton{
    if (!_scaleResetButton){
        _scaleResetButton = [[UIButton alloc] init];
        [_scaleResetButton setTitle:@"还原" forState:UIControlStateNormal];
        _scaleResetButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_scaleResetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _scaleResetButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _scaleResetButton.layer.cornerRadius = 16;
        _scaleResetButton.layer.masksToBounds = YES;
        _scaleResetButton.layer.borderWidth = 1;
        _scaleResetButton.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor;
        _scaleResetButton.hidden = YES; // 默认隐藏
        [_scaleResetButton addTarget:self action:@selector(scaleResetButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _scaleResetButton;
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

- (void)knowledgeButtonClick:(UIButton *)button{
    if (self.fullSkinDelegate && [self.fullSkinDelegate respondsToSelector:@selector(mediaAreaLandscapeFullSkinView_KnowledgeButtonClick:)]){
        [self.fullSkinDelegate mediaAreaLandscapeFullSkinView_KnowledgeButtonClick:self];
    }
}

- (void)danmuSwitchButtonClick:(UIButton *)button{
    self.enableDanmu = !self.enableDanmu;
    button.selected = self.enableDanmu;
    if (self.fullSkinDelegate && [self.fullSkinDelegate respondsToSelector:@selector(mediaAreaLandscapeFullSkinView_DanmuSwitch:enable:)]){
        [self.fullSkinDelegate mediaAreaLandscapeFullSkinView_DanmuSwitch:self enable:self.enableDanmu];
    }
    
    // 弹幕入口按钮显示或隐藏
    self.danmuEnterButton.hidden = !self.enableDanmu;
}

- (void)danmuEnterButtonClick:(UIButton *)button{
    if (self.fullSkinDelegate && [self.fullSkinDelegate respondsToSelector:@selector(mediaAreaLandscapeFullSkinView_DanmuEnter:)]){
        [self.fullSkinDelegate mediaAreaLandscapeFullSkinView_DanmuEnter:self];
    }
}

- (void)scaleResetButtonClick:(UIButton *)button{
    if (self.fullSkinDelegate && [self.fullSkinDelegate respondsToSelector:@selector(mediaAreaLandscapeFullSkinView_ScaleResetButtonClick:)]){
        [self.fullSkinDelegate mediaAreaLandscapeFullSkinView_ScaleResetButtonClick:self];
    }
}

#pragma mark - [ Public Methods ]
- (void)updateKnowledgeButton:(BOOL)show title:(NSString *)title {
    self.knowledgeButton.hidden = !show;
    if (title.length > 0) {
        [self.knowledgeButton setTitle:title forState:UIControlStateNormal];
    }
    // 重新布局
    [self setNeedsLayout];
}

- (void)setEnableDanmu:(BOOL)enableDanmu {
    _enableDanmu = enableDanmu;
    self.danmuSwitchButton.selected = enableDanmu;
}

- (void)updateScaleResetButton:(BOOL)show {
    // 只有状态不同时才更新，避免闪烁
    if (self.scaleResetButton.hidden == !show) {
        return;
    }
    
    self.scaleResetButton.hidden = !show;
}


- (void)setShowDanmuSwitch:(BOOL)showDanmuSwitch{
    self.danmuSwitchButton.hidden = !showDanmuSwitch;
}


@end
