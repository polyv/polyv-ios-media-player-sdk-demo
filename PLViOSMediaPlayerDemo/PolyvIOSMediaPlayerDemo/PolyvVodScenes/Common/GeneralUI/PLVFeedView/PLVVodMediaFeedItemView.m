//
//  PLVVodMediaFeedItemView.m
//  PolyvLiveScenesDemo
//
//  Created by MissYasiky on 2023/6/21.
//  Copyright © 2023 PLV. All rights reserved.
//

#import "PLVVodMediaFeedItemView.h"

@interface PLVVodMediaFeedItemView ()

@property (nonatomic, strong) UIView <PLVVodMediaFeedItemCustomViewDelegate>*customContentView;

@end

@implementation PLVVodMediaFeedItemView

- (void)setCustomContentView:(UIView <PLVVodMediaFeedItemCustomViewDelegate>*)customContentView {
    _customContentView = customContentView;
    
    for (UIView *subview in self.contentView.subviews) { // 把contentView里的视图清空
        if (subview && [subview isKindOfClass:[UIView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    self.contentView.frame = self.bounds;
    if (customContentView) {
        [self.contentView addSubview:customContentView];
        customContentView.frame = self.contentView.bounds;
    }
}

@end
