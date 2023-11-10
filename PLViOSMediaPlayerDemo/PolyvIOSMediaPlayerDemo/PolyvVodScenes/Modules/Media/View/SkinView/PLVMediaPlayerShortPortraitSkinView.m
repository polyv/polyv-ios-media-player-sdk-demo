//
//  PlVMediaPlayerShortHarfSkinView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/30.
//

#import "PLVMediaPlayerShortPortraitSkinView.h"

@implementation PLVMediaPlayerShortPortraitSkinView

#pragma mark - [ Life Period ]
- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (instancetype)initWithSkinType:(PLVMediaPlayerBaseSkinViewType)skinType{
    if (self = [super initWithSkinType:skinType]){
        //
        [self adapteUI];
    }
    
    return self;
}

- (void)adapteUI{
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

- (void)layoutSubviews{
    BOOL fullScreen = [UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height;

    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    
    CGFloat toppadding;
    if (@available(iOS 11.0, *)) {
        toppadding = self.safeAreaInsets.top;
    } else {
        toppadding = 20;
    }
    toppadding += 4; /// 顶部距离增加间隙值
            
    if (!fullScreen) {
        // 竖屏布局
        self.hidden = NO;
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
        self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.backButton.frame), CGRectGetMinY(self.backButton.frame), titleLabelWidth, commonHeight);
        
        [self refreshPlayTimesLabelFrame];
        [self refreshProgressViewFrame];
        
        CGFloat rightPadding = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 10.0 : 2.0;
        self.moreButton.frame = CGRectMake(viewWidth - rightPadding - backButtonSize.width, toppadding, backButtonSize.width, backButtonSize.height);
      
        // 底部UI
        CGFloat bottomShadowLayerHeight = 70.0;
        self.bottomShadowLayer.frame = CGRectMake(0, viewHeight - bottomShadowLayerHeight, viewWidth, bottomShadowLayerHeight);
        
        CGFloat timeLabelWidth = [self getLabelTextWidth:self.currentTimeLabel];
        self.currentTimeLabel.frame = CGRectMake(leftPadding + 12, viewHeight - bottomPadding - commonHeight, timeLabelWidth, commonHeight);
        
        self.diagonalsLabel.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLabel.frame), CGRectGetMinY(self.currentTimeLabel.frame), 5, commonHeight);
        
        timeLabelWidth = [self getLabelTextWidth:self.durationLabel];
        self.durationLabel.frame = CGRectMake(CGRectGetMaxX(self.diagonalsLabel.frame), CGRectGetMinY(self.currentTimeLabel.frame), timeLabelWidth, commonHeight);
        
        CGFloat progressSliderLeftRightPadding = 15;
        CGFloat progressSliderWidth = viewWidth - progressSliderLeftRightPadding - progressSliderLeftRightPadding;
        CGFloat progressHigh = 30;
        self.progressSlider.frame = CGRectMake(progressSliderLeftRightPadding , CGRectGetMinY(self.currentTimeLabel.frame) -progressHigh, progressSliderWidth, progressHigh);
   
        // 中间播放按钮
        self.playButton.center = self.center;
        self.playButton.bounds = CGRectMake(0, 0, 80, 80);
        
        // 全屏按钮
        self.fullScreenButton.frame = CGRectMake((viewWidth - 82)/2, CGRectGetMaxY(self.playButton.frame) + 90, 82, 28);
        
        // 自动隐藏皮肤
//        [self autoHideSkinView];
        
        // 隐藏背景
        self.topShadowLayer.hidden = YES;
        self.bottomShadowLayer.hidden = YES;
        
    }else{
        self.hidden = YES;
    }
}

- (void)refreshProgressViewFrame {
    CGFloat toppadding;
    if (@available(iOS 11.0, *)) {
        toppadding = self.safeAreaInsets.top;
    } else {
        toppadding = 20;
    }
    self.progressView.frame = CGRectMake(self.frame.size.width / 2 - 73.5, self.frame.size.height / 2 - 16, 147, 32);
}

- (void)refreshFloatViewShowButtonFrame {
    CGSize backButtonSize = CGSizeMake(40.0, 40.0);
    CGFloat originX = CGRectGetMinX(self.moreButton.frame);
    
    if (!self.fullScreenButton.hidden && self.fullScreenButton.superview) {
        originX = CGRectGetMinX(self.fullScreenButton.frame) - backButtonSize.width - 5;
    }
}

- (void)setPlayButtonWithPlaying:(BOOL)playing{
    if (playing){
        self.playButton.hidden = YES;
        self.playButton.selected = YES;
    }
    else{
//        self.playButton.hidden = NO;
        self.playButton.selected = NO;
    }
}


@end
