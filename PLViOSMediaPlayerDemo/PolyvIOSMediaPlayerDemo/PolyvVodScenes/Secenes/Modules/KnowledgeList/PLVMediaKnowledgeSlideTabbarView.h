//
//  PLVMediaKnowledgeSlideTabbarView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2026/1/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVMediaKnowledgeSlideTabbarView;


@protocol PLVMediaKnowledgeSlideTabbarViewDelegate <NSObject>
/// 选中一级分类的回调
- (void)plvSlideTabbarView:(PLVMediaKnowledgeSlideTabbarView *)slideTabbarView selectItemAtIndex:(NSInteger)index;
/// 点击关闭按钮回调
- (void)plvSlideTabbarViewCloseButtonAction:(PLVMediaKnowledgeSlideTabbarView *)slideTabbarView;
@end

@interface PLVMediaKnowledgeSlideTabbarView : UIView

/// 一级分类数组
@property (nonatomic, strong) NSArray<NSString *> *tabbarItemArray;

/// 当前选中序号
@property (nonatomic, assign) NSInteger currentIndex;

@property(nonatomic, weak) id<PLVMediaKnowledgeSlideTabbarViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
