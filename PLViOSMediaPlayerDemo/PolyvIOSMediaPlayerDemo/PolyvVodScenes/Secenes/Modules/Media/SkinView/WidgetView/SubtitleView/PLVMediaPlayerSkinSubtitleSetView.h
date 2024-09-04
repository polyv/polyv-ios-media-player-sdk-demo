//
//  PLVMediaPlayerSkinSubtitleSetView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/8/14.
//

#import <UIKit/UIKit.h>
#import "PLVMediaPlayerSubtitleConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaPlayerSkinSubtitleSetViewDelegate <NSObject>

/// 选中字幕后，对外回调通知
- (void)mediaPlayerSkinSubtitleSetView_SelectSubtitle;

@end

@interface PLVMediaPlayerSkinSubtitleSetView : UIView

@property (nonatomic, weak) id<PLVMediaPlayerSkinSubtitleSetViewDelegate> delegate;

- (void)showWithConfigModel:(PLVMediaPlayerSubtitleConfigModel *)configModel;

@end

NS_ASSUME_NONNULL_END
