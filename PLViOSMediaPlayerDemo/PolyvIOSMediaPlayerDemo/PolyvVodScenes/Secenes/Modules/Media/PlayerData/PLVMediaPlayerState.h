//
//  PLVMediaPlayerState.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVMediaPlayerState : NSObject

@property (nonatomic, assign) BOOL isSupportAudioMode;  // 音频模式
@property (nonatomic, assign, readonly) BOOL isSupportWindowMode; // 小窗模式
@property (nonatomic, assign) NSInteger curPlayMode;    // 当前播放模式 1:视频模式 2：音频模式
@property (nonatomic, assign) NSInteger curWindowMode;  // 当前窗口模式 1:普通模式 2：小窗模式
@property (nonatomic, assign) NSInteger curQualityLevel; // 当前清晰度
@property (nonatomic, assign) NSInteger qualityCount;    // 清晰度数量
@property (nonatomic, assign) CGFloat curPlayRate;       // 当前倍速
@property (nonatomic, assign) CGFloat origPlayRate;       // 记录上一次播放速度

@property (nonatomic, copy) NSString *snapshot;          // 视频封面
@property (nonatomic, assign) CGFloat ratio;             // 视频宽高比
@property (nonatomic, copy) NSString *videoTitle;        // 视频标题

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) BOOL isLocking;

@end

NS_ASSUME_NONNULL_END
