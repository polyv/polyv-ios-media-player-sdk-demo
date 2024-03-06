//
//  PLVMediaPlayerSkinPicInPicPlaceholderView.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/3/5.
//

#import "PLVMediaPlayerSkinPicInPicPlaceholderView.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

@implementation PLVMediaPlayerSkinPicInPicPlaceholderView

#pragma mark -- life cycle
- (instancetype)init{
    if (self = [super init]){
        self.backgroundColor = [UIColor colorWithRed:32/255.0 green:38/255.0 blue:57.0/255.0 alpha:1.0];
        [self addSubview:self.placeholderLable];
    }
    
    return self;
}

- (void)layoutSubviews{
    self.placeholderLable.frame = CGRectMake(0, 0, self.bounds.size.width, 20);
    self.placeholderLable.center = self.center;
}

- (UILabel *)placeholderLable{
    if (!_placeholderLable){
        _placeholderLable = [[UILabel alloc] init];
        _placeholderLable.text = @"小窗播放中...";
        _placeholderLable.textColor = [UIColor whiteColor];
        _placeholderLable.textAlignment = NSTextAlignmentCenter;
        _placeholderLable.font = [UIFont systemFontOfSize:14.0];
    }
    
    return _placeholderLable;
}

@end
