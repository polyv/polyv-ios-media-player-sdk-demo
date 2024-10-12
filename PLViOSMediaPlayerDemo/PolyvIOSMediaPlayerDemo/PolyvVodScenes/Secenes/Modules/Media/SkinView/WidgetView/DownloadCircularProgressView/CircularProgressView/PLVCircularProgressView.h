//
//  PLVCircularProgressView.h
//  PolyvIOSMediaPlayerDemo
//
//  Created by polyv on 2024/9/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PLVCircularProgressView : UIView

@property (nonatomic, assign) CGFloat progress; // 进度值，范围0.0到1.0
@property (nonatomic, strong) UIColor *trackColor; // 轨道颜色，默认为白色
@property (nonatomic, strong) UIColor *progressColor; // 进度颜色，默认为蓝色
@property (nonatomic, strong) UIColor *textColor; // 文本颜色，默认为黑色或其他合适颜色
@property (nonatomic, assign) CGFloat fontSize; // 字体大小
@property (nonatomic, assign) CGFloat lineWidth; // 进度轨道线宽

- (id)initWithFrame:(CGRect)frame andProgress:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
