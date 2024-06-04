//
//  PLVVodMediaFeedItemView.h
//  PolyvLiveScenesDemo
//
//  Created by MissYasiky on 2023/6/21.
//  Copyright © 2023 PLV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PLVVodMediaFeedViewDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface PLVVodMediaFeedItemView : UICollectionViewCell

@property (nonatomic, strong, readonly) UIView <PLVVodMediaFeedItemCustomViewDelegate>*customContentView;

- (void)setCustomContentView:(UIView <PLVVodMediaFeedItemCustomViewDelegate>*)customContentView;

@end

NS_ASSUME_NONNULL_END
