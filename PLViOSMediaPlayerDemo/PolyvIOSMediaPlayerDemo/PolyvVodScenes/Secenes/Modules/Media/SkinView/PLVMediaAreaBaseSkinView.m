//
//  PLVMediaPlayerBaseSkinView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/8/30.
//

#import "PLVMediaAreaBaseSkinView.h"
#import <MediaPlayer/MPVolumeView.h>
#import "PLVMediaBrightnessView.h"

#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

typedef NS_ENUM(NSInteger, PLVMediaPlayerBaseSkinViewPanType) {
    PLVBasePlayerSkinViewTypeAdjustVolume     = 1, //在屏幕左边，上下滑动调节声音
    PLVBasePlayerSkinViewTypeAdjustBrightness = 2, //在屏幕右边，上下滑动调节亮度
    PLVBasePlayerSKinViewTyoeAdjusttProgress  = 3  //在屏幕中间，左右滑动调节进度
};

@interface PLVMediaAreaBaseSkinView ()<
PLVProgressSliderDelegate,
UIGestureRecognizerDelegate
>

@property (nonatomic, assign) PLVMediaAreaBaseSkinViewType skinViewType;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) PLVMediaPlayerBaseSkinViewPanType panType;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, assign) BOOL moreButtonOriginalStatus;

@property (nonatomic, assign) NSTimeInterval currentPlaybackTime; // 当前播放时间戳
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval scrubTime;

@end

@implementation PLVMediaAreaBaseSkinView

#pragma mark 【Life Cycle】
- (instancetype)initWithSkinType:(PLVMediaAreaBaseSkinViewType)skinType{
    if (self = [self init]){
        self.skinViewType = skinType;
        
        [self setupData];
        [self setupUI];
    }
    
    return self;
}

- (instancetype)init {
    if (self = [super initWithFrame:CGRectZero]) {
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

- (void)layoutSubviews{
    // 布局逻辑，由子类去实现(因不同子类的布局逻辑存在较大差异)
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    for (UIView * subview in self.subviews) {
        if (subview.hidden != YES && subview.alpha > 0 && subview.userInteractionEnabled && CGRectContainsPoint(subview.frame, point)) {
            return YES;
        }
    }
    
    BOOL otherViewHandler = NO;
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(plvMediaAreaBaseSkinView:askHandlerForTouchPointOnSkinView:)]) {
        otherViewHandler = [self.baseDelegate plvMediaAreaBaseSkinView:self askHandlerForTouchPointOnSkinView:point];
    }
    return !otherViewHandler;
}

#pragma mark 【Public Methods】
- (void)setupUI{
    // 添加 手势识别
    // 单击 手势识别
    UITapGestureRecognizer *singleGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    singleGestureRecognizer.numberOfTapsRequired = 1;
    singleGestureRecognizer.numberOfTouchesRequired = 1;
    [singleGestureRecognizer addTarget:self action:@selector(tapGestureAction:)];
    self.tapGR = singleGestureRecognizer;
    [self addGestureRecognizer:self.tapGR];
    
    // 双击 手势识别
    UITapGestureRecognizer *doubleGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    doubleGestureRecognizer.numberOfTapsRequired = 2;
    doubleGestureRecognizer.numberOfTouchesRequired = 1;
    [doubleGestureRecognizer addTarget:self action:@selector(tapGestureAction:)];
    self.doubleTapGR = doubleGestureRecognizer;
    self.doubleTapGR.delegate = self;
    [self addGestureRecognizer:self.doubleTapGR];
    
    // 拖拽 手势识别
    if (self.skinViewType==PLVMediaAreaBaseSkinViewType_Portrait_Half
        || self.skinViewType==PLVMediaAreaBaseSkinViewType_Landscape_Full) {
        self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        [self addGestureRecognizer:self.panGR];
    }
    
    // 长按 手势识别
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    [self addGestureRecognizer:longPress];
    
    
    // 添加 视图
    // 注意：懒加载过程中(即Getter)已增加判断，若场景不匹配，将创建失败并返回nil
    UIView * controlsSuperview = self;
    [controlsSuperview.layer addSublayer:self.topShadowLayer];
    [controlsSuperview addSubview:self.backButton];
    [controlsSuperview addSubview:self.titleLabel];
    [controlsSuperview addSubview:self.moreButton];

    [controlsSuperview.layer addSublayer:self.bottomShadowLayer];
    [controlsSuperview addSubview:self.playButton];
    [controlsSuperview addSubview:self.fullScreenButton];
    
    /// 底部UI
    [controlsSuperview addSubview:self.currentTimeLabel];
    [controlsSuperview addSubview:self.diagonalsLabel];
    [controlsSuperview addSubview:self.durationLabel];
    [controlsSuperview addSubview:self.progressSlider];
    [controlsSuperview addSubview:self.progressPreviewView];
    
    [controlsSuperview bringSubviewToFront:self.backButton];
}

- (CGFloat)getLabelTextWidth:(UILabel *)label {
    CGFloat minWidth = 38;
    CGFloat resultWidth = minWidth;
    if (label) {
        resultWidth = [label.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 1)
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes:@{NSFontAttributeName:label.font}
                                               context:nil].size.width + 5;
        if (resultWidth < minWidth) {
            resultWidth = minWidth;
        }
    }
    
    return resultWidth;
}

- (void)setTitleLabelWithText:(NSString *)titleText{
    if ([PLVVodFdUtil checkStringUseable:titleText]) {
        if (titleText.length > 12 && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            titleText = [NSString stringWithFormat:@"%@...", [titleText substringToIndex:12]];
        }
        self.titleLabel.text = titleText;
    }else{
        NSLog(@"PLVLCBasePlayerSkinView[%@] - setTitleLabelWithText failed, titleText:%@",NSStringFromClass(self.class),titleText);
    }
}

- (void)setPlayButtonWithPlaying:(BOOL)playing{
    self.playButton.selected = playing;
    if (self.playButton.selected) {
        [self.playButton setImage:[UIImage imageNamed:@"plv_skin_control_icon_pause"] forState:UIControlStateSelected | UIControlStateHighlighted];
    }else{
        [self.playButton setImage:[UIImage imageNamed:@"plv_skin_control_icon_play"] forState:UIControlStateHighlighted];
    }
}

- (void)showFloatViewShowButtonTipsLabelAnimation:(BOOL)showTips{
    NSLog(@"PLVLCBasePlayerSkinView[%@] - showFloatViewShowButtonTipsLabelAnimation failed, the method was not overridden by subclass",NSStringFromClass(self.class));
}

- (void)setProgressWithCachedProgress:(CGFloat)cachedProgress
                       playedProgress:(CGFloat)playedProgress
                         durationTime:(NSTimeInterval)durationTime
                    currentTimeString:(NSString *)currentTimeString
                       durationString:(NSString *)durationString{
    [self.progressSlider setProgressWithCachedProgress:cachedProgress playedProgress:playedProgress];
    self.progressSlider.userInteractionEnabled = (durationTime > 0 ? YES : NO);
    
    BOOL needUpdate = NO;
    if (self.currentTimeLabel.text.length !=  currentTimeString.length) {
//        [self setNeedsLayout];
        needUpdate = YES;
    }
    self.currentTimeLabel.text = [PLVVodFdUtil checkStringUseable:currentTimeString] ? currentTimeString : @"00:00";
    self.currentPlaybackTime = [PLVVodFdUtil secondsToTimeInterval:self.currentTimeLabel.text];
    if (![self.durationLabel.text isEqualToString:durationString]) {
        self.durationLabel.text = [PLVVodFdUtil checkStringUseable:durationString] ? durationString : @"00:00";
        needUpdate = YES;
//        [self setNeedsLayout];
    }
    self.duration = [PLVVodFdUtil secondsToTimeInterval:self.durationLabel.text];
    
    // 更新布局
    if (needUpdate) {
        [self refreshPlayTimesLabelFrame];
    }
}

- (void)setProgressLabelWithCurrentTime:(NSTimeInterval)currentTime durationTime:(NSTimeInterval)durationTime {
    [self.progressPreviewView updateProgressTime:currentTime];
}

- (void)refreshPlayTimesLabelFrame{
    NSLog(@"PLVLCBasePlayerSkinView[%@] - refreshPlayTimesLabelFrame failed, the method was not overridden by subclass",NSStringFromClass(self.class));
}

- (void)refreshProgressViewFrame {
    NSLog(@"PLVLCBasePlayerSkinView[%@] - refreshProgressViewFrame failed, the method was not overridden by subclass",NSStringFromClass(self.class));
}

/// 刷新更多按钮显示
/// @param hidden YES:隐藏，NO:恢复原来状态
- (void)refreshMoreButtonHiddenOrRestore:(BOOL)hidden {
    if (hidden) {
        self.moreButtonOriginalStatus = self.moreButton.hidden;
        self.moreButton.hidden = YES;
    }else {
        self.moreButton.hidden = self.moreButtonOriginalStatus;
    }
}

- (void)autoHideSkinView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(controlsSwitchHideStatus) object:nil];
    [self performSelector:@selector(controlsSwitchHideStatus) withObject:nil afterDelay:2.5];
}

+ (BOOL)checkView:(UIView *)otherView canBeHandlerForTouchPoint:(CGPoint)point onSkinView:(PLVMediaAreaBaseSkinView *)skinView{
    BOOL otherViewCanBeHandler = NO;
    if (otherView.hidden != YES && otherView.alpha > 0 && otherView.userInteractionEnabled) {
        CGPoint convertPoint = [skinView convertPoint:point toView:otherView.superview];
        otherViewCanBeHandler = CGRectContainsPoint(otherView.frame, convertPoint);
    }
    return otherViewCanBeHandler;
}

#pragma mark 【Animation】
- (void)controlsSwitchShowStatusWithAnimation:(BOOL)showStatus{
    if (self.isSkinShowing == showStatus) {
        NSLog(@"PLVLCBasePlayerSkinView[%@] - controlsSwitchShowAnimationWithShow failed , state is same",NSStringFromClass(self.class));
        return;
    }
    
    self.isSkinShowing = showStatus;
    CGFloat alpha = self.isSkinShowing ? 1.0 : 0.0;
    __weak typeof(self) weakSelf = self;
    void (^animationBlock)(void) = ^{
        weakSelf.topShadowLayer.opacity = alpha;
        weakSelf.bottomShadowLayer.opacity = alpha;
        for (UIView * subview in weakSelf.subviews) {
            if ([subview isKindOfClass:PLVMediaProgressPreviewView.class]) {
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

#pragma mark 【Getter & Setter】
- (CAGradientLayer *)topShadowLayer{
    if (!_topShadowLayer) {
        _topShadowLayer = [CAGradientLayer layer];
        _topShadowLayer.startPoint = CGPointMake(0.5, 1);
        _topShadowLayer.endPoint = CGPointMake(0.5, 0);
        _topShadowLayer.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6].CGColor];
        _topShadowLayer.locations = @[@(0.0), @(1.0f)];
    }
    return _topShadowLayer;
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"plv_skin_control_icon_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"";
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
    }
    return _titleLabel;
}

- (UIButton *)moreButton{
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton setImage:[UIImage imageNamed:@"plv_skin_control_icon_more"] forState:UIControlStateNormal];
        [_moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.moreButtonOriginalStatus = _moreButton.hidden;
    }
    return _moreButton;
}

- (CAGradientLayer *)bottomShadowLayer{
    if (!_bottomShadowLayer) {
        _bottomShadowLayer = [CAGradientLayer layer];
        _bottomShadowLayer.startPoint = CGPointMake(0.5, 0);
        _bottomShadowLayer.endPoint = CGPointMake(0.5, 1);
        _bottomShadowLayer.colors = @[(__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6].CGColor];
        _bottomShadowLayer.locations = @[@(0), @(1.0f)];
    }
    return _bottomShadowLayer;
}

- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"plv_skin_control_icon_play"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"plv_skin_control_icon_pause"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIButton *)fullScreenButton{
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:@"plv_skin_control_icon_fullscreen"] forState:UIControlStateNormal];
        [_fullScreenButton setImage:[UIImage imageNamed:@"plv_skin_control_icon_fullscreen"] forState:UIControlStateSelected];
        [_fullScreenButton addTarget:self action:@selector(fullScreenButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        // iPad时隐藏全屏按钮
        _fullScreenButton.hidden = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? YES : NO;
    }
    return _fullScreenButton;
}

- (UILabel *)currentTimeLabel{
    if (!_currentTimeLabel ) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.text = @"00:00";
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
    }
    return _currentTimeLabel;
}

- (UILabel *)diagonalsLabel{
    if (!_diagonalsLabel) {
        _diagonalsLabel = [[UILabel alloc] init];
        _diagonalsLabel.text = @"/";
        _diagonalsLabel.textAlignment = NSTextAlignmentCenter;
        _diagonalsLabel.textColor = [UIColor whiteColor];
        _diagonalsLabel.font = [UIFont fontWithName:@"PingFang SC" size:10];
    }
    return _diagonalsLabel;
}

- (UILabel *)durationLabel{
    if (!_durationLabel ) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.text = @"00:00";
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
    }
    return _durationLabel;
}

- (PLVProgressSlider *)progressSlider{
    if (!_progressSlider ) {
        _progressSlider = [[PLVProgressSlider alloc] init];
        _progressSlider.delegate = self;
        _progressSlider.userInteractionEnabled = YES;
        _progressSlider.slider.minimumTrackTintColor = PLV_UIColorFromRGB(@"6DA7FF");
        [_progressSlider.slider setThumbImage:[UIImage imageNamed:@"plv_skin_control_slider_thumbnail_default"] forState:UIControlStateNormal];
        [_progressSlider.slider setThumbImage:[UIImage imageNamed:@"plv_skin_control_slider_thumbnail_highlight"] forState:UIControlStateHighlighted];
    }
    return _progressSlider;
}

- (PLVMediaProgressPreviewView *)progressPreviewView {
    if (!_progressPreviewView ) {
        _progressPreviewView = [[PLVMediaProgressPreviewView alloc] init];
        _progressPreviewView.hidden = YES;
    }
    return _progressPreviewView;
}

- (void)setIsSkinShowing:(BOOL)skinShow{
    BOOL didChanged = (_isSkinShowing != skinShow);
    _isSkinShowing = skinShow;
    if (didChanged) {
        if ([self.baseDelegate respondsToSelector:@selector(plvMediaAreaBaseSkinView:didChangedSkinShowStatus:)]) {
            [self.baseDelegate plvMediaAreaBaseSkinView:self didChangedSkinShowStatus:_isSkinShowing];
        }
    }
}

#pragma mark 【Private Methods】
- (void)setupData{
    self.isSkinShowing = YES;
    self.currentPlaybackTime = 0;
    self.duration = 0;
    self.scrubTime = 0;
}

#pragma mark 【Gesture Methods】
- (void)controlMedia:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:self];
    CGPoint velocty = [gestureRecognizer velocityInView:self];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.lastPoint = p;
        if (fabs(velocty.x) <= fabs(velocty.y)) { //在屏幕右边，上下滑动调整声音
            if (self.lastPoint.x > self.bounds.size.width * 0.5) {
                self.panType = PLVBasePlayerSkinViewTypeAdjustVolume;
            } else {//在屏幕左边，上下滑动调整亮度
                self.panType = PLVBasePlayerSkinViewTypeAdjustBrightness;
                [PLVMediaBrightnessView sharedBrightnessView];
            }
        } else {
            self.panType = PLVBasePlayerSKinViewTyoeAdjusttProgress;
            self.scrubTime = self.currentPlaybackTime;
            [self setProgressLabelWithCurrentTime:self.currentPlaybackTime durationTime:self.duration];
            [self showProgressView:YES];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged
               || gestureRecognizer.state == UIGestureRecognizerStateEnded
               || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        switch (self.panType) {
            case PLVBasePlayerSkinViewTypeAdjustVolume: {
                CGFloat dy = self.lastPoint.y - p.y;
                [self changeVolume:dy];
                break;
            }
            case PLVBasePlayerSkinViewTypeAdjustBrightness: {
                CGFloat dy = self.lastPoint.y - p.y;
                [UIScreen mainScreen].brightness = [self valueOfDistance:dy baseValue:[UIScreen mainScreen].brightness];
                break;
            }
            case PLVBasePlayerSKinViewTyoeAdjusttProgress: {
                if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
                    self.scrubTime += velocty.x / 200;
                    if (self.scrubTime > self.duration) {
                        self.scrubTime = self.duration;
                    }
                    if (self.scrubTime < 0) {
                        self.scrubTime = 0;
                    }
                    [self setProgressLabelWithCurrentTime:self.scrubTime durationTime:self.duration];
                } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
                    self.currentPlaybackTime = self.scrubTime;
                    if([self.baseDelegate respondsToSelector:@selector(plvMediaAreaBaseSkinViewProgressViewPaned:scrubTime:)]){
                        [self.baseDelegate plvMediaAreaBaseSkinViewProgressViewPaned:self scrubTime:self.scrubTime];
                    }
                    self.scrubTime = 0;
                    [self showProgressView:NO];
                }
            }
            default:
                break;
        }
        self.lastPoint = p;
    }
}

- (CGFloat)valueOfDistance:(CGFloat)distance baseValue:(CGFloat)baseValue {
    CGFloat value = baseValue + distance / 300.0f;
    if (value < 0.0) {
        value = 0.0;
    } else if (value > 1.0) {
        value = 1.0;
    }
    return value;
}

- (void)changeVolume:(CGFloat)distance {
    if (self.volumeView == nil) {
        self.volumeView = [[MPVolumeView alloc] init];
        self.volumeView.showsVolumeSlider = YES;
        [self addSubview:self.volumeView];
        [self.volumeView sizeToFit];
        self.volumeView.hidden = YES;
    }
    for (UIView *v in self.volumeView.subviews) {
        if ([v.class.description isEqualToString:@"MPVolumeSlider"]) {
            UISlider *volumeSlider = (UISlider *)v;
            [volumeSlider setValue:[self valueOfDistance:distance baseValue:volumeSlider.value] animated:NO];
            [volumeSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        }
    }
}

- (void)showProgressView:(BOOL)show {
    self.progressPreviewView.hidden = show ? NO : YES;
}

- (void)controlsSwitchHideStatus {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (!self.hidden && self.isSkinShowing) {
        [self controlsSwitchShowStatusWithAnimation:NO];
    }
}

#pragma mark 【Action】
- (void)tapGestureAction:(UITapGestureRecognizer *)tapGR {
    if (tapGR.numberOfTapsRequired == 2 && tapGR.numberOfTouchesRequired == 1) {
        if (self.skinViewType == PLVMediaAreaBaseSkinViewType_Portrait_Full){
            // 短视频-竖屏，不响应双击事件
            return;
        }
        BOOL wannaPlay = !self.playButton.selected;

        if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(plvMediaAreaBaseSkinViewPlayButtonClicked:wannaPlay:)]) {
            [self.baseDelegate plvMediaAreaBaseSkinViewPlayButtonClicked:self wannaPlay:wannaPlay];
        }
        if (!self.isSkinShowing) {
            [self controlsSwitchShowStatusWithAnimation:!self.isSkinShowing];
        }
    } else if (tapGR.numberOfTapsRequired == 1 && tapGR.numberOfTouchesRequired == 1) {
        if (self.skinViewType == PLVMediaAreaBaseSkinViewType_Portrait_Full){
            // 短视频皮肤 1)隐藏、显示播放按钮 2)模拟播放事件
            [self playButtonAction:self.playButton];

        } else {
            [self controlsSwitchShowStatusWithAnimation:!self.isSkinShowing];
        }
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)panGR {
    [self controlMedia:panGR];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state == UIGestureRecognizerStateCancelled || longPress.state == UIGestureRecognizerStateEnded) {
        if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(plvMediaAreaBaseSkinView:longPressGestureStart:)]){
            [self.baseDelegate plvMediaAreaBaseSkinView:self longPressGestureEnd:longPress];
        }
        return;
    }
    
    if (longPress.state == UIGestureRecognizerStateBegan || longPress.state == UIGestureRecognizerStateChanged) {
        if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(plvMediaAreaBaseSkinView:longPressGestureEnd:)]){
            [self.baseDelegate plvMediaAreaBaseSkinView:self longPressGestureStart:longPress];
        }
        return;
    }
}

- (void)backButtonAction:(UIButton *)button{
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(plvMediaAreaBaseSkinViewBackButtonClicked:)]) {
        [self.baseDelegate plvMediaAreaBaseSkinViewBackButtonClicked:self];
    }
}

- (void)pictureInPictureButtonAction:(UIButton *)button{
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(plvMediaAreaBaseSkinViewPictureInPictureButtonClicked:)]) {
        [self.baseDelegate plvMediaAreaBaseSkinViewPictureInPictureButtonClicked:self];
    }
}

- (void)moreButtonAction:(UIButton *)button{
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(plvMediaAreaBaseSkinViewMoreButtonClicked:)]) {
        [self.baseDelegate plvMediaAreaBaseSkinViewMoreButtonClicked:self];
    }
}

- (void)playButtonAction:(UIButton *)button{
    BOOL wannaPlay = !button.selected;
    button.selected = wannaPlay;
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(plvMediaAreaBaseSkinViewPlayButtonClicked:wannaPlay:)]) {
        [self.baseDelegate plvMediaAreaBaseSkinViewPlayButtonClicked:self wannaPlay:wannaPlay];
    }
    
    if (self.skinViewType == PLVMediaAreaBaseSkinViewType_Portrait_Full){
        button.hidden = wannaPlay;
    }
}

- (void)fullScreenButtonAction:(UIButton *)button{
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(plvMediaAreaBaseSkinViewFullScreenOpenButtonClicked:)]) {
        [self.baseDelegate plvMediaAreaBaseSkinViewFullScreenOpenButtonClicked:self];
    }
}

#pragma mark 【Delegate】
- (void)plvProgressSlider:(PLVProgressSlider *)progressSlider sliderDragEnd:(CGFloat)currentSliderProgress{
    self.progressPreviewView.hidden = YES;
    
    if ([self.baseDelegate respondsToSelector:@selector(plvMediaAreaBaseSkinView:sliderDragEnd:)]){
        [self.baseDelegate plvMediaAreaBaseSkinView:self sliderDragEnd:currentSliderProgress];
    }
}

/// 进度连续变化
- (void)plvProgressSlider:(PLVProgressSlider *)progressSlider sliderDragingProgressChange:(CGFloat)currentSliderProgress{
    NSTimeInterval progressTime = self.duration * currentSliderProgress;
    [self.progressPreviewView updateProgressTime:progressTime];
    self.progressPreviewView.hidden = NO;
}

#pragma mark 【UIGestureRecognizerDelegate】

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Fix player exception pause when touch subview button
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UIButton"]) {
        return NO;
    }
    return YES;
}

@end
