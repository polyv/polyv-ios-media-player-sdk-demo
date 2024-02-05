//
//  PLVMediaPlayerState.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger) {
    PLVMediaPlayerQualityStateDefault = 0, // 默认,隐藏提示控件
    PLVMediaPlayerQualityStatePrepare, // 弱网提示，可以进行清晰度切换
    PLVMediaPlayerQualityStateChanging, // 清晰度切换中
    PLVMediaPlayerQualityStateComplete  // 清晰度切换完成
}PLVMediaPlayerQualityState;

@interface PLVMediaPlayerState : NSObject

@property (nonatomic, assign) BOOL isSupportAudioMode;  // 音频模式
@property (nonatomic, assign, readonly) BOOL isSupportWindowMode; // 小窗模式
@property (nonatomic, assign) NSInteger curPlayMode;    // 当前播放模式 1:视频模式 2：音频模式
@property (nonatomic, assign) NSInteger curWindowMode;  // 当前窗口模式 1:普通模式 2：小窗模式
@property (nonatomic, assign) NSInteger curQualityLevel; // 当前清晰度
@property (nonatomic, assign) NSInteger qualityCount;    // 清晰度数量
@property (nonatomic, assign) PLVMediaPlayerQualityState qualityState; // 清晰度切换状态
@property (nonatomic, assign) CGFloat curPlayRate;       // 当前倍速
@property (nonatomic, assign) CGFloat origPlayRate;       // 记录上一次播放速度

@property (nonatomic, copy) NSString *snapshot;          // 视频封面
@property (nonatomic, assign) CGFloat ratio;             // 视频宽高比
@property (nonatomic, copy) NSString *videoTitle;        // 视频标题

@property (nonatomic, assign) NSTimeInterval duration;  // 视频时长
@property (nonatomic, copy) NSString *progressImageString;    // 视频预览 雪碧图

@property (nonatomic, assign) BOOL isPlaying;  // 当前是否正在播放中

@property (nonatomic, assign) BOOL isLocking;  // 当前是否锁屏中

@end

NS_ASSUME_NONNULL_END
