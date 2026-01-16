//
//  PLVMediaKnowledgeSlideTabbarView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2026/1/4.
//

#import "PLVMediaKnowledgeSlideTabbarView.h"
#import <PolyvMediaPlayerSDK/PLVVodMediaColorUtil.h>

@interface PLVMediaKnowledgeSlideTabbarView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollContentView;
@property (nonatomic, strong) UIView *indexView;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, copy) NSMutableArray<UIButton *> *itemButtonArray;
@property (nonatomic, copy) NSMutableArray *itemTitleWidthArray;

@end

@implementation PLVMediaKnowledgeSlideTabbarView

#pragma mark - Init & UI

- (instancetype)init
{
    if (self = [super init]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [PLVVodMediaColorUtil colorFromHexString:@"#222326"];
    [self addSubview:self.closeButton];
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.scrollContentView];
    [self.scrollContentView addSubview:self.indexView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.bounds);
    CGFloat closeButtonWidth = 55;
    
    // closeButton 布局
    self.closeButton.frame = CGRectMake(viewWidth - closeButtonWidth, 0, closeButtonWidth, viewHeight);
    
    // scrollView 布局
    CGFloat scrollViewWidth = viewWidth - closeButtonWidth;
    self.scrollView.frame = CGRectMake(0, 0, scrollViewWidth, viewHeight);
    
    // scrollContentView 布局（高度与 scrollView 相同，宽度根据内容计算）
    CGFloat contentHeight = viewHeight;
    CGFloat contentWidth = MAX(scrollViewWidth, [self calculateContentWidth]);
    self.scrollContentView.frame = CGRectMake(0, 0, contentWidth, contentHeight);
    self.scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
    
    // 更新按钮和 indexView 的位置
    [self layoutTabbarItems];
    [self updateIndexViewFrame];
}

- (CGFloat)calculateContentWidth {
    CGFloat itemPadding = 20;
    CGFloat itemMarginLeft = 12;
    CGFloat totalWidth = itemMarginLeft;
    
    for (NSNumber *widthNumber in self.itemTitleWidthArray) {
        CGFloat titleWidth = [widthNumber floatValue];
        CGFloat itemWidth = titleWidth + 2 * itemPadding;
        totalWidth += itemWidth;
    }
    
    return totalWidth;
}

- (void)layoutTabbarItems {
    CGFloat itemPadding = 20;
    CGFloat itemMarginLeft = 12;
    CGFloat contentHeight = CGRectGetHeight(self.scrollContentView.bounds);
    
    for (NSInteger i = 0; i < self.itemButtonArray.count; i++) {
        UIButton *itemButton = self.itemButtonArray[i];
        NSNumber *widthNumber = self.itemTitleWidthArray[i];
        CGFloat titleWidth = [widthNumber floatValue];
        CGFloat itemWidth = titleWidth + 2 * itemPadding;
        
        itemButton.frame = CGRectMake(itemMarginLeft, 0, itemWidth, contentHeight);
        itemMarginLeft += itemWidth;
    }
}

/// 重新设置Tabbar
- (void)rebuildTabbar {
    for (UIButton *itemButton in self.itemButtonArray) {
        [itemButton removeFromSuperview];
    }
    [self.itemButtonArray removeAllObjects];
    [self.itemTitleWidthArray removeAllObjects];
    
    for (NSInteger i = 0; i < self.tabbarItemArray.count; i++) {
        NSString *title = self.tabbarItemArray[i];
        UIButton *itemButton = [self createButtonWithTitle:title];
        itemButton.tag = 100 + i;
        itemButton.selected = self.currentIndex == i;
        
        CGFloat titleWidth = [title boundingRectWithSize:CGSizeMake(1000, 16) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.width;
        
        [self.scrollContentView addSubview:itemButton];
        [itemButton addTarget:self action:@selector(clickItemAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.itemButtonArray addObject:itemButton];
        [self.itemTitleWidthArray addObject:[NSNumber numberWithFloat:titleWidth]];
    }
    [self setNeedsLayout];
    [self updateIndexView];
}

/// 更新indexView位置
- (void)updateIndexView {
    [self updateIndexViewFrame];
}

- (void)updateIndexViewFrame {
    self.indexView.hidden = self.currentIndex >= self.itemButtonArray.count;
    if (self.currentIndex < self.itemButtonArray.count && self.itemButtonArray.count > 0) {
        UIButton *item = self.itemButtonArray[self.currentIndex];
        CGFloat width = [self.itemTitleWidthArray[self.currentIndex] floatValue];
        CGFloat contentHeight = CGRectGetHeight(self.scrollContentView.bounds);
        CGFloat indexViewHeight = 2;
        CGFloat indexViewX = CGRectGetMidX(item.frame) - width / 2.0;
        CGFloat indexViewY = contentHeight - indexViewHeight;
        
        self.indexView.frame = CGRectMake(indexViewX, indexViewY, width, indexViewHeight);
    }
}

/// 生成itemButton
/// @param title title
- (UIButton *)createButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:0];
    UIColor *normalColor = [PLVVodMediaColorUtil colorFromHexString:@"#FFFFFF" alpha:0.6];
    [button setTitleColor:normalColor forState:0];
    [button setTitleColor:[PLVVodMediaColorUtil colorFromHexString:@"#FFFFFF"] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    return button;
}

#pragma mark - Setter

-(void)setTabbarItemArray:(NSArray<NSString *> *)tabbarItemArray {
    _tabbarItemArray = tabbarItemArray;
    [self rebuildTabbar];
}

-(void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    [self updateIndexView];
}

#pragma mark - Action

/// 点击关闭按钮
- (void)clickCloseButtonAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(plvSlideTabbarViewCloseButtonAction:)]) {
        [self.delegate plvSlideTabbarViewCloseButtonAction:self];
    }
}

/// 点击item
/// @param button item
- (void)clickItemAction:(UIButton *)button {
    NSInteger index = button.tag - 100;
    for (NSInteger i = 0; i < self.itemButtonArray.count; i++) {
        UIButton *itemButton = self.itemButtonArray[i];
        itemButton.selected = i == index;
    }
    self.currentIndex = index;
    if (self.delegate && [self.delegate respondsToSelector:@selector(plvSlideTabbarView:selectItemAtIndex:)]) {
        [self.delegate plvSlideTabbarView:self selectItemAtIndex:index];
    }
}

#pragma mark - Loadlazy

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)scrollContentView {
    if (_scrollContentView == nil) {
        _scrollContentView = [[UIView alloc]init];
    }
    return _scrollContentView;
}

- (UIView *)indexView {
    if (_indexView == nil) {
        _indexView = [[UIView alloc]init];
        _indexView.backgroundColor = [PLVVodMediaColorUtil colorFromHexString:@"#3990FF"];
    }
    return _indexView;
}

- (UIButton *)closeButton {
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"plv_skin_white_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(clickCloseButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (NSMutableArray<UIButton *> *)itemButtonArray {
    if (_itemButtonArray == nil) {
        _itemButtonArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _itemButtonArray;
}

- (NSMutableArray *)itemTitleWidthArray {
    if (_itemTitleWidthArray == nil) {
        _itemTitleWidthArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _itemTitleWidthArray;
}


@end
