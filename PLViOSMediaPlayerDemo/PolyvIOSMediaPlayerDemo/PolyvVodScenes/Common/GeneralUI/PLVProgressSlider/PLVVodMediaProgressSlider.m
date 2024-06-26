//
//  PLVVodMediaProgressSlider.m
//  PLVLiveScenesDemo
//
//  Created by Lincal on 2020/11/11.
//  Copyright © 2020 PLV. All rights reserved.
//

#import "PLVVodMediaProgressSlider.h"

@interface PLVVodMediaProgressSlider ()

#pragma mark 状态
@property (nonatomic, assign) BOOL sliderDragging; /// slider 是否处于拖动中 (YES:正在被拖动；NO:未被拖动)

#pragma mark UI
/// view hierarchy
///
/// (PLVVodMediaProgressSlider) self
/// ├── (UIProgressView) progressView
/// └── (UISlider) slider
@property (nonatomic, strong) UIProgressView * progressView; /// 进度条
@property (nonatomic, strong) UISlider * slider; /// 滑杆条
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureSlider; // 进度条点击事件

@end

@implementation PLVVodMediaProgressSlider

#pragma mark - [ Life Period ]
- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews{
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.bounds);

    CGFloat progressViewHeight = 2.5;
    CGFloat progressViewY = (viewHeight - progressViewHeight) / 2.0;
    CGFloat progressViewX = 3.0;
    CGFloat progressViewWidth = viewWidth - progressViewX * 2;
    self.progressView.frame = CGRectMake(progressViewX, progressViewY, progressViewWidth, progressViewHeight);
    
    self.slider.frame = self.bounds;
    CGFloat midY =  ceilf(CGRectGetMidY(self.slider.frame));
    self.progressView.center = CGPointMake(CGRectGetMidX(self.progressView.frame), midY);
}


#pragma mark - [ Public Methods ]
- (void)setProgressWithCachedProgress:(CGFloat)cachedProgress playedProgress:(CGFloat)playedProgress{
    if (!self.sliderDragging) {
        self.progressView.progress = cachedProgress;
        self.slider.value = playedProgress;
    }
}


#pragma mark - [ Private Methods ]
- (void)setupUI{
    [self addSubview:self.progressView];
    [self addSubview:self.slider];
    
    self.tapGestureSlider = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:self.tapGestureSlider];
}


#pragma mark Getter
- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressViewStyle = UIProgressViewStyleBar;
        _progressView.progress = 0;
        _progressView.progressTintColor = [UIColor colorWithWhite:1 alpha:0.5];
        _progressView.trackTintColor = [UIColor colorWithWhite:1 alpha:0.3];
        _progressView.layer.cornerRadius = 1.5;
        _progressView.clipsToBounds = YES;
    }
    return _progressView;
}

- (UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.maximumTrackTintColor = [UIColor clearColor];
        [_slider addTarget:self action:@selector(sliderTouchDownAction:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDownRepeat | UIControlEventTouchDragInside | UIControlEventTouchDragOutside | UIControlEventTouchDragEnter | UIControlEventTouchDragExit];
        [_slider addTarget:self action:@selector(sliderTouchEndAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
        [_slider addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

#pragma mark - [ Event ]
#pragma mark Action
- (IBAction)sliderTouchDownAction:(UISlider *)sender {
    self.sliderDragging = YES;
}

- (IBAction)sliderTouchEndAction:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(PLVVodMediaProgressSlider:sliderDragEnd:)]) {
        [self.delegate PLVVodMediaProgressSlider:self sliderDragEnd:self.slider.value];
    }
    self.sliderDragging = NO;
    self.tapGestureSlider.enabled = YES;
}

- (IBAction)sliderValueChangedAction:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(PLVVodMediaProgressSlider:sliderDragingProgressChange:)]) {
        [self.delegate PLVVodMediaProgressSlider:self sliderDragingProgressChange:self.slider.value];
    }
    self.tapGestureSlider.enabled = NO;
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap{
    //
    CGPoint point = [tap locationInView:self];
    
    CGFloat value = (self.slider.maximumValue - self.slider.minimumValue) * (point.x / self.slider.frame.size.width);
    self.slider.value = value;
    [self.slider sendActionsForControlEvents:UIControlEventValueChanged];
    [self.slider sendActionsForControlEvents:UIControlEventTouchUpInside];
}
@end
