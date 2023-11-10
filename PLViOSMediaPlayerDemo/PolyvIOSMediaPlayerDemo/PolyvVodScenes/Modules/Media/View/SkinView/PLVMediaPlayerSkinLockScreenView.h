//
//  PLVMediaPlayerSkinLockScreenView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaPlayerSkinLockScreenViewDelegate;

@interface PLVMediaPlayerSkinLockScreenView : UIView

@property (nonatomic, weak) id<PLVMediaPlayerSkinLockScreenViewDelegate> delegate;
@property (nonatomic, strong) UIButton *unlockScreenBtn;

@end

@protocol PLVMediaPlayerSkinLockScreenViewDelegate <NSObject>

- (void)mediaPlayerSkinLockScreenView_unlockScreenEvent:(PLVMediaPlayerSkinLockScreenView *)lockScreenView;

@end

NS_ASSUME_NONNULL_END
