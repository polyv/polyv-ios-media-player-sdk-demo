//
//  PLVMediaPlayerSkinDefinitionTipsView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by Dhan on 2024/1/4.
//

#import "PLVMediaPlayerSkinDefinitionTipsView.h"
#import "UIImage+Tint.h"

#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

@interface PLVMediaPlayerSkinDefinitionTipsView ()<UITextViewDelegate>

/// 是否正在展示
@property (nonatomic, assign) BOOL isShowing;

@property (nonatomic, assign) PLVVodQuality switchQuality;

@property (nonatomic, strong) UITextView *tipTextView;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIView *bubbleView;

@property (nonatomic, assign) CGFloat tipWidth;

@property (nonatomic, assign) CGPoint targetPoint;

@property (nonatomic, assign) BOOL above;

@property (nonatomic, assign) PLVMediaPlayerState *mediaState;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@end

@implementation PLVMediaPlayerSkinDefinitionTipsView

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self updateUIWithTargetPoint:self.targetPoint abovePoint:self.above];
}

#pragma mark - Initialize

- (void)initUI {
    self.backgroundColor = [UIColor clearColor];
    self.hidden = YES;
    [self addSubview:self.bubbleView];
    [self.bubbleView addSubview:self.tipTextView];
    [self.bubbleView addSubview:self.closeButton];
}


#pragma mark - Public

- (void)updateUIWithTargetPoint:(CGPoint)targetPoint abovePoint:(BOOL)above {
    self.targetPoint = targetPoint;
    self.above = above;
    
    /// 气泡各组件左右边距
    CGFloat xPadding = 16;
    /// 文本相对气泡的上下边距
    CGFloat textYPadding = 12;
    
    CGFloat bubbleWidth = self.tipWidth + 3 * xPadding + 12;
    CGFloat bubbleHeight = 52;
    CGFloat bubbleOriginX = self.targetPoint.x + 22 - bubbleWidth;
    CGFloat bubbleOriginY = 0;
    
    
    if (!above) {
        bubbleOriginY = self.targetPoint.y;
        self.bubbleView.frame = CGRectMake(bubbleOriginX, bubbleOriginY, bubbleWidth, bubbleHeight);
        self.tipTextView.frame = CGRectMake(xPadding, 8 + textYPadding, self.tipWidth, 20);
        
    } else {
        bubbleOriginY = self.targetPoint.y - bubbleHeight;
        self.bubbleView.frame = CGRectMake(bubbleOriginX, bubbleOriginY, bubbleWidth, bubbleHeight);
        self.tipTextView.frame = CGRectMake(xPadding, textYPadding, self.tipWidth, 20);
    }
    
    if (_shapeLayer.superlayer) {
        [_shapeLayer removeFromSuperlayer];
        _shapeLayer = nil;
    }
    CGFloat midX = bubbleWidth - 18;
    CGFloat maxY = CGRectGetHeight(self.bubbleView.frame);
    
    UIBezierPath *maskPath = above ? [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, CGRectGetWidth(self.bubbleView.frame), CGRectGetHeight(self.bubbleView.frame) - 8) cornerRadius:8] : [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 8, CGRectGetWidth(self.bubbleView.frame), CGRectGetHeight(self.bubbleView.frame) - 8) cornerRadius:8]  ;
    // triangle
    /*
    if (above) {
        [maskPath moveToPoint:CGPointMake(midX,maxY)];
        [maskPath addLineToPoint:CGPointMake(midX - 8, maxY - 8)];
        [maskPath addLineToPoint:CGPointMake(midX + 8, maxY - 8)];
        [maskPath closePath];
    } else {
        [maskPath moveToPoint:CGPointMake(midX,0)];
        [maskPath addLineToPoint:CGPointMake(midX-8, 8)];
        [maskPath addLineToPoint:CGPointMake(midX+8, 8)];
        [maskPath closePath];
    }
     */
    [maskPath closePath];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.frame = self.bounds;
    shapeLayer.fillColor = UIColor.blackColor.CGColor;
    shapeLayer.path = maskPath.CGPath;
    _shapeLayer = shapeLayer;
    [self.bubbleView.layer insertSublayer:_shapeLayer atIndex:0];
    
    
    self.closeButton.frame = CGRectMake(CGRectGetMaxX(self.tipTextView.frame) + 10, CGRectGetMidY(self.tipTextView.frame) - 8, 16, 16);
}

- (void)showSwitchQualityWithModel:(PLVMediaPlayerState *)mediaState targetPoint:(CGPoint)targetPoint abovePoint:(BOOL)above {
    BOOL showChangeString = mediaState.qualityCount > 1 && (mediaState.curQualityLevel - 1) > 0;
    
    self.switchQuality = showChangeString ? (mediaState.curQualityLevel - 1) : mediaState.curQualityLevel;
    
    NSString *qualityString = @"";
    if (showChangeString) {
        if (self.switchQuality == PLVVodQualityStandard) {
            qualityString = @"切换到流畅";
        }else if (self.switchQuality == PLVVodQualityHigh) {
            qualityString = @"切换到高清";
        }else if (self.switchQuality == PLVVodQualityUltra) {
            qualityString = @"切换到超清";
        }
    }
    
    NSString *tipContentString;
    if (self.customPoorNetworkTips  && self.customPoorNetworkTips.length > 0 && [self.customPoorNetworkTips isKindOfClass:NSString.class] ) {
        tipContentString = [NSString stringWithFormat:@"%@%@", self.customPoorNetworkTips, qualityString];
    } else {
        tipContentString = showChangeString ?[NSString stringWithFormat:@"您的网络环境较差，可尝试%@", qualityString] : @"当前网络信号弱，请耐心等待或更换网络";
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tipContentString attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0],
                                                     NSForegroundColorAttributeName:[UIColor whiteColor]}];
    if (qualityString && qualityString.length > 0 && [qualityString isKindOfClass:NSString.class]) {
        [attributedString addAttribute:NSLinkAttributeName value:@"switchQuality://" range:[tipContentString rangeOfString:qualityString]];
    }
    self.tipTextView.attributedText = attributedString;
    self.tipWidth = [attributedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
    
    [self updateUIWithTargetPoint:targetPoint abovePoint:above];
    
    self.isShowing = YES;
    self.hidden = NO;
}

- (void)updateUI {
    self.tipTextView.frame = CGRectMake(self.bounds.size.width - self.tipWidth - 20, self.bounds.size.height - 100, self.tipWidth, 20);
}

- (void)hide {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isShowing = NO;
        self.hidden = YES;
    });
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction{
    if ([URL.scheme isEqualToString:@"switchQuality"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerSkinDefinitionTipsView_SwitchQuality:)]) {
            [self.delegate mediaPlayerSkinDefinitionTipsView_SwitchQuality:self.switchQuality];
        }
        [self hide];
        return NO;
    }
    return YES;
}

#pragma mark - Loadlazy
- (UITextView *)tipTextView {
    if (!_tipTextView) {
        _tipTextView = [[UITextView alloc]init];
        _tipTextView.editable = NO;
        _tipTextView.delegate = self;
        _tipTextView.backgroundColor = [UIColor clearColor];
        _tipTextView.textContainer.lineFragmentPadding = 0.0;
        _tipTextView.textContainerInset = UIEdgeInsetsMake(2, 0, 0, 0);
        UIColor *linkColor = [UIColor colorWithRed:19/255.0 green:126/255.0 blue:188/255.0 alpha:1];
        _tipTextView.linkTextAttributes = @{NSForegroundColorAttributeName:linkColor};
    }
    return _tipTextView;
}

- (UIView *)bubbleView {
    if (!_bubbleView) {
        _bubbleView = [[UIView alloc]init];
        _bubbleView.backgroundColor = [UIColor clearColor];
    }
    return _bubbleView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc]init];
        UIImage *origImg = [UIImage imageNamed:@"plv_skin_menu_icon_close"];
        [_closeButton setImage:[origImg imageWithCustomTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self.closeButton || hitView == self.tipTextView) {
        return  hitView;
    }
    return nil;
}

@end
