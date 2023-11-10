//
//  PLVMediaPlayerSkinMoreView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/10.
//

#import <UIKit/UIKit.h>
#import "PLVMediaPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaPlayerSkinMoreViewDelegate ;

@interface PLVMediaPlayerSkinMoreView : UIView

@property (nonatomic, strong) id<PLVMediaPlayerSkinMoreViewDelegate> delegate;

-(void)showMoreViewWithModel:(PLVMediaPlayerState *)mediaPlayerState;

@end

@protocol PLVMediaPlayerSkinMoreViewDelegate <NSObject>

- (void)mediaPlayerSkinMoreView_SwitchToAudioMode:(PLVMediaPlayerSkinMoreView *)moreView;
- (void)mediaPlayerSkinMoreView_StartPictureInPicture:(PLVMediaPlayerSkinMoreView *)moreView;

@end

NS_ASSUME_NONNULL_END
