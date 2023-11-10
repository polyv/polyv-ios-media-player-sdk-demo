//
//  PLVMediaPlayerState.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/18.
//

#import "PLVMediaPlayerState.h"

@implementation PLVMediaPlayerState

- (instancetype)init{
    if (self = [super init]){
        _isSupportAudioMode = NO;
        _curPlayMode = 1;   // 视频模式
        _curWindowMode = 1; // 普通模式
        _curQualityLevel = 1; // 流畅
        _curPlayRate = 1.0;
        _origPlayRate = _curPlayRate;
    }
    
    return self;
}

- (BOOL)isSupportWindowMode{
    BOOL support = YES;
    if (_curPlayMode == 2){
        support = NO;
    }
    return support;
}

@end
