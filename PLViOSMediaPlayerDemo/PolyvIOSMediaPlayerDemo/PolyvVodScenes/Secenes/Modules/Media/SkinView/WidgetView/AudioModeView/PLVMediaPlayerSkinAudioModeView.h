//
//  PLVMediaPlayerSkinAudioModeView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/11.
//

#import <UIKit/UIKit.h>
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>
#import "PLVMediaPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaPlayerSkinAudioModeViewDelegate;

@interface PLVMediaPlayerSkinAudioModeView : UIView

@property (nonatomic, weak) id<PLVMediaPlayerSkinAudioModeViewDelegate> delegate;
@property (nonatomic, strong) UIButton *switchButton;
@property (nonatomic, strong) PLVMediaPlayerState *mediaPlayerState;

- (void)startRotate;
- (void)stopRotate;

@end

@protocol PLVMediaPlayerSkinAudioModeViewDelegate <NSObject>

- (void)mediaPlayerSkinAudioModeView_switchVideoMode:(PLVMediaPlayerSkinAudioModeView *)audioModeView;

@end

NS_ASSUME_NONNULL_END
