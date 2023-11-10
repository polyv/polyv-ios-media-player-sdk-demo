//
//  PLVMediaPlayerSkinFastForwardView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/10/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVMediaPlayerSkinFastForwardView : UIView

@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) double rate;

- (void)show;
- (void)hide;
- (void)setLoading:(BOOL)load;

@end

NS_ASSUME_NONNULL_END
