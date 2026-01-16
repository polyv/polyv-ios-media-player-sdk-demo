//
//  PLVMediaKnowledgePointCell.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2026/1/4.
//

#import <UIKit/UIKit.h>
#import "PLVMediaKnowledgeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVMediaKnowledgePointCell : UITableViewCell

+ (PLVMediaKnowledgePointCell *)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) PLVMediaKnowledgeModel *pointModel;
@property (nonatomic, assign) BOOL isSelectCell;
@property (nonatomic, assign) BOOL isShowDesc;


@end

NS_ASSUME_NONNULL_END
