//
//  PLVMediaPlayerSkinLandscapeSubtitleSetView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/8/15.
//

#import <UIKit/UIKit.h>
#import "PLVMediaPlayerSubtitleConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaPlayerSkinLandscapeSubtitleSetViewDelegage <NSObject>

/// 选中字幕后，对外回调通知
- (void)mediaPlayerSkinLandscapeSubtitleSetView_SelectSubtitle;

@end

@interface PLVMediaPlayerSkinLandscapeSubtitleSetView : UIView

@property (nonatomic, weak) id<PLVMediaPlayerSkinLandscapeSubtitleSetViewDelegage> delegate;

- (void)showWithConfigModel:(PLVMediaPlayerSubtitleConfigModel *)configModel;

@end

NS_ASSUME_NONNULL_END
