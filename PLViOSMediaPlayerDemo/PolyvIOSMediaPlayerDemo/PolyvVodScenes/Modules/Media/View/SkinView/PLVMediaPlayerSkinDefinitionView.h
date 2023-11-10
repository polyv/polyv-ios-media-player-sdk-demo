//
//  PLVMediaPlayerSkinDefinitionView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/9/11.
//

#import <UIKit/UIKit.h>
#import "PLVMediaPlayerState.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaPlayerSkinDefinitionViewDelegate;

@interface PLVMediaPlayerSkinDefinitionView : UIView

@property (nonatomic, weak) id<PLVMediaPlayerSkinDefinitionViewDelegate> delegate;

- (void)showDefinitionViewWithModel:(PLVMediaPlayerState *)mediaState;

@end

@protocol PLVMediaPlayerSkinDefinitionViewDelegate <NSObject>

- (void)mediaPlayerSkinDefinitionView_SwitchQualtiy:(NSInteger)qualityLevel;

@end

NS_ASSUME_NONNULL_END
