//
//  PlVMediaPlayerShortHarfSkinView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/30.
//

#import "PLVMediaAreaPortraitFullSkinView.h"
#import "PLVOrientationUtil.h"

@implementation PLVMediaAreaPortraitFullSkinView

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
    
    // 播放按钮
    [self addSubview:self.playButton];
    [self.playButton setImage:[UIImage imageNamed:@"plv_skin_control_icon_shortplay"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"plv_skin_control_icon_shortplay"] forState:UIControlStateSelected];
    // 默认隐藏
    self.playButton.hidden = YES;
    self.playButton.alpha = 0.5;
    
    // 全屏按钮
    [self.fullScreenButton setTitle:@"全屏观看" forState:UIControlStateNormal];
    [self.fullScreenButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
}


- (void)updateUI{
    if (self.isInited) {
        return;
    }
    if (CGRectGetWidth(self.bounds) == 0) {
        return;
    }
    
    self.isInited = YES;
    
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    
    CGFloat toppadding;
    if (@available(iOS 11.0, *)) {
        toppadding = self.safeAreaInsets.top;
    } else {
        toppadding = 20;
    }
    toppadding += 4; /// 顶部距离增加间隙值

    [self controlsSwitchShowStatusWithAnimation:YES];

    // 基础数据
    CGFloat leftPadding = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 10.0 : 2.0;
    CGFloat bottomPadding = 20.0;
    CGFloat commonHeight = 20.0;
    
    // 顶部UI
    CGFloat topShadowLayerHeight = 83.0;
    self.topShadowLayer.frame = CGRectMake(0, 0, viewWidth, topShadowLayerHeight);
    
    CGSize backButtonSize = CGSizeMake(40.0, 40.0);
    self.backButton.frame = CGRectMake(leftPadding, toppadding, backButtonSize.width, backButtonSize.height);
    self.backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 0);
            
    CGFloat titleLabelWidthScale = 200.0 / 375.0;
    CGFloat titleLabelWidth = viewWidth * titleLabelWidthScale;
    CGFloat titleLableX = self.backButton.hidden ? 15 : CGRectGetMaxX(self.backButton.frame);
    self.titleLabel.frame = CGRectMake(titleLableX, CGRectGetMinY(self.backButton.frame), titleLabelWidth, commonHeight);
    
    [self refreshProgressViewFrame];
    
    CGFloat rightPadding = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 10.0 : 2.0;
    self.moreButton.frame = CGRectMake(viewWidth - rightPadding - backButtonSize.width, toppadding, backButtonSize.width, backButtonSize.height);
  
    // 底部UI
    CGFloat bottomShadowLayerHeight = 70.0;
    self.bottomShadowLayer.frame = CGRectMake(0, viewHeight - bottomShadowLayerHeight, viewWidth, bottomShadowLayerHeight);
    
    // 播放进度 时间
    CGFloat timeLabelWidth = [self getLabelTextWidth:self.currentTimeLabel];
    self.currentTimeLabel.frame = CGRectMake(leftPadding + 12, viewHeight - bottomPadding - commonHeight, timeLabelWidth, commonHeight);
    
    self.diagonalsLabel.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLabel.frame), CGRectGetMinY(self.currentTimeLabel.frame), 5, commonHeight);
    
    timeLabelWidth = [self getLabelTextWidth:self.durationLabel];
    self.durationLabel.frame = CGRectMake(CGRectGetMaxX(self.diagonalsLabel.frame), CGRectGetMinY(self.currentTimeLabel.frame), timeLabelWidth, commonHeight);
    
    // 进度条
    CGFloat progressSliderLeftRightPadding = 15;
    CGFloat progressSliderWidth = viewWidth - progressSliderLeftRightPadding - progressSliderLeftRightPadding;
    CGFloat progressHigh = 30;
    self.progressSlider.frame = CGRectMake(progressSliderLeftRightPadding , CGRectGetMinY(self.currentTimeLabel.frame) -progressHigh, progressSliderWidth, progressHigh);

    // 中间播放按钮
    self.playButton.center = self.center;
    self.playButton.bounds = CGRectMake(0, 0, 80, 80);
    
    // 全屏按钮
    self.fullScreenButton.frame = CGRectMake((viewWidth - 82)/2, CGRectGetMaxY(self.playButton.frame) + 90, 82, 28);
        
    [self refreshProgressViewFrame];
    
    // 自动隐藏皮肤
//    [self autoHideSkinView];
    
    // 隐藏背景
    self.topShadowLayer.hidden = YES;
    self.bottomShadowLayer.hidden = YES;

}

- (void)refreshProgressViewFrame {
    // 预览视图
    self.progressPreviewView.frame = CGRectMake(self.frame.size.width / 2 - self.progressPreviewView.bounds.size.width / 2,
                                                self.progressSlider.frame.origin.y - self.progressPreviewView.bounds.size.height - 6,
                                                self.progressPreviewView.bounds.size.width,
                                                self.progressPreviewView.bounds.size.height);
}

- (void)refreshPlayTimesLabelFrame{
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    
    CGFloat toppadding;
    if (@available(iOS 11.0, *)) {
        toppadding = self.safeAreaInsets.top;
    } else {
        toppadding = 20;
    }
    toppadding += 4; /// 顶部距离增加间隙值

    // 基础数据
    CGFloat leftPadding = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 10.0 : 2.0;
    CGFloat bottomPadding = 20.0;
    CGFloat commonHeight = 20.0;
    CGFloat timeLabelWidth = [self getLabelTextWidth:self.currentTimeLabel];
    self.currentTimeLabel.frame = CGRectMake(leftPadding + 12, viewHeight - bottomPadding - commonHeight, timeLabelWidth, commonHeight);
    
    self.diagonalsLabel.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLabel.frame), CGRectGetMinY(self.currentTimeLabel.frame), 5, commonHeight);
    
    timeLabelWidth = [self getLabelTextWidth:self.durationLabel];
    self.durationLabel.frame = CGRectMake(CGRectGetMaxX(self.diagonalsLabel.frame), CGRectGetMinY(self.currentTimeLabel.frame), timeLabelWidth, commonHeight);
}

- (void)setPlayButtonWithPlaying:(BOOL)playing{
    if (playing){
        self.playButton.hidden = YES;
        self.playButton.selected = YES;
    }
    else{
        self.playButton.selected = NO;
    }
}


@end
