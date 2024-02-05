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
        _curPlayRate = 1.0; // 倍速
        _origPlayRate = _curPlayRate; // 原始倍速
        _qualityState = PLVMediaPlayerQualityStateDefault;
    }
    
    return self;
}

- (BOOL)isSupportWindowMode{
    BOOL support = NO;
    // iOS 15 以上系统，支持小窗
    if (@available(iOS 15.0, *)){
        support = YES;
    }
    // 视频播放模式才支持小窗
    if (_curPlayMode == 2){
        support = NO;
    }
  
    return support;
}

@end
