//
//  PLVMediaKnowledgeCategoryCell.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2026/1/4.
//

#import <UIKit/UIKit.h>
#import "PLVMediaKnowledgeModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface PLVMediaKnowledgeCategoryCell : UITableViewCell

+ (PLVMediaKnowledgeCategoryCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, copy) PLVMediaKnowledgeWorkKey *workKeyModel;
@property (nonatomic, assign) BOOL isSelectCell;


@end

NS_ASSUME_NONNULL_END
