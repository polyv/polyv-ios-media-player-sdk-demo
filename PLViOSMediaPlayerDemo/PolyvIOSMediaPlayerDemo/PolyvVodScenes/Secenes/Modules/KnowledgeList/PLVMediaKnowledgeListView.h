//
//  PLVMediaKnowledgeListView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2026/1/4.
//

#import <UIKit/UIKit.h>
#import "PLVMediaKnowledgeModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface PLVMediaKnowledgeListView : UIView

@property (nonatomic, strong) PLVMediaKnowledgeModel *knowledgeModel;

@property (nonatomic, assign, readonly) BOOL showing;

/// 选中知识点回调
@property (nonatomic, copy) void (^selectKnowledgePointBlock)(PLVMediaKnowledgePoint *point);

/// 展示知识清单
- (void)showKnowledgeListView;

/// 隐藏知识清单
- (void)hideKnowledgeListView;

@end

NS_ASSUME_NONNULL_END
