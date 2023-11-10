//
//  PLVFeedItemView.m
//  PolyvLiveScenesDemo
//
//  Created by MissYasiky on 2023/6/21.
//  Copyright © 2023 PLV. All rights reserved.
//

#import "PLVFeedItemView.h"

@interface PLVFeedItemView ()

@property (nonatomic, strong) UIView <PLVFeedItemCustomViewDelegate>*customContentView;

@end

@implementation PLVFeedItemView

- (void)setCustomContentView:(UIView <PLVFeedItemCustomViewDelegate>*)customContentView {
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
