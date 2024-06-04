//
//  PLVMediaPlayerSkinView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/30.
//

#import "PLVMediaAreaPortraitHalfSkinView.h"
#import "PLVVodMediaOrientationUtil.h"

@implementation PLVMediaAreaPortraitHalfSkinView

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
            
    // 竖屏布局
    self.hidden = NO;
    [self controlsSwitchShowStatusWithAnimation:YES];

    // 基础数据
    CGFloat leftPadding = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 10.0 : 2.0;
    CGFloat bottomPadding = 12.0;
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
            
    CGFloat rightPadding = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? 10.0 : 2.0;
    self.moreButton.frame = CGRectMake(viewWidth - rightPadding - backButtonSize.width, toppadding, backButtonSize.width, backButtonSize.height);
           
    // 底部UI
    CGFloat bottomShadowLayerHeight = 70.0;
    self.bottomShadowLayer.frame = CGRectMake(0, viewHeight - bottomShadowLayerHeight, viewWidth, bottomShadowLayerHeight);
            
    self.playButton.frame = CGRectMake(leftPadding, viewHeight - bottomPadding - commonHeight, backButtonSize.width, commonHeight);
            
    self.fullScreenButton.frame = CGRectMake(CGRectGetMinX(self.moreButton.frame), CGRectGetMinY(self.playButton.frame), backButtonSize.width, commonHeight);
                    
    // 播放进度 时间
    CGFloat timeLabelWidth = [self getLabelTextWidth:self.currentTimeLabel];
    self.currentTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame) + 10, CGRectGetMinY(self.playButton.frame), timeLabelWidth, commonHeight);
    
    self.diagonalsLabel.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLabel.frame), CGRectGetMinY(self.currentTimeLabel.frame), 5, commonHeight);
    
    timeLabelWidth = [self getLabelTextWidth:self.durationLabel];
    self.durationLabel.frame = CGRectMake(CGRectGetMaxX(self.diagonalsLabel.frame), CGRectGetMinY(self.currentTimeLabel.frame), timeLabelWidth, commonHeight);
    
    // 进度条
    leftPadding = 15;
    rightPadding = 10;
    CGFloat progressHigh = 20;
    CGRect progressRect = CGRectMake(leftPadding, CGRectGetMinY(self.playButton.frame) - 12 -progressHigh, viewWidth - leftPadding - rightPadding, progressHigh);
    self.progressSlider.frame = progressRect;

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


- (void)refreshProgressViewFrame {
    // 预览视图
    self.progressPreviewView.frame = CGRectMake(self.frame.size.width / 2 - self.progressPreviewView.bounds.size.width / 2,
                                                self.progressSlider.frame.origin.y - self.progressPreviewView.bounds.size.height - 6,
                                                self.progressPreviewView.bounds.size.width,
                                                self.progressPreviewView.bounds.size.height);
}

#pragma mark [PUBLIC METHOD]
- (void)hiddenMediaPlayerPortraitHalSkinView:(BOOL)isHidden {
    [self controlsSwitchShowStatusWithAnimation:!isHidden];
}

@end
