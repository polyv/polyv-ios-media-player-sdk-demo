//
//  PLVFeedItemView.h
//  PolyvLiveScenesDemo
//
//  Created by MissYasiky on 2023/6/21.
//  Copyright © 2023 PLV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVFeedViewDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVFeedItemView : UICollectionViewCell

@property (nonatomic, strong, readonly) UIView <PLVFeedItemCustomViewDelegate>*customContentView;

- (void)setCustomContentView:(UIView <PLVFeedItemCustomViewDelegate>*)customContentView;

@end

NS_ASSUME_NONNULL_END
