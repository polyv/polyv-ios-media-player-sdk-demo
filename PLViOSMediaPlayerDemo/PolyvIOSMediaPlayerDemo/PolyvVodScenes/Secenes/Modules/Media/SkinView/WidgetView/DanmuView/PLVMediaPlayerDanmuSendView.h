//
//  PLVMediaPlayerDanmuSendView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2026/1/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PLVMediaPlayerDanmuSendViewDelegate;

@interface PLVMediaPlayerDanmuSendView : UIView

@property (nonatomic, weak) id<PLVMediaPlayerDanmuSendViewDelegate> delegate;

@property (nonatomic, strong, readonly) NSString *danmuContent;
@property (nonatomic, assign, readonly) NSUInteger danmuColorHex;
@property (nonatomic, assign, readonly) int danmuFontSize;
@property (nonatomic, assign, readonly) NSInteger danmuMode;

@end

@protocol PLVMediaPlayerDanmuSendViewDelegate <NSObject>

/// 发送弹幕
- (void)danmuSendView:(PLVMediaPlayerDanmuSendView *)sendView didSendDanmuWithContent:(NSString *)content colorHex:(NSUInteger)colorHex fontSize:(int)fontSize mode:(NSInteger)mode;

@end

NS_ASSUME_NONNULL_END
