//
//  PLVSlideTabView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/10/12.
//

#import "PLVSlideTabView.h"
#import "PLVFixedTabbarView.h"
#import "PLVSlideView.h"
#import "PLVSlideTabCache.h"

#define kDefaultTabbarHeight 34
#define kDefaultTabbarBottomSpacing 0
#define kDefaultCacheCount 4

@implementation PLVTabedbarItem
+ (PLVTabedbarItem *)itemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage{
    PLVTabedbarItem *item = [[PLVTabedbarItem alloc] init];
    item.title = title;
    item.image = image;
    item.selectedImage = selectedImage;
    
    return item;
}

@end

@interface PLVSlideTabView()<PLVSlideViewDelegate, PLVSlideViewDataSource>

@end


@implementation PLVSlideTabView{
    PLVSlideView *slideView_;
    PLVFixedTabbarView *tabbar_;
    PLVSlideTabCache *ctrlCache_;
}

- (void)commonInit{
    if(@available(iOS 13.0, *)) {
        self.backgroundColor = [UIColor tertiarySystemBackgroundColor];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    self.tabbarHeight = kDefaultTabbarHeight;
    self.tabbarBottomSpacing = kDefaultTabbarBottomSpacing;
    
    tabbar_ = [[PLVFixedTabbarView alloc] initWithFrame:CGRectMake(0, 0, /*self.bounds.size.width*/kDefaultFixedTabbarItemWidth*self.tabbarItems.count, self.tabbarHeight)];
    tabbar_.delegate = self;
    [self addSubview:tabbar_];
    
    slideView_ = [[PLVSlideView alloc] initWithFrame:CGRectMake(0, self.tabbarHeight+self.tabbarBottomSpacing, self.bounds.size.width, self.bounds.size.height-self.tabbarHeight-self.tabbarBottomSpacing)];
    slideView_.delegate = self;
    slideView_.dataSource = self;
    [self addSubview:slideView_];
    
    ctrlCache_ = [[PLVSlideTabCache alloc] initWithCount:4];
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

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self layoutBarAndSlide];
}

- (void)layoutBarAndSlide{
    UIView *barView = (UIView *)tabbar_;
    barView.frame = CGRectMake(0, 0, /*CGRectGetWidth(self.bounds)*/kDefaultFixedTabbarItemWidth*self.tabbarItems.count, self.tabbarHeight);
    slideView_.frame = CGRectMake(0, self.tabbarHeight+self.tabbarBottomSpacing, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)-self.tabbarHeight-self.tabbarBottomSpacing);

}

- (void)setBaseViewController:(UIViewController *)baseViewController{
    slideView_.baseViewController = baseViewController;
}

- (void)buildTabbar{
    NSMutableArray *tabbarItems = [NSMutableArray array];
    for (PLVTabedbarItem *item in self.tabbarItems) {
        PLVFixedTabbarViewTabItem *barItem = [[PLVFixedTabbarViewTabItem alloc] init];
        barItem.title = item.title;
        barItem.titleColor = self.tabItemNormalColor;
        barItem.selectedTitleColor = self.tabItemSelectedColor;
        barItem.tabItemNormalFontSize = self.tabItemNormalFontSize;
        barItem.tabItemSelectedFontSize = self.tabItemSelectedFontSize;
        barItem.image = item.image;
        barItem.selectedImage = item.selectedImage;
        
        [tabbarItems addObject:barItem];
    }
    
    tabbar_.tabbarItems = tabbarItems;
    tabbar_.trackColor = self.tabbarTrackColor;
    tabbar_.backgroundImage = self.tabbarBackgroundImage;

    [self layoutBarAndSlide];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    _selectedIndex = selectedIndex;
    [slideView_ setSelectedIndex:selectedIndex];
    [tabbar_ setSelectedIndex:selectedIndex];
}

- (void)setCanScroll:(BOOL)canScroll{
    [slideView_ setCanScroll:canScroll];
}

- (void)PLVSlideTabbar:(id)sender selectAt:(NSInteger)index{
    [slideView_ setSelectedIndex:index];
}

- (NSInteger)numberOfControllersInDLSlideView:(PLVSlideView *)sender{
    return [self.delegate numberOfTabsInPLVSlideTabView:self];
}

- (UIViewController *)PLVSlideView:(PLVSlideView *)sender controllerAt:(NSInteger)index{
    NSString *key = [NSString stringWithFormat:@"%ld", (long)index];
    if ([ctrlCache_ objectForKey:key]) {
        return [ctrlCache_ objectForKey:key];
    }
    else{
        UIViewController *ctrl = [self.delegate PLVSlideTabView:self controllerAt:index];
        [ctrlCache_ setObject:ctrl forKey:key];
        return ctrl;
    }
}

- (void)PLVSlideView:(PLVSlideView *)slide switchingFrom:(NSInteger)oldIndex to:(NSInteger)toIndex percent:(float)percent{
    [tabbar_ switchingFrom:oldIndex to:toIndex percent:percent];
}
- (void)PLVSlideView:(PLVSlideView *)slide didSwitchTo:(NSInteger)index{
    self.selectedIndex = index;

    [tabbar_ setSelectedIndex:index];
    if (self.delegate && [self.delegate respondsToSelector:@selector(PLVSlideTabView:didSelectedAt:)]) {
        [self.delegate PLVSlideTabView:self didSelectedAt:index];
    }
}
- (void)DLSlideView:(PLVSlideView *)slide switchCanceled:(NSInteger)oldIndex{
    [tabbar_ setSelectedIndex:oldIndex];
}


@end
