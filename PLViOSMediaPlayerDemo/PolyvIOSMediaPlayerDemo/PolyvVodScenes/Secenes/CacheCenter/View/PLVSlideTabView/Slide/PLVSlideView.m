//
//  PLVSlideView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/10/12.
//

#import "PLVSlideView.h"

#define kPanSwitchOffsetThreshold 50.0f

@implementation PLVSlideView{
    NSInteger oldIndex_;
    NSInteger panToIndex_;
    UIPanGestureRecognizer *pan_;
    CGPoint panStartPoint_;
    
    UIViewController *oldCtrl_;
    UIViewController *willCtrl_;
    
    BOOL isSwitching_;
}

- (void)commonInit{
    oldIndex_ = -1;
    isSwitching_ = NO;
    
    pan_ = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    [self addGestureRecognizer:pan_];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (NSInteger)selectedIndex{
    return oldIndex_;
}
- (void)setSelectedIndex:(NSInteger)selectedIndex{
    if (selectedIndex != oldIndex_) {
        [self switchTo:selectedIndex];
    }
}

- (void)setCanScroll:(BOOL)canScroll{
    pan_.enabled = canScroll;
}

//- (void)setViewControllers:(NSArray *)vcs{
//    _viewControllers = vcs;
//}

- (void)removeOld{
    [self removeCtrl:oldCtrl_];
    [oldCtrl_ endAppearanceTransition];
    oldCtrl_ = nil;
    oldIndex_ = -1;
}
- (void)removeWill{
    [willCtrl_ beginAppearanceTransition:NO animated:NO];
    [self removeCtrl:willCtrl_];
    [willCtrl_ endAppearanceTransition];
    willCtrl_ = nil;
    panToIndex_ = -1;
}
- (void)showAt:(NSInteger)index{
    if (oldIndex_ != index) {
        //[self removeAt:oldIndex_];
        [self removeOld];
        
        UIViewController *vc = [self.dataSource PLVSlideView:self controllerAt:index];
        [self.baseViewController addChildViewController:vc];
        vc.view.frame = self.bounds;
        [self addSubview:vc.view];
        [vc didMoveToParentViewController:self.baseViewController];
        oldIndex_ = index;
        oldCtrl_ = vc;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(PLVSlideView:didSwitchTo:)]) {
            [self.delegate PLVSlideView:self didSwitchTo:index];
        }
    }
}

- (void)removeCtrl:(UIViewController *)ctrl{
    UIViewController *vc = ctrl;
    [vc willMoveToParentViewController:nil];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
}

//- (void)removeAt:(int)index{
//    if (oldIndex_ == index) {
//        oldIndex_ = -1;
//    }
//
//    if (index >= 0 && index <= [self.dataSource numberOfControllersInDLSlideView:self]) {
//        UIViewController *vc = [self.dataSource DLSlideView:self controllerAt:index];
//        [vc willMoveToParentViewController:nil];
//        [vc.view removeFromSuperview];
//        [vc removeFromParentViewController];
//    }
//}
- (void)switchTo:(NSInteger)index{
    if (index == oldIndex_) {
        return;
    }
    if (isSwitching_) {
        return;
    }

    if (oldCtrl_ != nil && oldCtrl_.parentViewController == self.baseViewController) {
        isSwitching_ = YES;
        //UIViewController *oldvc = [self.dataSource DLSlideView:self controllerAt:oldIndex_];;
        UIViewController *oldvc = oldCtrl_;
        UIViewController *newvc = [self.dataSource PLVSlideView:self controllerAt:index];
        
        [oldvc willMoveToParentViewController:nil];
        [self.baseViewController addChildViewController:newvc];
        
        CGRect nowRect = oldvc.view.frame;
        CGRect leftRect = CGRectMake(nowRect.origin.x-nowRect.size.width, nowRect.origin.y, nowRect.size.width, nowRect.size.height);
        CGRect rightRect = CGRectMake(nowRect.origin.x+nowRect.size.width, nowRect.origin.y, nowRect.size.width, nowRect.size.height);
        
        CGRect newStartRect;
        CGRect oldEndRect;
        if (index > oldIndex_) {
            newStartRect = rightRect;
            oldEndRect = leftRect;
        }
        else{
            newStartRect = leftRect;
            oldEndRect = rightRect;
        }
        
        newvc.view.frame = newStartRect;
        [newvc willMoveToParentViewController:self.baseViewController];
        
        [self.baseViewController transitionFromViewController:oldvc toViewController:newvc duration:0.4 options:0 animations:^{
            newvc.view.frame = nowRect;
            oldvc.view.frame = oldEndRect;
        } completion:^(BOOL finished) {
            [oldvc removeFromParentViewController];
            [newvc didMoveToParentViewController:self.baseViewController];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(PLVSlideView:didSwitchTo:)]) {
                [self.delegate PLVSlideView:self didSwitchTo:index];
            }
            
            self->isSwitching_ = NO;
        }];
        
        oldIndex_ = index;
        oldCtrl_ = newvc;
    }
    else{
        [self showAt:index];
    }
    
    willCtrl_ = nil;
    panToIndex_ = -1;
}

- (void)repositionForOffsetX:(CGFloat)offsetx{
    float x = 0.0f;
    
    if (panToIndex_ < oldIndex_) {
        x = self.bounds.origin.x - self.bounds.size.width + offsetx;
    }
    else if(panToIndex_ > oldIndex_){
        x = self.bounds.origin.x + self.bounds.size.width + offsetx;
    }
    
    //UIViewController *oldvc = [self.dataSource DLSlideView:self controllerAt:oldIndex_];
    UIViewController *oldvc = oldCtrl_;
    oldvc.view.frame = CGRectMake(self.bounds.origin.x + offsetx, self.bounds.origin.y, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    if (panToIndex_ >= 0 && panToIndex_ < [self.dataSource numberOfControllersInDLSlideView:self]) {
        //UIViewController *vc = [self.dataSource DLSlideView:self controllerAt:panToIndex_];
        UIViewController *vc = willCtrl_;
        vc.view.frame = CGRectMake(x, self.bounds.origin.y, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
//        if (vc.parentViewController == nil) {
//
//            [self.baseViewController addChildViewController:vc];
//            [vc willMoveToParentViewController:self.baseViewController];
//            [vc beginAppearanceTransition:YES animated:YES];
//            [self addSubview:vc.view];
//            //[vc didMoveToParentViewController:self.baseViewController];
//        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(PLVSlideView:switchingFrom:to:percent:)]) {
        [self.delegate PLVSlideView:self switchingFrom:oldIndex_ to:panToIndex_ percent:fabs(offsetx)/self.bounds.size.width];
    }
}

- (void)backToOldWithOffset:(CGFloat)offsetx{
    NSTimeInterval animatedTime = 0;
    animatedTime = 0.3;
    
    //animatedTime = fabs(self.frame.size.width - fabs(offsetx)) / self.frame.size.width * 0.35;
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView animateWithDuration:animatedTime animations:^{
        [self repositionForOffsetX:0];
    } completion:^(BOOL finished) {
        if (self->panToIndex_ >= 0 && self->panToIndex_ < [self.dataSource numberOfControllersInDLSlideView:self] && self->panToIndex_ != self->oldIndex_) {
            //[self removeAt:panToIndex_];
            [self->oldCtrl_ beginAppearanceTransition:YES animated:NO];
            [self removeWill];
            [self->oldCtrl_ endAppearanceTransition];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(PLVSlideView:switchCanceled:)]) {
            [self.delegate PLVSlideView:self switchCanceled:self->oldIndex_];
        }
    }];
    
}

- (void)panHandler:(UIPanGestureRecognizer *)pan{
    if (oldIndex_ < 0) {
        return;
    }
    
    CGPoint point = [pan translationInView:self];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self panGestureBegan:point];
    } else if (pan.state == UIGestureRecognizerStateChanged){
        [self panGestureChanged:point];
    } else if (pan.state == UIGestureRecognizerStateEnded){
        [self panGestureEnded:point];
    }
}

- (void)panGestureBegan:(CGPoint)point {
    panStartPoint_ = point;
    [oldCtrl_ beginAppearanceTransition:NO animated:YES];
}

- (void)panGestureChanged:(CGPoint)point {
    NSInteger panToIndex = -1;
    float offsetx = point.x - panStartPoint_.x;
    
    if (offsetx > 0) {
        panToIndex = oldIndex_ - 1;
    } else if(offsetx < 0) {
        panToIndex = oldIndex_ + 1;
    }
    
    if (panToIndex != panToIndex_ && willCtrl_) {
        [self removeWill];
    }
    
    if (panToIndex < 0 || panToIndex >= [self.dataSource numberOfControllersInDLSlideView:self]) {
        panToIndex_ = panToIndex;
        [self repositionForOffsetX:offsetx/2.0f];
    } else {
        if (panToIndex != panToIndex_) {
            willCtrl_ = [self.dataSource PLVSlideView:self controllerAt:panToIndex];
            [self.baseViewController addChildViewController:willCtrl_];
            [willCtrl_ willMoveToParentViewController:self.baseViewController];
            [willCtrl_ beginAppearanceTransition:YES animated:YES];
            [self addSubview:willCtrl_.view];
            
            panToIndex_ = panToIndex;
        }
        [self repositionForOffsetX:offsetx];
    }
}

- (void)panGestureEnded:(CGPoint)point {
    float offsetx = point.x - panStartPoint_.x;
    
    if (panToIndex_ >= 0 &&
        panToIndex_ < [self.dataSource numberOfControllersInDLSlideView:self] &&
        panToIndex_ != oldIndex_ &&
        fabs(offsetx) > kPanSwitchOffsetThreshold) {
        NSTimeInterval animatedTime = 0;
        animatedTime = fabs(self.frame.size.width - fabs(offsetx)) / self.frame.size.width * 0.4;
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView animateWithDuration:animatedTime animations:^{
            [self repositionForOffsetX:offsetx > 0 ? self.bounds.size.width : -self.bounds.size.width];
        } completion:^(BOOL finished) {
            //[self removeAt:oldIndex_];
            [self removeOld];
            
            if (self->panToIndex_ >= 0 && self->panToIndex_ < [self.dataSource numberOfControllersInDLSlideView:self]) {
                [self->willCtrl_ endAppearanceTransition];
                [self->willCtrl_ didMoveToParentViewController:self.baseViewController];
                self->oldIndex_ = self->panToIndex_;
                self->oldCtrl_ = self->willCtrl_;
                self->willCtrl_ = nil;
                self->panToIndex_ = -1;
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(PLVSlideView:didSwitchTo:)]) {
                [self.delegate PLVSlideView:self didSwitchTo:self->oldIndex_];
            }
        }];
    } else{
        [self backToOldWithOffset:offsetx];
    }
}

@end
