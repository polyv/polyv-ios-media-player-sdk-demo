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
@property (nonatomic, strong) PLVMediaPlayerState *mediaPlayerState;

-(void)showMoreViewWithModel:(PLVMediaPlayerState *)mediaPlayerState;

@end

@protocol PLVMediaPlayerSkinMoreViewDelegate <NSObject>

- (void)mediaPlayerSkinMoreView_SwitchPlayMode:(PLVMediaPlayerSkinMoreView *)moreView;
- (void)mediaPlayerSkinMoreView_StartPictureInPicture:(PLVMediaPlayerSkinMoreView *)moreView;
- (void)mediaPlayerSkinMoreView_SetSubtitle:(PLVMediaPlayerSkinMoreView *)moreView;

@end

NS_ASSUME_NONNULL_END
