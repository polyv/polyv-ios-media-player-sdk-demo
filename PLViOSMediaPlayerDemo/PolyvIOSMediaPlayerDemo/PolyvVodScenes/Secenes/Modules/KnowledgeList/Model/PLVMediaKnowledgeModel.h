//
//  PLVMediaKnowledgeModel.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2026/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 知识清单model

@class PLVMediaKnowledgeWorkType;
@interface PLVMediaKnowledgeModel : NSObject

/// 按钮名称
@property (nonatomic, copy) NSString *buttonName;

/// 是否全屏展示, 默认NO
@property (nonatomic, assign) BOOL fullScreenStyle;

/// 一级分类list
@property (nonatomic, copy) NSArray<PLVMediaKnowledgeWorkType *> *knowledgeWorkTypes;

@end


#pragma mark - 一级分类model

@class PLVMediaKnowledgeWorkKey;
@interface PLVMediaKnowledgeWorkType : NSObject

/// 一级分类名
@property (nonatomic, copy) NSString *name;

/// 二级分类list，此项为空则不显示该WorkType一级分类
@property (nonatomic, copy) NSArray<PLVMediaKnowledgeWorkKey *> *knowledgeWorkKeys;

@end


#pragma mark - 二级分类model

@class PLVMediaKnowledgePoint;
@interface PLVMediaKnowledgeWorkKey : NSObject

/// 二级分类名
@property (nonatomic, copy) NSString *name;

/// 知识点list
@property (nonatomic, copy) NSArray<PLVMediaKnowledgePoint *> *knowledgePoints;

@end


#pragma mark - 知识点Model

@interface PLVMediaKnowledgePoint : NSObject

/// 描述
@property (nonatomic, copy) NSString *name;

/// 时间点
@property (nonatomic, assign) NSTimeInterval time;

@end

NS_ASSUME_NONNULL_END
