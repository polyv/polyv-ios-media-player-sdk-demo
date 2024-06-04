//
//  PLVVodMediaToast.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2023/10/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PLVVodMediaToastView;
@interface PLVVodMediaToast : NSObject

/** 仅文字，展示在屏幕底部 */
+(void)showMessage:(NSString *)message;

@end

@interface PLVVodMediaToastView : UIView

-(instancetype)initWithMessage:(NSString *)message;

-(void)show;

@end
NS_ASSUME_NONNULL_END
