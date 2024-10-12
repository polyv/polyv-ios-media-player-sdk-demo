//
//  PLVCircularProgressView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/9/4.
//

#import "PLVCircularProgressView.h"
#import "PLVVodMediaCommonUtil.h"

@interface PLVCircularProgressView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation PLVCircularProgressView

- (instancetype)initWithFrame:(CGRect)frame andProgress:(CGFloat)progress {
    self = [super initWithFrame:frame];
    if (self) {
        _lineWidth = 3;
        _progress = progress;
        _trackColor = [PLVVodMediaCommonUtil colorFromHexString:@"#3F76FC" alpha:0.2];
        _progressColor = [PLVVodMediaCommonUtil colorFromHexString:@"#3F76FC" alpha:1.0];
        _textColor = [PLVVodMediaCommonUtil colorFromHexString:@"#333333" alpha:1.0];

        _fontSize = 8;
        [self setupViews];
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self updateUI];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    
    self.trackLayer = [CAShapeLayer layer];
    self.trackLayer.frame = self.bounds;
    self.progressLayer = [CAShapeLayer layer];
    self.progressLabel.frame = self.bounds;
    
    self.progressLabel = [[UILabel alloc] init];
    self.progressLabel.font = [UIFont systemFontOfSize:self.fontSize];
    
    self.trackLayer.strokeColor = self.trackColor.CGColor;
    self.trackLayer.fillColor = [UIColor clearColor].CGColor;
    
    self.progressLayer.strokeColor = self.progressColor.CGColor;
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.textColor = [UIColor blackColor];
    
    [self.layer addSublayer:self.trackLayer];
    [self.layer addSublayer:self.progressLayer];
    [self addSubview:self.progressLabel];
    
    [self configureLayout];
}

- (void)updateUI{
    [self configureLayout];
}

- (void)configureLayout {
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) / 2.0 - self.lineWidth;
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:-M_PI_2 endAngle:M_PI_2*3 clockwise:YES];
    
    self.trackLayer.path = path.CGPath;
    self.trackLayer.lineWidth = self.lineWidth;
    
    self.progressLayer.lineWidth = self.lineWidth;
    
    self.progressLabel.frame = CGRectMake(0, 0, self.bounds.size.width, 30);
    self.progressLabel.center = center;
}

#pragma mark [public]

- (void)setTextColor:(UIColor *)textColor{
    _textColor = textColor;
    self.progressLabel.textColor = textColor;
}

- (void)setProgress:(CGFloat)progress {
    _progress = MAX(0, MIN(1, progress));
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) / 2.0 - self.lineWidth;
        CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        
        CGFloat endAngle = -M_PI_2 + self.progress * M_PI * 2;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:-M_PI_2 endAngle:endAngle clockwise:YES];
        
        self.progressLayer.path = path.CGPath;
        
        self.progressLabel.text = [NSString stringWithFormat:@"%.0f%%", self.progress * 100];
    });
}


@end
