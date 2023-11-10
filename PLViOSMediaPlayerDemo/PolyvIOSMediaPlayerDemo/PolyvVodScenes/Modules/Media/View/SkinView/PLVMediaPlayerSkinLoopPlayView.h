//
//  PLVMediaPlayerSkinLoopPlayView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/10/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaPlayerSkinLoopPlayViewDelegate;

@interface PLVMediaPlayerSkinLoopPlayView : UIView

@property (nonatomic, weak) id<PLVMediaPlayerSkinLoopPlayViewDelegate> delegate;

- (void)showMediaPlayerLoopPlayView;

@end

@protocol PLVMediaPlayerSkinLoopPlayViewDelegate <NSObject>

/// 返回按钮事件
- (void)mediaPlayerLoopPlayView_BackEvent:(PLVMediaPlayerSkinLoopPlayView *)loopPlayView;

/// 重新播放事件
- (void)mediaPlayerLoopPlayView_LoopPlay:(PLVMediaPlayerSkinLoopPlayView *)loopPlayView;

@end
NS_ASSUME_NONNULL_END
