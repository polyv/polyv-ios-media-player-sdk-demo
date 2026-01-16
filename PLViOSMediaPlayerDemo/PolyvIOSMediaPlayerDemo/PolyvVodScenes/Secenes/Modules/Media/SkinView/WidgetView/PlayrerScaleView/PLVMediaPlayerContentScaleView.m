//
//  PLVMediaPlayerContentScaleView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created on 2026/1/8.
//

#import "PLVMediaPlayerContentScaleView.h"

@interface PLVMediaPlayerContentScaleView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;  /// 双指捏合手势
@property (nonatomic, assign) CGFloat currentScale;                    /// 当前缩放比例
@property (nonatomic, assign) CGFloat initialScale;                    /// 手势开始时的缩放比例
@property (nonatomic, assign) CGPoint currentTranslation;              /// 当前平移量
@property (nonatomic, assign) BOOL isTransforming;                     /// 是否正在变换中

@end

@implementation PLVMediaPlayerContentScaleView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)dealloc {
    [self resetZoom];
}

#pragma mark - Setup

- (void)setupView {
    self.backgroundColor = [UIColor blackColor];
    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
    
    // 初始化属性
    self.currentScale = 1.0;
    self.initialScale = 1.0;
    self.currentTranslation = CGPointZero;
    self.zoomEnabled = NO;
    self.isTransforming = NO;
    self.minScale = 0.5;
    self.maxScale = 3.0;
    
    // 添加手势
    [self setupGestures];
}

- (void)setupGestures {
    // 双指捏合手势
    self.pinchGesture = [[UIPinchGestureRecognizer alloc]
                         initWithTarget:self
                         action:@selector(handlePinchGesture:)];
    self.pinchGesture.delegate = self;
    [self addGestureRecognizer:self.pinchGesture];
}

/// 将手势添加到指定视图上（用于解决视图遮挡问题）
- (void)attachGesturesToView:(UIView *)view {
    if (!view) return;
    
    // 从当前视图移除手势
    if (self.pinchGesture && self.pinchGesture.view == self) {
        [self removeGestureRecognizer:self.pinchGesture];
    }
    
    // 添加到指定视图
    [view addGestureRecognizer:self.pinchGesture];
}

#pragma mark - Gesture Handlers

/// 处理双指捏合手势
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gesture {
    if (!self.zoomEnabled) return;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.isTransforming = YES;
        self.initialScale = self.currentScale;  // 记录手势开始时的缩放比例
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        // 基于初始缩放比例计算新的缩放值
        CGFloat newScale = self.initialScale * gesture.scale;
        newScale = MAX(self.minScale, MIN(self.maxScale, newScale));
        
        [self applyScale:newScale translation:self.currentTranslation];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateCancelled) {
        // 更新当前缩放比例
        self.currentScale = self.initialScale * gesture.scale;
        self.currentScale = MAX(self.minScale, MIN(self.maxScale, self.currentScale));
        
        [self notifyScaleChanged];
        self.isTransforming = NO;
    }
}

#pragma mark - Transform Methods

/// 应用缩放和平移变换
- (void)applyScale:(CGFloat)scale translation:(CGPoint)translation {
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DScale(transform, scale, scale, 1.0);
    transform = CATransform3DTranslate(transform,
                                       translation.x / scale,
                                       translation.y / scale,
                                       0);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.layer.transform = transform;
    [CATransaction commit];
}

/// 约束平移范围（防止画面移出边界过多）
- (CGPoint)constrainTranslation:(CGPoint)translation {
    if (self.currentScale <= self.minScale) return CGPointZero;
    
    CGSize viewSize = self.bounds.size;
    CGFloat scaledWidth = viewSize.width * self.currentScale;
    CGFloat scaledHeight = viewSize.height * self.currentScale;
    
    CGFloat maxX = (scaledWidth - viewSize.width) / 2.0;
    CGFloat maxY = (scaledHeight - viewSize.height) / 2.0;
    
    CGFloat constrainedX = MAX(-maxX, MIN(maxX, translation.x));
    CGFloat constrainedY = MAX(-maxY, MIN(maxY, translation.y));
    
    return CGPointMake(constrainedX, constrainedY);
}

#pragma mark - Public Methods

- (void)resetZoom {
    [self resetZoomWithAnimation:NO];
}

- (void)resetZoomWithAnimation:(BOOL)animated {
    self.isTransforming = NO;
    self.currentScale = 1.0;
    self.initialScale = 1.0;  // 重置初始缩放比例
    self.currentTranslation = CGPointZero;
    
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            [self applyScale:1.0 translation:CGPointZero];
        } completion:^(BOOL finished) {
            [self notifyScaleChanged];
        }];
    } else {
        [self applyScale:1.0 translation:CGPointZero];
        [self notifyScaleChanged];
    }
}

#pragma mark - Private Methods

- (void)notifyScaleChanged {
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerContentScaleView:didChangeScale:)]) {
        [self.delegate mediaPlayerContentScaleView:self didChangeScale:self.currentScale];
    }
}

#pragma mark - UIGestureRecognizerDelegate


/// 控制手势是否应该开始识别
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.zoomEnabled) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Override

- (void)setFrame:(CGRect)frame {
    // 如果正在变换中，不要修改 frame（frame 会清除 transform）
    if (!self.isTransforming) {
        [super setFrame:frame];
        
        // 重新应用变换
        if (self.currentScale > self.minScale) {
            [self applyScale:self.currentScale translation:self.currentTranslation];
        }
    }
}

@end
