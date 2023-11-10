//
//  PLVMediaPlayerSkinView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/30.
//

#import "PLVMediaPlayerPortraitSkinView.h"

@implementation PLVMediaPlayerPortraitSkinView

#pragma mark - [ Life Period ]
- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
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
                        
        CGFloat timeLabelWidth = [self getLabelTextWidth:self.currentTimeLabel];
        self.currentTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame) + 10, CGRectGetMinY(self.playButton.frame), timeLabelWidth, commonHeight);
        
        self.diagonalsLabel.frame = CGRectMake(CGRectGetMaxX(self.currentTimeLabel.frame), CGRectGetMinY(self.currentTimeLabel.frame), 5, commonHeight);
        
        timeLabelWidth = [self getLabelTextWidth:self.durationLabel];
        self.durationLabel.frame = CGRectMake(CGRectGetMaxX(self.diagonalsLabel.frame), CGRectGetMinY(self.currentTimeLabel.frame), timeLabelWidth, commonHeight);
        
        leftPadding = 15;
        rightPadding = 10;
        CGFloat progressHigh = 20;
        CGRect progressRect = CGRectMake(leftPadding, CGRectGetMinY(self.playButton.frame) - 12 -progressHigh, viewWidth - leftPadding - rightPadding, progressHigh);
        self.progressSlider.frame = progressRect;
   
        // 自动隐藏皮肤
        [self autoHideSkinView];
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

@end
