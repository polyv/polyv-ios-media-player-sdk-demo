//
//  PLVFixedTabbarView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/10/12.
//

#import "PLVFixedTabbarView.h"
#import "PLVSlideTabUtil.h"

#define kTrackViewHeight 2
#define kTrackViewWidth 20

#define kImageSpacingX 3.0f

#define kLabelTagBase 1000
#define kImageTagBase 2000
#define kSelectedImageTagBase 3000

@implementation PLVFixedTabbarViewTabItem

@end

@implementation PLVFixedTabbarView{
    UIScrollView *scrollView_;
    UIImageView *backgroudView_;
    UIImageView *trackView_;
}

- (void)commonInit{
    _selectedIndex = -1;
    
    backgroudView_ = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:backgroudView_];
    
    scrollView_ = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:scrollView_];
    
    trackView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-kTrackViewHeight-1, self.bounds.size.width, kTrackViewHeight)];
    [self addSubview:trackView_];
    trackView_.layer.cornerRadius = 2.0f;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [scrollView_ addGestureRecognizer:tap];
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

- (void)setBackgroundImage:(UIImage *)backgroundImage{
    backgroudView_.image = backgroundImage;
}

- (void)setTrackColor:(UIColor *)trackColor{
    trackView_.backgroundColor = trackColor;
}

- (void)setTabbarItems:(NSArray *)tabbarItems{
    if (_tabbarItems != tabbarItems) {
        for (UIView *subview in scrollView_.subviews){
            if ([subview isKindOfClass:[UILabel class]] || [subview isKindOfClass:[UIImageView class]]){
                [subview removeFromSuperview];
            }
        }
        
        _tabbarItems = tabbarItems;
        
        assert(tabbarItems.count <= 4);
        
        float width = kDefaultFixedTabbarItemWidth;
        float height = self.bounds.size.height;
        float x = 0.0f;
        NSInteger i=0;
        for (PLVFixedTabbarViewTabItem *item in tabbarItems) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, height)];
            label.text = item.title;
            label.font = [UIFont systemFontOfSize:item.tabItemNormalFontSize];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = item.titleColor;
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = kLabelTagBase+i;
            if (self.selectedIndex == i){
                label.font = [UIFont systemFontOfSize:item.tabItemSelectedFontSize];
                label.textColor = item.selectedTitleColor;
            }
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:item.image];
            [imageView sizeToFit];
            imageView.tag = kImageTagBase+i;
            
            UIImageView *selectedImageView = [[UIImageView alloc] initWithImage:item.selectedImage];
            [selectedImageView sizeToFit];
            selectedImageView.alpha = 0.0f;
            selectedImageView.tag = kSelectedImageTagBase+i;

            [scrollView_ addSubview:label];
            [scrollView_ addSubview:imageView];
            [scrollView_ addSubview:selectedImageView];
            i++;
        }
        
        [self layoutTabbar];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    backgroudView_.frame = self.bounds;
    scrollView_.frame = self.bounds;
    [self layoutTabbar];
}

- (void)layoutTabbar {
    float width = self.bounds.size.width/self.tabbarItems.count;
    float height = self.bounds.size.height;
    float x = 0.0f;
    for (NSInteger i=0; i<self.tabbarItems.count; i++) {
        x = i*width;
        UILabel *label = (UILabel *)[scrollView_ viewWithTag:kLabelTagBase+i];
        UIImageView *imageView = (UIImageView *)[scrollView_ viewWithTag:kImageTagBase+i];
        UIImageView *selectedIamgeView = (UIImageView *)[scrollView_ viewWithTag:kSelectedImageTagBase+i];
        label.frame = CGRectMake(x + (width-label.bounds.size.width-CGRectGetWidth(imageView.bounds))/2.0f, (height-label.bounds.size.height)/2.0f, CGRectGetWidth(label.bounds), CGRectGetHeight(label.bounds));
        imageView.frame = CGRectMake(label.frame.origin.x + label.bounds.size.width+kImageSpacingX, (height-imageView.bounds.size.height)/2.0, CGRectGetWidth(imageView.bounds), CGRectGetHeight(imageView.bounds));
        selectedIamgeView.frame = imageView.frame;
    }
    
    float trackX = width*self.selectedIndex;
    trackX = trackX + (width - kTrackViewWidth)/2;
//    trackView_.frame = CGRectMake(trackX, self.bounds.size.height-kTrackViewHeight-1, width, kTrackViewHeight);
    trackView_.frame = CGRectMake(trackX, self.bounds.size.height-kTrackViewHeight-1, kTrackViewWidth, kTrackViewHeight);

}

- (NSInteger)tabbarCount{
    return self.tabbarItems.count;
}

- (void)switchingFrom:(NSInteger)fromIndex to:(NSInteger)toIndex percent:(float)percent{
    PLVFixedTabbarViewTabItem *fromItem = [self.tabbarItems objectAtIndex:fromIndex];
    UILabel *fromLabel = (UILabel *)[scrollView_ viewWithTag:kLabelTagBase+fromIndex];
    UIImageView *fromIamge = (UIImageView *)[scrollView_ viewWithTag:kImageTagBase+fromIndex];
    UIImageView *fromSelectedIamge = (UIImageView *)[scrollView_ viewWithTag:kSelectedImageTagBase+fromIndex];
    fromLabel.textColor = [PLVSlideTabUtil getColorOfPercent:percent between:fromItem.titleColor and:fromItem.selectedTitleColor];
    fromIamge.alpha = percent;
    fromSelectedIamge.alpha = (1-percent);

    if (toIndex >= 0 && toIndex < [self tabbarCount]) {
        PLVFixedTabbarViewTabItem *toItem = [self.tabbarItems objectAtIndex:toIndex];
        UILabel *toLabel = (UILabel *)[scrollView_ viewWithTag:kLabelTagBase+toIndex];
        UIImageView *toIamge = (UIImageView *)[scrollView_ viewWithTag:kImageTagBase+toIndex];
        UIImageView *toSelectedIamge = (UIImageView *)[scrollView_ viewWithTag:kSelectedImageTagBase+toIndex];
        toLabel.textColor = [PLVSlideTabUtil getColorOfPercent:percent between:toItem.selectedTitleColor and:toItem.titleColor];
        toIamge.alpha = (1-percent);
        toSelectedIamge.alpha = percent;
    }
    
    float width = self.bounds.size.width/self.tabbarItems.count;
    float trackX;
    if (toIndex > fromIndex) {
        trackX = width*fromIndex + width*percent;
    }
    else{
        trackX = width*fromIndex - width*percent;
    }

    trackX = trackX + (width - kTrackViewWidth)/2;
    trackView_.frame = CGRectMake(trackX, trackView_.frame.origin.y, CGRectGetWidth(trackView_.bounds), CGRectGetHeight(trackView_.bounds));

}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    if (!self.tabbarItems.count) return;
    
    if (_selectedIndex != selectedIndex) {
        if (_selectedIndex >= 0) {
            PLVFixedTabbarViewTabItem *fromItem = [self.tabbarItems objectAtIndex:_selectedIndex];
            UILabel *fromLabel = (UILabel *)[scrollView_ viewWithTag:kLabelTagBase+_selectedIndex];
            UIImageView *fromIamge = (UIImageView *)[scrollView_ viewWithTag:kImageTagBase+_selectedIndex];
            UIImageView *fromSelectedIamge = (UIImageView *)[scrollView_ viewWithTag:kSelectedImageTagBase+_selectedIndex];
            fromLabel.textColor = fromItem.titleColor;
            fromLabel.font = [UIFont systemFontOfSize:fromItem.tabItemNormalFontSize];
            fromIamge.alpha = 1.0f;
            fromSelectedIamge.alpha = 0.0f;
        }
        
        if (selectedIndex >= 0 && selectedIndex < [self tabbarCount]) {
            PLVFixedTabbarViewTabItem *toItem = [self.tabbarItems objectAtIndex:selectedIndex];
            UILabel *toLabel = (UILabel *)[scrollView_ viewWithTag:kLabelTagBase+selectedIndex];
            UIImageView *toIamge = (UIImageView *)[scrollView_ viewWithTag:kImageTagBase+selectedIndex];
            UIImageView *toSelectedIamge = (UIImageView *)[scrollView_ viewWithTag:kSelectedImageTagBase+selectedIndex];
            toLabel.textColor = toItem.selectedTitleColor;
            toLabel.font = [UIFont systemFontOfSize:toItem.tabItemSelectedFontSize];

            toIamge.alpha = 0.0f;
            toSelectedIamge.alpha = 1.0f;
        }
        
        float width = self.bounds.size.width/self.tabbarItems.count;
        float trackX = width*selectedIndex;
        trackX = trackX + (width - kTrackViewWidth)/2;
        trackView_.frame = CGRectMake(trackX, trackView_.frame.origin.y, CGRectGetWidth(trackView_.bounds), CGRectGetHeight(trackView_.bounds));

        _selectedIndex = selectedIndex;
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tap{
    float width = self.bounds.size.width/self.tabbarItems.count;

    CGPoint point = [tap locationInView:scrollView_];
    NSInteger i = point.x/width;
    self.selectedIndex = i;
    if (self.delegate) {
        [self.delegate PLVSlideTabbar:self selectAt:i];
    }
}

@end
